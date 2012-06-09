//
//  LoadGameController.m
//  Puzzle
//
//  Created by Andrea Barbon on 14/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "LoadGameController.h"
#import "PuzzleController.h"
#import "MenuController.h"
#import "Puzzle.h"
#import "Image.h"

@interface LoadGameController ()

@end

@implementation LoadGameController

@synthesize managedObjectContext, delegate, contents,images, tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"d MMM YYYY - hh:mm"];
    
    contents = [[NSMutableArray alloc] initWithCapacity:100];
    images = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    //contents =  [[NSMutableArray alloc] initWithArray:[managedObjectContext executeFetchRequest:fetchRequest1 error:nil]];
    
}

- (void)reloadData {
    
    if (loading) return;
    
    loading = YES;
    
    [tableView reloadData];
    
    indicator.alpha = 1;
    [indicator startAnimating];
    
    
    [NSThread detachNewThreadSelector:@selector(fetchData) toTarget:self withObject:nil];

}

- (void)fetchData {

//    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];    
//    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Image"  inManagedObjectContext:delegate.delegate.managedObjectContext];
//    [fetchRequest2 setEntity:entity2];    
//    NSLog(@"Images: %d", [[NSMutableArray arrayWithArray:[delegate.delegate.managedObjectContext executeFetchRequest:fetchRequest2 error:nil]] count]);
    
    
    NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Puzzle"  inManagedObjectContext:delegate.delegate.managedObjectContext];
    
    [fetchRequest1 setEntity:entity];
    fetchRequest1.predicate = [NSPredicate predicateWithFormat:@"name != %@", delegate.delegate.puzzleDB.name];
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastSaved" ascending:NO];
    [fetchRequest1 setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    dateSort = nil;
    [fetchRequest1 setFetchLimit:100];
    
    contents = [NSMutableArray arrayWithArray:[delegate.delegate.managedObjectContext executeFetchRequest:fetchRequest1 error:nil]];
    
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:100];
    
    for (Puzzle *puzzle in contents) {
        [array addObject:[[UIImage imageWithData:puzzle.image.data] imageByResizingToFitSize:CGSizeMake(400, 400) scaleUpIfNeeded:YES]];
    }
    
    images = array;
    array = nil;
    
    
    
    indicator.alpha = 0;
    [indicator stopAnimating];
    
    loading = NO;
    
    [tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)back:(id)sender {
    
    [delegate.delegate.managedObjectContext save:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.frame = CGRectMake(delegate.mainView.frame.size.width, self.view.frame.origin.y, 
                                     self.view.frame.size.width, self.view.frame.size.height);
        
        delegate.mainView.frame = CGRectMake(0, delegate.mainView.frame.origin.y, 
                                             delegate.mainView.frame.size.width, delegate.mainView.frame.size.height);
    
    }];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return !loading;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = YELLOW;
        cell.selectedBackgroundView = v;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = YELLOW;
        cell.textLabel.textAlignment = UITextAlignmentRight;        
        cell.detailTextLabel.textAlignment = UITextAlignmentRight;
    }
        
    Puzzle *puzzle = [contents objectAtIndex:indexPath.row];
    
    cell.imageView.image = [images objectAtIndex:indexPath.row];
    cell.textLabel.text = [df stringFromDate:[puzzle lastSaved]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d pieces, %d%% completed", puzzle.pieceNumber.intValue*puzzle.pieceNumber.intValue, puzzle.percentage.intValue];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView_ commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Puzzle *puzzleToDelete = [contents objectAtIndex:indexPath.row];

        [delegate.delegate.managedObjectContext deleteObject:puzzleToDelete];

        [delegate.delegate.managedObjectContext deleteObject:puzzleToDelete];
        [contents removeObjectAtIndex:indexPath.row];
        [images removeObjectAtIndex:indexPath.row];
        
        [tableView_ deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    delegate.delegate.puzzleCompete = NO;
    
    [delegate.delegate.managedObjectContext save:nil];
    [delegate.delegate prepareForNewPuzzle];
    [delegate.delegate loadPuzzle:[contents objectAtIndex:indexPath.row]];
    delegate.game.view.frame = CGRectMake(-delegate.mainView.frame.size.width, 
                                          delegate.game.view.frame.origin.y, 
                                          self.view.frame.size.width, 
                                          self.view.frame.size.height);        
    
    [UIView animateWithDuration:0.3 animations:^{
        
        delegate.game.view.frame = CGRectMake(0, delegate.game.view.frame.origin.y,
                                              self.view.frame.size.width, self.view.frame.size.height);        
        self.view.frame = CGRectMake(delegate.mainView.frame.size.width, self.view.frame.origin.y, 
                                     self.view.frame.size.width, self.view.frame.size.height);        
    }];
}

@end
