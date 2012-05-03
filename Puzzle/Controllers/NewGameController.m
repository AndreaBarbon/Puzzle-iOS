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

#define IMAGE_QUALITY 0.5


@interface NewGameController ()

@end

@implementation NewGameController

@synthesize popover, delegate, imagePath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value*(int)slider.value];
    
    loadingView.layer.cornerRadius = 10;
    loadingView.layer.masksToBounds = YES;

    image.layer.cornerRadius = 20;
    image.layer.masksToBounds = YES;
    
    tapToSelectView.layer.cornerRadius = 20;
    tapToSelectView.layer.masksToBounds = YES;

    imagePath = [[NSString alloc] initWithFormat:@""];
    
    //progressView.progressTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    //slider.minimumTrackTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];


}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [delegate.delegate.view bringSubviewToFront:delegate.delegate.menuButtonView];

    NSLog(@"After picking");
    [delegate.delegate print_free_memory];
    
    NSData *dataJPG = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], IMAGE_QUALITY);
    
    NSLog(@"Image size JPG = %.2f", (float)2*((float)dataJPG.length/10000000.0));
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [popover dismissPopoverAnimated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self dismissModalViewControllerAnimated:YES];
    }
        
    UIImage *temp = [UIImage imageWithData:dataJPG];    
    CGRect rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    imagePath = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
    
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.width);
    NSLog(@"Original Rect = %.1f, %.1f, %.1f, %.1f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    tapToSelectView.hidden = YES;
    startButton.enabled = YES;    
    
    
    image.image = [delegate.delegate clipImage:temp toRect:rect];
        
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    [delegate.delegate.view bringSubviewToFront:delegate.delegate.menuButtonView];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

- (IBAction)selectImage:(id)sender {
    
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.allowsEditing = YES;
    c.delegate = self;
    
    NSLog(@"B4 picking");
    [delegate.delegate print_free_memory];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        [popover presentPopoverFromRect:loadingView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self presentModalViewController:c animated:YES];
    }
    
    [delegate.delegate.view sendSubviewToBack:delegate.delegate.menuButtonView];


}

- (IBAction)startNewGame:(id)sender {
    
    NSLog(@"Started");
    
    delegate.delegate.loadingGame = NO;
    
    if (image.image == nil) {
        delegate.delegate.image = [UIImage imageNamed:@"Cover"];
        
    } else {
        delegate.delegate.image = image.image;
    }
    delegate.delegate.imageView.image = delegate.delegate.image;
    delegate.delegate.imageViewLattice.image = delegate.delegate.image;
    delegate.delegate.pieceNumber = (int)slider.value;
    
    
    [self startLoading];

    [delegate.delegate removeOldPieces];

    
    [delegate createNewGame];




    
}

- (void)startLoading {
    
    startButton.hidden = YES;
    
    if (delegate.delegate.loadingGame) {
        
        int n = [delegate.delegate.puzzleDB.pieceNumber intValue]*[delegate.delegate.puzzleDB.pieceNumber intValue];
        pieceNumberLabel.text = [NSString stringWithFormat:@"%d", n];    
        slider.hidden = YES;    
        tapToSelectView.hidden = YES;
        image.image = delegate.delegate.image;

    } else {

        image.image = delegate.delegate.image;

    }
    
    progressView.hidden = NO;
    loadingView.hidden = NO;
    progressView.progress = 0.01;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveBar) userInfo:nil repeats:YES];
    

}


- (void)gameStarted {
    
    NSLog(@"Game is started");
    
    [timer invalidate];

    [delegate toggleMenuWithDuration:0];
    
    progressView.progress = 0.001;
    delegate.delegate.loadedPieces = 0;
    progressView.hidden = YES;  
    loadingView.hidden = YES;
    startButton.hidden = NO;
    pieceNumberLabel.hidden = NO;    
    slider.hidden = NO;    
    piecesLabel.hidden = NO;
    tapToSelectView.hidden = NO;
    
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value*(int)slider.value];    

}


- (void)moveBar {
    
    float a = (float)delegate.delegate.loadedPieces;
    float b = 2*(float)((int)slider.value*(int)slider.value);
    
    if (delegate.delegate.loadingGame) {
        
        b = delegate.delegate.N;
    }
    
    progressView.progress = a/b;

}


- (IBAction)numberSelected:(UISlider*)sender {
        
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value*(int)slider.value];

    
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
