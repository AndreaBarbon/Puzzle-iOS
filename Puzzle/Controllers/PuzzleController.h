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
    IBOutlet UIView *drawerView;
    IBOutlet UIStepper *stepper;
    IBOutlet UIStepper *stepperDrawer;
    IBOutlet UIButton *restartButton;
    int DrawerPosition;
}


@property(nonatomic) float piceSize;
@property(nonatomic) float N;
@property(nonatomic) int pieceNumber;


@property (nonatomic, retain) NSArray *pieces;
@property (nonatomic, retain) Lattice *lattice;

@property (nonatomic, retain) UIPopoverController *popover;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;



+(float)float:(float)f modulo:(float)m;

- (PieceView*)pieceWithNumber:(int)j;
- (PieceView*)pieceWithPosition:(int)j;
- (int)positionOfPiece:(PieceView*)piece;

- (IBAction)scrollDrawer:(id)sender;
- (IBAction)restartPuzzle:(id)sender;

- (CGRect)frameOfLatticePiece:(int)i;


-(BOOL)pieceIsOut:(PieceView*)piece;
- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated;



@end
