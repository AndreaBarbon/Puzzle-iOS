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

@interface NewGameController ()

@end

@implementation NewGameController

@synthesize popover, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value*(int)slider.value];
    
    loadingView.layer.cornerRadius = 10;
    loadingView.layer.masksToBounds = YES;


}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [popover dismissPopoverAnimated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self dismissModalViewControllerAnimated:YES];
    }
        
    UIImage *temp = [info objectForKey:UIImagePickerControllerOriginalImage];    
    CGRect rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    
    //rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    
    tapToSelectView.hidden = YES;
    startButton.enabled = YES;    
    
    image.image = [delegate.delegate clipImage:temp toRect:rect];
    
    
    
}

- (IBAction)selectImage:(id)sender {
    
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.allowsEditing = YES;
    c.delegate = self;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        [popover presentPopoverFromRect:loadingView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self presentModalViewController:c animated:YES];
    }

}

- (IBAction)startNewGame:(id)sender {
    
    NSLog(@"Started");
    
    startButton.enabled = NO;    
    progressView.hidden = NO;
    loadingView.hidden = NO;

    timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveBar) userInfo:nil repeats:YES];

    
    if (image.image == nil) {
        delegate.delegate.image = [UIImage imageNamed:@"Cover"];
        
    } else {
        delegate.delegate.image = image.image;
    }
    delegate.delegate.imageView.image = delegate.delegate.image;
    delegate.delegate.imageViewLattice.image = delegate.delegate.image;
    delegate.delegate.pieceNumber = (int)slider.value;
    
    
    [delegate.delegate removeOldPieces];

    [NSThread detachNewThreadSelector:@selector(createNewGame) toTarget:delegate withObject:nil];




    
}

- (void)gameStarted {

    NSLog(@"Game effectively starting");
    
    [timer invalidate];
    progressView.progress = 0.001;
    delegate.delegate.loadedPieces = 0;
    progressView.hidden = YES;  
    loadingView.hidden = YES;
    tapToSelectView.hidden = NO;


    NSLog(@"Game effectively started");

}


- (void)moveBar {
    
    float a = (float)delegate.delegate.loadedPieces;
    float b = (float)((int)slider.value*(int)slider.value);
    
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
