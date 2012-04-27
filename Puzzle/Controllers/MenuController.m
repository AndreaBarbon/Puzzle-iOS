//
//  MenuController.m
//  Puzzle
//
//  Created by Andrea Barbon on 27/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "MenuController.h"
#import "PuzzleController.h"

@interface MenuController ()

@end

@implementation MenuController

@synthesize delegate, duringGame;

- (void)viewWillAppear:(BOOL)animated {

    resumeButton.hidden = !duringGame;
    
}

- (IBAction)startNewGame:(id)sender {
    
    //Warning: are you sure?
    
    [self.view removeFromSuperview];
    [delegate startNewGame];
    
}

- (IBAction)resumeGame:(id)sender {
    
    [self.view removeFromSuperview];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

@end
