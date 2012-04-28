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

@class PuzzleController;
@class NewGameController;


@protocol MenuProtocol

- (void)startNewGame;

@end


@interface MenuController : UIViewController <NewGameDelegate> {
    
    IBOutlet UIButton *resumeButton;
    IBOutlet UIButton *newGameButton;
    IBOutlet UIButton *showThePictureButton;
    
    UIView *obscuringView;
    
}

@property (nonatomic, assign) PuzzleController *delegate;
@property (nonatomic) BOOL duringGame;
@property (nonatomic, retain) NewGameController *game;


- (IBAction)startNewGame:(id)sender;
- (IBAction)resumeGame:(id)sender;
- (IBAction)showThePicture:(id)sender;

- (void)toggleMenu;

- (void)createNewGame;


@end
