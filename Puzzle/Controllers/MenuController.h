//
//  MenuController.h
//  Puzzle
//
//  Created by Andrea Barbon on 27/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PuzzleController;


@protocol MenuProtocol

- (void)startNewGame;

@end


@interface MenuController : UIViewController {
    
    IBOutlet UIButton *resumeButton;
    IBOutlet UIButton *newGameButton;
    
}

@property (nonatomic, assign) PuzzleController *delegate;
@property (nonatomic) BOOL duringGame;


- (IBAction)startNewGame:(id)sender;
- (IBAction)resumeGame:(id)sender;


@end
