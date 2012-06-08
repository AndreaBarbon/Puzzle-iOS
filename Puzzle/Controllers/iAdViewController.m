//
//  iAdViewController.m
//  Puzzle
//
//  Created by Andrea Barbon on 07/06/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "iAdViewController.h"
#import "PuzzleController.h"

@interface iAdViewController ()

@end

@implementation iAdViewController

@synthesize managedObjectContext, persistentStoreCoordinator, puzzle, adBannerView;


#pragma mark -
#pragma iAd

- (void)viewDidLoad {
    
//    [self createAdBannerView];
//    [self.view addSubview:adBannerView];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return !duringAD;

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    adBannerView.hidden = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect rect;
        float screenWidth = [[UIScreen mainScreen] bounds].size.width;
        float screenHeight = [[UIScreen mainScreen] bounds].size.height;
        
        
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:adBannerView.currentContentSizeIdentifier];
            rect = CGRectMake(0, screenHeight-bannerSize.height*adBannerView.bannerLoaded, 0, 0);
        } else {
            adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
            CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:adBannerView.currentContentSizeIdentifier];
            rect = CGRectMake(0, screenWidth-bannerSize.height*adBannerView.bannerLoaded, 0, 0);
        }
        
        adBannerView.frame = rect;
        
    }completion:^(BOOL finished) {
        
        adBannerView.hidden = NO;
        
    }];

    [self.view bringSubviewToFront:self.adBannerView];
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
   
}


- (void) createAdBannerView
{
    
    CGRect rect;
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        rect = CGRectMake(0, screenHeight, 0, 0);
    } else {
        rect = CGRectMake(0, screenWidth, 0, 0);
    }

    adBannerView = [[ADBannerView alloc] initWithFrame:rect];
    adBannerView.hidden = YES;
    [self.view addSubview:adBannerView];
    
    adBannerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;


    
//    CGRect bannerFrame = adBannerView.frame;
//    bannerFrame.origin.y = self.view.frame.size.height;
//    adBannerView.frame = bannerFrame;
    
    adBannerView.delegate = self;
    adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"------> AD");
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"AD error");
    
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    IF_IPAD [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    duringAD = YES;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
    IF_IPAD [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    duringAD = NO;
}


- (void) adjustBannerViewWithOrientation:(UIInterfaceOrientation)orientation
{
    
    CGRect rect;
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:adBannerView.currentContentSizeIdentifier];
        rect = CGRectMake(0, screenHeight-bannerSize.height*adBannerView.bannerLoaded, 0, 0);
    } else {
        adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:adBannerView.currentContentSizeIdentifier];
        rect = CGRectMake(0, screenWidth-bannerSize.height*adBannerView.bannerLoaded, 0, 0);
    }
    
    
    [UIView animateWithDuration:0.5 animations:^{        
        
        adBannerView.frame = rect;
        
    }completion:^(BOOL finished) {
        
        adBannerView.hidden = NO;
        
    }];
    

    [self.view bringSubviewToFront:self.adBannerView];
    
    return;
        
    
    
    
    
    
    CGRect windowViewFrame = [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame];
    CGRect adBannerFrame = adBannerView.frame;
    CGPoint adBannerCenter = adBannerView.center;
    
    


    if([adBannerView isBannerLoaded])
    {
        //adBannerCenter.y -= bannerSize.height;
        //windowViewFrame.size.height = windowViewFrame.size.height - bannerSize.height;
    } else {
        //adBannerCenter.y += bannerSize.height;
    }
    adBannerFrame.origin.y = windowViewFrame.size.height;

    [self.view bringSubviewToFront:self.adBannerView];

        
    [UIView animateWithDuration:0.5 animations:^{
        
        adBannerView.center = adBannerCenter; 
       
        int direction = 1;
        
        if (windowViewFrame.size.height==self.view.frame.size.height) {
            NSLog(@"Zero");
            direction = 0;
        }
        
        if (windowViewFrame.size.height>self.view.frame.size.height) {
            direction = -1;
            NSLog(@"meno uno");
        }
        
       [(PuzzleController*)self adjustForAd:direction];
        
        self.view.frame = windowViewFrame;
    }];
    
}

@end
