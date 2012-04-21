//
//  PuzzleController.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PuzzleController : TopClass <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate> {
    
    BOOL swiping;
    CGPoint drawerFirstPoint;
}

@property(nonatomic) float piceSize;


@property (nonatomic, retain) NSArray *pieces;
@property (nonatomic, retain) UIPopoverController *popover;

@property (nonatomic, retain) IBOutlet UIScrollView *sv;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;


@end
