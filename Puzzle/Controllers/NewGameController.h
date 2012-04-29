//
//  NewGameController.h
//  Puzzle
//
//  Created by Andrea Barbon on 28/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuController;

@protocol NewGameDelegate

- (void)createNewGame;

@end

@interface NewGameController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    
    IBOutlet UIImageView *image;
    IBOutlet UILabel *pieceNumberLabel;
    IBOutlet UISlider *slider;
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *imageButton;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIActivityIndicatorView *indicator;
    NSTimer *timer;
    
    int times;
}

@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, assign) MenuController *delegate;


- (IBAction)startNewGame:(id)sender;
- (IBAction)numberSelected:(UISlider*)sender;
- (IBAction)selectImage:(id)sender;
- (void)gameStarted;
- (void)moveBar;



@end
