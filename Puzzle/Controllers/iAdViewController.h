//
//  iAdViewController.h
//  Puzzle
//
//  Created by Andrea Barbon on 07/06/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class PuzzleController;

@interface iAdViewController : UIViewController <ADBannerViewDelegate> {
    
    BOOL duringAD;

    
}

@property (nonatomic, retain) IBOutlet ADBannerView *adBannerView;
@property (nonatomic, retain) PuzzleController *puzzle;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)createAdBannerView;

@end
