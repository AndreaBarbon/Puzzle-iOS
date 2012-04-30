//
//  PuzzleController.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "PieceView.h"
#import "MenuController.h"
#import "Lattice.h"


@interface PuzzleController : TopClass < UIScrollViewDelegate, PieceViewProtocol, MenuProtocol> {
    
    BOOL swiping;
    BOOL didRotate;
    BOOL receivedFirstTouch;
    
    CGPoint drawerFirstPoint;
    IBOutlet UIView *menuButtonView;
    IBOutlet UIStepper *stepper;
    IBOutlet UIView *stepperDrawer;
    IBOutlet UIButton *restartButton;
    int DrawerPosition;
    float drawerSize;
    float drawerMargin;
}


@property(nonatomic) float piceSize;
@property(nonatomic) float N;
@property(nonatomic) int pieceNumber;
@property(nonatomic) int loadedPieces;

@property (nonatomic, strong) AVAudioPlayer *positionedSound;
@property (nonatomic, strong) AVAudioPlayer *completedSound;




@property (nonatomic, retain) IBOutlet UIView *drawerView;

@property (nonatomic, retain) NSArray *pieces;
@property (nonatomic, retain) Lattice *lattice;
@property (nonatomic, retain) UIPanGestureRecognizer *pan;
@property (nonatomic, retain) UIPanGestureRecognizer *panDrawer;

@property (nonatomic, retain) MenuController *menu;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *imageViewLattice;



+ (float)float:(float)f modulo:(float)m;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

- (BOOL)pieceIsOut:(PieceView *)piece;
- (PieceView*)pieceWithNumber:(int)j;
- (PieceView*)pieceWithPosition:(int)j;
- (int)positionOfPiece:(PieceView*)piece;

- (void)toggleImageWithDuration:(float)duration;

- (IBAction)restartPuzzle:(id)sender;
- (IBAction)scrollDrawerRight:(id)sender;
- (IBAction)scrollDrawerLeft:(id)sender;


- (CGRect)frameOfLatticePiece:(int)i;


- (void)panDrawer:(UIPanGestureRecognizer*)gesture;

- (BOOL)pieceIsOut:(PieceView*)piece;
- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated;

- (void)startNewGame;
- (void)print_free_memory;
- (void)removeOldPieces;
- (UIImage*)clipImage:(UIImage*)img toRect:(CGRect)rect;

@end
