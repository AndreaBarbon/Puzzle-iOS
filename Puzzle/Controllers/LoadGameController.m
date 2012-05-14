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
    
    contents = [[NSMutableArray alloc] initWithCapacity:100];
    images = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
    //contents =  [[NSMutableArray alloc] initWithArray:[managedObjectContext executeFetchRequest:fetchRequest1 error:nil]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)back:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame = CGRectMake(delegate.mainView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        delegate.mainView.frame = CGRectMake(0, 0, delegate.mainView.frame.size.width, delegate.mainView.frame.size.height);
    
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
    NSLog(@"DC");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Contents count %d", contents.count);

    return contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = YELLOW;
        cell.selectedBackgroundView = v;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
        
    cell.imageView.image = [images objectAtIndex:indexPath.row];

    cell.textLabel.text = [[[contents objectAtIndex:indexPath.row] lastSaved] description];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
