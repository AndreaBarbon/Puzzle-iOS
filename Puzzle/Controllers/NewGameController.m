//
//  NewGameController.m
//  Puzzle
//
//  Created by Andrea Barbon on 28/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "NewGameController.h"
#import "MenuController.h"
#import "PuzzleController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+CWAdditions.h"
#import "PuzzleLibraryController.h"

#define IMAGE_QUALITY 0.5


@interface NewGameController ()

@end

@implementation NewGameController

@synthesize popover, delegate, imagePath, startButton, image, tapToSelectLabel, puzzleLibraryButton, progressView, slider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //piecesLabel.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:40];
    backButton.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:40];
    startButton.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:40];
    
    //yourPhotosButton.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:30];
    //cameraButton.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:30];
    //puzzleLibraryButton.titleLabel.font = [UIFont fontWithName:@"Bello-Pro" size:30];
    
    //pieceNumberLabel.font = [UIFont fontWithName:@"Bello-Pro" size:80];

    
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d ", (int)slider.value*(int)slider.value];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        cameraButton.enabled = NO;
    }
    
    if (image.image==nil) {
        
        startButton.enabled = NO;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
     
        slider.maximumValue = 10;
                
    } else {

    }
    
    loadingView.layer.cornerRadius = 10;
    loadingView.layer.masksToBounds = YES;

    image.layer.cornerRadius = 20;
    image.layer.masksToBounds = YES;
    
    tapToSelectView.layer.cornerRadius = 20;
    tapToSelectView.layer.masksToBounds = YES;
    
    containerView.layer.cornerRadius = 20;
    containerView.layer.masksToBounds = YES;
    
    typeOfImageView.layer.cornerRadius = 20;
    typeOfImageView.layer.masksToBounds = YES;

    imagePath = [[NSString alloc] initWithFormat:@""];

    typeOfImageView.backgroundColor = WOOD;
    
}

- (void)adjustForAd {
    
    [delegate.delegate.view bringSubviewToFront:delegate.delegate.adBannerView];
    delegate.delegate.adBannerView.hidden = NO;

    IF_IPAD return;
    

    float origin = -delegate.delegate.adPresent*delegate.delegate.adBannerView.frame.size.height/2;
    
    NSLog(@"Origin = %.1f", origin);
    
    CGRect frame = self.view.frame;
    frame.origin.y = origin;
    self.view.frame = frame;
    
    frame = delegate.view.frame;
    frame.origin.y = origin;
    //delegate.view.frame = frame;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
        
    typeOfImageView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        delegate.chooseLabel.alpha = 0;
    }];

    [delegate.delegate.view bringSubviewToFront:delegate.delegate.menuButtonView];

    DLog(@"After picking");
    [delegate.delegate print_free_memory];
    
    NSData *dataJPG = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], IMAGE_QUALITY);
    
    DLog(@"Image size JPG = %.2f", (float)2*((float)dataJPG.length/10000000.0));
    
    [self dismissPicker];
        
    UIImage *temp = [UIImage imageWithData:dataJPG];    
    CGRect rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    imagePath = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
    
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.width);
    DLog(@"Original Rect = %.1f, %.1f, %.1f, %.1f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    tapToSelectLabel.hidden = YES;
    startButton.enabled = YES;    
    

    //image.image = [delegate.delegate clipImage:temp toRect:rect];
    image.image = temp;    
    
    [self adjustForAd];

}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    popover = nil;
    [UIView animateWithDuration:0.3 animations:^{
        delegate.chooseLabel.alpha = 0;
    }];

    [self adjustForAd];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [UIView animateWithDuration:0.3 animations:^{
        delegate.chooseLabel.alpha = 0;
    }];
    
    [self dismissPicker];
    
    [self adjustForAd];

}

- (void)dismissPicker {
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [popover dismissPopoverAnimated:NO];
        
    } else {  
        
        [self dismissModalViewControllerAnimated:YES];
    }   
        
}

- (void)imagePickedFromPuzzleLibrary:(UIImage*)pickedImage {
    
    typeOfImageView.hidden = YES;

    [UIView animateWithDuration:0.3 animations:^{
        delegate.chooseLabel.alpha = 0;
    }];

    
    [delegate.delegate.view bringSubviewToFront:delegate.delegate.menuButtonView];
    
    DLog(@"After picking");
    [delegate.delegate print_free_memory];
    
    NSData *dataJPG = UIImageJPEGRepresentation(pickedImage, IMAGE_QUALITY);
    
    DLog(@"Image size JPG = %.2f", (float)2*((float)dataJPG.length/10000000.0));
    
    [self dismissPicker];
    
    image.image = [UIImage imageWithData:dataJPG];
    
    tapToSelectLabel.hidden = YES;
    startButton.enabled = YES;    
    
    [self adjustForAd];

}





- (IBAction)selectImageFromPuzzleLibrary:(id)sender {
    
    [delegate playMenuSound];
    delegate.chooseLabel.alpha = 1;

    
    PuzzleLibraryController *c = [[PuzzleLibraryController alloc] init];
    c.delegate = self;
    
    IF_IPAD {
        
        delegate.delegate.adBannerView.hidden = YES;

        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        CGRect rect = CGRectMake(self.view.center.x, -20, 1, 1);
        [popover setPopoverContentSize:self.view.bounds.size];
        [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

        
    } else IF_IPHONE {
        
        [self presentModalViewController:c animated:YES];
    }

}

- (IBAction)selectImageFromPhotoLibrary:(UIButton*)sender {
    
    delegate.delegate.adBannerView.hidden = YES;

    [delegate playMenuSound];
    delegate.chooseLabel.alpha = 1;

    int direction;

    UIImagePickerController *c = [[UIImagePickerController alloc] init];
   
    if ([sender.titleLabel.text isEqualToString:@"Camera"]) {
        
        c.sourceType = UIImagePickerControllerSourceTypeCamera;
        direction = UIPopoverArrowDirectionUp;

    } else {

        c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        direction = UIPopoverArrowDirectionUp;
    }
    c.allowsEditing = YES;
    c.delegate = self;
    
    DLog(@"B4 picking");
    [delegate.delegate print_free_memory];
    
    
    IF_IPAD {
        
        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        CGRect rect = CGRectMake(self.view.center.x, -20, 1, 1);
        [popover setPopoverContentSize:self.view.bounds.size];
        [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:direction animated:YES];

    } else IF_IPHONE {
        
        [self presentModalViewController:c animated:YES];
    }
    
}

- (IBAction)selectImage:(id)sender {
    
    [delegate playMenuSound];

    typeOfImageView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        delegate.chooseLabel.alpha = 0;
    }];
}

- (IBAction)startNewGame:(id)sender {
    
    [delegate playMenuSound];
    
    DLog(@"Started");
    
    tapToSelectView.hidden = YES;
    
    delegate.delegate.loadingGame = NO;

    delegate.delegate.image = image.image;
    
    delegate.delegate.imageView.image = delegate.delegate.image;
    delegate.delegate.imageViewLattice.image = delegate.delegate.image;
    delegate.delegate.pieceNumber = (int)slider.value;
    
    
    [self startLoading];

    [delegate.delegate removeOldPieces];

    
    [delegate createNewGame];
    
}

- (IBAction)back:(id)sender {
    
    [delegate playMenuSound];

    if (typeOfImageView.hidden) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, 
                                         self.view.frame.size.width, self.view.frame.size.height);
            
            delegate.mainView.frame = CGRectMake(0, delegate.mainView.frame.origin.y, 
                                                 self.view.frame.size.width, self.view.frame.size.height);
            
        }completion:^(BOOL finished) {
            
            typeOfImageView.hidden = YES;
        }];
        
    } else {
        
        typeOfImageView.hidden = YES;
    }
    
}

- (void)startLoading {
    
    startButton.hidden = YES;
    backButton.hidden = YES;

    
    if (delegate.delegate.loadingGame) {
        
        int n = [delegate.delegate.puzzleDB.pieceNumber intValue];
        pieceNumberLabel.text = [NSString stringWithFormat:@"%d ", n*n];
        slider.value = (float)n;
        tapToSelectView.hidden = YES;
        image.image = delegate.delegate.image;

    } else {

        image.image = delegate.delegate.image;
    }

    slider.enabled = NO;    
    
    if (image.image==nil) {
        image.image = [UIImage imageNamed:@"Wood.jpg"];
    }
    
    progressView.hidden = NO;
    loadingView.hidden = NO;
    progressView.progress = 0.0;
    
    //timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveBar) userInfo:nil repeats:YES];
    

}


- (void)gameStarted {
    
    DLog(@"Game is started");
    
    [timer invalidate];

    [delegate toggleMenuWithDuration:0];
    
    progressView.progress = 0.0;
    delegate.delegate.loadedPieces = 0;
    progressView.hidden = YES;  
    loadingView.hidden = YES;
    startButton.hidden = NO;
    backButton.hidden = NO;
    pieceNumberLabel.hidden = NO;    
    slider.enabled = YES;    
    piecesLabel.hidden = NO;
    tapToSelectView.hidden = NO;
    tapToSelectLabel.hidden = NO;

    
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d ", (int)slider.value*(int)slider.value];    

}

- (void)loadingFailed {
    
    DLog(@"Game failed");
    
    [timer invalidate];
    
    [delegate toggleMenuWithDuration:0];
        
    progressView.progress = 0.0;
    delegate.delegate.loadedPieces = 0;
    progressView.hidden = YES;  
    loadingView.hidden = YES;
    
    startButton.hidden = NO;
    backButton.hidden = NO;
    
    pieceNumberLabel.hidden = NO;    
    slider.enabled = YES;    
    piecesLabel.hidden = NO;
    tapToSelectView.hidden = NO;
    tapToSelectLabel.hidden = NO ;
    
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d ", (int)slider.value*(int)slider.value];    
    
    self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, 
                                 self.view.frame.size.width, self.view.frame.size.height);

}


- (void)moveBar {
        
    float a = (float)delegate.delegate.loadedPieces;
    float b = (float)((int)slider.value*(int)slider.value);
    
    if (delegate.delegate.loadingGame) {
        
        b = delegate.delegate.NumberSquare;
    }
    
    progressView.progress = a/b;

}


- (IBAction)numberSelected:(UISlider*)sender {
        
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d ", (int)slider.value*(int)slider.value];

    
}








- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
