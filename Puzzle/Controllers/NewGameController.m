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

@interface NewGameController ()

@end

@implementation NewGameController

@synthesize popover, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pieceNumberLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value*(int)slider.value];


}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [popover dismissPopoverAnimated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self dismissModalViewControllerAnimated:YES];
    }
        
    image.image = [info objectForKey:UIImagePickerControllerEditedImage];
    
}

- (IBAction)selectImage:(id)sender {
    
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.allowsEditing = YES;
    c.delegate = self;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        CGRectMake(imageButton.center.x, imageButton.center.y, 1, 1);
        [popover presentPopoverFromRect:imageButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self presentModalViewController:c animated:YES];
    }

}

- (IBAction)startNewGame:(id)sender {
    
    NSLog(@"Started");
    
    startButton.hidden = YES;    
    progressView.hidden = NO;
    indicator.hidden = NO;

    timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveBar) userInfo:nil repeats:YES];

    
    delegate.delegate.image = image.image;
    delegate.delegate.imageView.image = delegate.delegate.image;
    delegate.delegate.imageViewLattice.image = delegate.delegate.image;
    delegate.delegate.pieceNumber = (int)slider.value;
    
    [NSThread detachNewThreadSelector:@selector(createNewGame) toTarget:delegate withObject:nil];
    
}

- (void)gameStarted {

    [timer invalidate];
    progressView.progress = 0.001;
    delegate.delegate.loadedPieces = 0;
    startButton.hidden = NO;    
    progressView.hidden = YES;  
    indicator.hidden = YES;

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
