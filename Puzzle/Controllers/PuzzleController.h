//
//  PuzzleController.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PieceView.h"
#import "Lattice.h"


@interface PuzzleController : TopClass <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, PieceViewProtocol> {
    
    BOOL swiping;
    CGPoint drawerFirstPoint;
    IBOutlet UIView *menuButtonView;
}

@property(nonatomic) float piceSize;


@property (nonatomic, retain) NSArray *pieces;
@property (nonatomic, retain) Lattice *lattice;

@property (nonatomic, retain) UIPopoverController *popover;

@property (nonatomic, retain) IBOutlet UIScrollView *sv;


@end
