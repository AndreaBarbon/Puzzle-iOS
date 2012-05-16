//
//  PuzzleLibraryController.m
//  Puzzle
//
//  Created by Andrea Barbon on 10/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PuzzleLibraryController.h"
#import "NewGameController.h"
#import "MenuController.h"
#import <QuartzCore/QuartzCore.h>

#define IMAGE_SIZE 240

@implementation PhotoCell

- (void)viewDidLoad
{
    self.backgroundColor = [UIColor clearColor];
}

@synthesize photo;

@end



@implementation PuzzleLibraryController

@synthesize delegate;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    thumbs = [[NSArray alloc] initWithArray:[self imagesForPuzzle]];
    paths = [[NSArray alloc] initWithArray:[self pathsForImages]];
    
    if (thumbs.count == 0) {
        delegate.puzzleLibraryButton.enabled = NO;
    }
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSArray*)imagesForPuzzle {
    
    NSArray *dirContents = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:nil];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:dirContents.count];
    for (NSString *string in dirContents) 
    {
        if ([string hasSuffix:@"_puzzle_thumb.jpg"]  || 
            [string hasSuffix:@"_puzzle_thumb.jpeg"] ||
            [string hasSuffix:@"_puzzle_thumb.png"]  ||
            [string hasSuffix:@"_puzzle_thumb.JPG"]  ||
            [string hasSuffix:@"_puzzle_thumb.JPEG"] ||
            [string hasSuffix:@"_puzzle_thumb.PNG"]
            ) {
            
            [tempArray addObject:[UIImage imageWithContentsOfFile:string]];
        } 
    }
    NSLog(@"Found %d thumbs", tempArray.count);
    return [NSArray arrayWithArray:tempArray];
    
}

- (NSArray*)pathsForImages {
    
    NSArray *dirContents = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:nil];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:dirContents.count];
    for (NSString *string in dirContents) 
    {
        if ([string hasSuffix:@"_puzzle.jpg"]  || 
            [string hasSuffix:@"_puzzle.jpeg"] ||
            [string hasSuffix:@"_puzzle.png"]  ||
            [string hasSuffix:@"_puzzle.JPG"]  ||
            [string hasSuffix:@"_puzzle.JPEG"] ||
            [string hasSuffix:@"_puzzle.PNG"]
            ) {
            
            [tempArray addObject:string];
        } 
    }
    NSLog(@"Found %d images", tempArray.count);
    return [NSArray arrayWithArray:tempArray];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.view.bounds.size.width;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return thumbs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        float w = self.view.bounds.size.width;
        cell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.photo = [[UIImageView alloc] initWithFrame:CGRectMake((w-IMAGE_SIZE)/2, (w-IMAGE_SIZE)/2, IMAGE_SIZE, IMAGE_SIZE)];
        cell.photo.layer.cornerRadius = 20;
        cell.photo.layer.masksToBounds = YES;
        [cell addSubview:cell.photo];
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = YELLOW;
        cell.selectedBackgroundView = v;
    }
    
    //NSString *path = [content objectAtIndex:indexPath.row];
    cell.photo.image = [thumbs objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate.delegate playMenuSound];
    NSString *path = [paths objectAtIndex:indexPath.row];
    [delegate imagePickedFromPuzzleLibrary:[UIImage imageWithContentsOfFile:path]];
}

@end
