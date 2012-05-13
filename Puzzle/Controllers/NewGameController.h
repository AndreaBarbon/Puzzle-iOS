//
//  NewGameController.h
//  Puzzle
//
//  Created by Andrea Barbon on 28/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuController, PuzzleLibraryController;

@protocol NewGameDelegate

- (void)createNewGame;

@end

@interface NewGameController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    
    IBOutlet UILabel *pieceNumberLabel;
    IBOutlet UIButton *piecesLabel;
    IBOutlet UISlider *slider;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *imageButton;
    IBOutlet UIButton *cameraButton;
    IBOutlet UIProgressView *progressView;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIView *loadingView;
    IBOutlet UIView *tapToSelectView;
    IBOutlet UIView *containerView;
    IBOutlet UIView *typeOfImageView;
    NSTimer *timer;
    
    int times;
}

@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) NSString *imagePath;
@property (nonatomic, assign) MenuController *delegate;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UIView *tapToSelectLabel;


- (IBAction)startNewGame:(id)sender;
- (IBAction)numberSelected:(UISlider*)sender;
- (IBAction)selectImage:(id)sender;
- (void)gameStarted;
- (void)moveBar;
- (void)startLoading;
- (void)loadingFailed;
- (void)imagePickedFromPuzzleLibrary:(UIImage*)pickedImage;

@end
