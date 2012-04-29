//
//  MenuController.m
//  Puzzle
//
//  Created by Andrea Barbon on 27/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "MenuController.h"
#import "PuzzleController.h"
#import "NewGameController.h"

@interface MenuController ()

@end

@implementation MenuController

@synthesize delegate, duringGame, game;

- (void)viewWillAppear:(BOOL)animated {
    

    
}

- (void)toggleMenu {
    
    
    resumeButton.hidden = !duringGame;
    showThePictureButton.hidden = !duringGame;    
    
    float obscuring;
    
    if (duringGame) {
        
        obscuring = 0.5;
        
    } else {
        obscuring = 1;
    }
    
    
    if (self.view.alpha==0) {
        
        [delegate.view removeGestureRecognizer:delegate.pan];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            obscuringView.alpha = obscuring;
            self.view.alpha = 1;
        }];
        
    } else {
     
        [delegate.view addGestureRecognizer:delegate.pan];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            NSLog(@"Animation started");
            [delegate print_free_memory];

            obscuringView.alpha = 0;
            self.view.alpha = 0;
            
        } completion:^(BOOL finished) {
            NSLog(@"Animation completed");
            [delegate print_free_memory];
            NSLog(@"\n\n\n\n");
        }];
    }
    
}

- (void)createNewGame {
    
    @autoreleasepool {
        
        [delegate startNewGame];
        
        game.view.transform = CGAffineTransformIdentity;
        
        [self toggleMenu];

    }
            
}


- (IBAction)startNewGame:(id)sender {
    
    //Warning: are you sure?
    
    //[self toggleMenu];
    //[delegate startNewGame];
    

    
    [UIView animateWithDuration:0.5 animations:^{
        
        game.view.transform = CGAffineTransformMakeTranslation(-self.view.frame.size.width,0);
        
    }];
    
    
}

- (IBAction)resumeGame:(id)sender {
    
    [self toggleMenu];

}

- (IBAction)showThePicture:(id)sender {

    //[self toggleMenu];    
    [delegate toggleImageWithDuration:0.5];
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

    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 20;

    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect rect = CGRectMake(0, 0, screen.size.height, screen.size.height);
    obscuringView = [[UIView alloc] initWithFrame:rect];
    obscuringView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [delegate.view addSubview:obscuringView];
    [delegate.view bringSubviewToFront:self.view];
    
    resumeButton.hidden = YES;
    showThePictureButton.hidden = YES; 
    
    
    game = [[NewGameController alloc] init];    
    game.view.frame = CGRectMake(self.view.frame.size.width, 0, game.view.frame.size.width, game.view.frame.size.height);
    game.delegate = self;

    [self.view addSubview:game.view];

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
