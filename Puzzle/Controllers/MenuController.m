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

@synthesize delegate, duringGame, game, obscuringView, mainView, menuSound, chooseLabel;


- (void)toggleMenuWithDuration:(float)duration {
    
    delegate.puzzleCompete = NO;

    resumeButton.hidden = !duringGame;
    showThePictureButton.hidden = !duringGame;  
    
    float obscuring;
    
    if (duringGame) {
        
        obscuring = 1;
        
    } else {
        obscuring = 1;
    }
    
    
    if (self.view.alpha==0) {
        
        [delegate.view removeGestureRecognizer:delegate.pan];

        [UIView animateWithDuration:duration animations:^{
            
            obscuringView.alpha = obscuring;
            self.view.alpha = 1;
        }];
        
        [delegate stopTimer];

        
    } else {
     
        [delegate.view addGestureRecognizer:delegate.pan];
        
        [UIView animateWithDuration:duration animations:^{
            
            obscuringView.alpha = 0;
            self.view.alpha = 0;
            
        } completion:^(BOOL finished) {

            game.view.frame = CGRectMake(self.view.frame.size.width, 0, game.view.frame.size.width, game.view.frame.size.height);
            mainView.frame = CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height);
            [delegate startTimer];

        }];
    }
    
}

- (void)createNewGame {
    
        
    [delegate startNewGame];
        
            
}


- (IBAction)startNewGame:(id)sender {
    
    //Warning: are you sure?
    
    //[self toggleMenu];
    //[delegate startNewGame];
    
    if (sender!=nil) {
        
        [self playMenuSound];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self showNewGameView];
            
        }];
        
    } else {
        
        [self showNewGameView];
    }
    
    
}

- (void)showNewGameView {
    
    chooseLabel.center = CGPointMake(self.view.center.x-5, self.view.center.y-280);
    game.tapToSelectLabel.hidden = NO;
    game.startButton.enabled = (game.image.image != nil);
    game.view.frame = CGRectMake(0, 0, game.view.frame.size.width, game.view.frame.size.height);
    mainView.frame = CGRectMake(-mainView.frame.size.width, 0, mainView.frame.size.width, mainView.frame.size.height);
    
}

- (void)loadSounds {
    
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"Scissors_Shears" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    menuSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [menuSound prepareToPlay];

}

- (void)playMenuSound {
    
    if (!IS_DEVICE_PLAUYING_MUSIC) {
        
        [menuSound play];
    }
}

- (IBAction)resumeGame:(id)sender {
    
    delegate.completedController.view.alpha = 0;
    delegate.puzzleCompleteImage.alpha = 0;
    [self toggleMenuWithDuration:0.5];
    [self playMenuSound];
}

- (IBAction)showThePicture:(id)sender {

    //[self toggleMenu];    
    [delegate toggleImageWithDuration:0.5];
    [self playMenuSound];
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
    [self loadSounds];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
     
        self.view.layer.masksToBounds = YES;
        self.view.layer.cornerRadius = 20;        
    }

    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect rect = CGRectMake(0, 0, screen.size.height, screen.size.height);
    obscuringView = [[UIView alloc] initWithFrame:rect];
    obscuringView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    
    
    chooseLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChooseLabel"]];
    chooseLabel.alpha = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [obscuringView addSubview:chooseLabel];
    
    [delegate.view addSubview:obscuringView];
    [delegate.view bringSubviewToFront:self.view];
    
    resumeButton.hidden = YES;
    showThePictureButton.hidden = YES; 
    
    
    game = [[NewGameController alloc] init];    
    game.view.frame = CGRectMake(self.view.frame.size.width, 0, game.view.frame.size.width, game.view.frame.size.height);
    mainView.frame = CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height);

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
