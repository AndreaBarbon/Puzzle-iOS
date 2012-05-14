//
//  MenuController.h
//  Puzzle
//
//  Created by Andrea Barbon on 27/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NewGameController.h"

#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>


@class PuzzleController;
@class NewGameController;
@class LoadGameController;


@protocol MenuProtocol

- (void)startNewGame;

@end


@interface MenuController : UIViewController <NewGameDelegate> {
    
    IBOutlet UIButton *resumeButton;
    IBOutlet UIButton *newGameButton;
    IBOutlet UIButton *showThePictureButton;
    IBOutlet UIButton *loadGameButton;
    
    IBOutlet UIImageView *image;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIView *loadingView;
    
}

@property (nonatomic, assign) PuzzleController *delegate;
@property (nonatomic) BOOL duringGame;
@property (nonatomic, retain) NewGameController *game;
@property (nonatomic, retain) LoadGameController *loadGameController;

@property (nonatomic, retain) UIView *obscuringView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIImageView *chooseLabel;


@property (nonatomic, retain) AVAudioPlayer *menuSound;


- (IBAction)startNewGame:(id)sender;
- (IBAction)resumeGame:(id)sender;
- (IBAction)loadGame:(id)sender;
- (IBAction)showThePicture:(id)sender;

- (void)toggleMenuWithDuration:(float)duration;

- (void)createNewGame;
- (void)playMenuSound;

@end
