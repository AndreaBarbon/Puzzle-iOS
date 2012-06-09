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

@synthesize managedObjectContext, persistentStoreCoordinator, puzzle, adBannerView, prevOrientation, adPresent;


#pragma mark -
#pragma iAd

- (void)viewDidLoad {
    
//    [self createAdBannerView];
//    [self.view addSubview:adBannerView];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;

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
    [(PuzzleController*)self adjustForAd:!adPresent];
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
    adPresent = YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"AD error");
    [(PuzzleController*)self adjustForAd:-1*adPresent];
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
    adPresent = NO;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    IF_IPAD [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    prevOrientation = self.interfaceOrientation;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
    if (self.interfaceOrientation != prevOrientation) [(PuzzleController*)self fuckingRotateTo:self.interfaceOrientation duration:0.5];
    [self adjustBannerViewWithOrientation:self.interfaceOrientation];
    
    IF_IPAD [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
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
        
    
}

@end
