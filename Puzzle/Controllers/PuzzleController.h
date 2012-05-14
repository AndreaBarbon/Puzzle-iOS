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
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+CWAdditions.h"

#import "PieceView.h"
#import "MenuController.h"
#import "PuzzleCompletedController.h"
#import "Lattice.h"
#import "Piece.h"
#import "Puzzle.h"
#import "Image.h"
#import "CreatePuzzleOperation.h"

#define QUALITY 1.5

#define PIECE_SIZE_IPAD 180
#define PIECE_SIZE_IPHONE 75



@interface PuzzleController : UIViewController <UIGestureRecognizerDelegate, PieceViewProtocol, MenuProtocol, CreatePuzzleDelegate, UIAlertViewDelegate> {
    
    BOOL swiping;
    BOOL didRotate;
    BOOL receivedFirstTouch;
    BOOL loadingGame;
    
    BOOL panningDrawerUP;
    BOOL loadingFailed;
    
    CGPoint drawerFirstPoint;
    
    IBOutlet UIStepper *stepper;
    IBOutlet UIView *stepperDrawer;
    IBOutlet UIButton *restartButton;
    IBOutlet UILabel *percentageLabel;
    
    IBOutlet UIView *HUDView;
    IBOutlet UIView *firstPointView;


    
    NSArray *directions_positions;
    NSArray *directions_numbers;
    
    UIAlertView *alertView;

    
    int numberOfPiecesInDrawer;
    
    int DrawerPosition;
    int firstPiecePlace;
    
    float drawerSize;
    float drawerMargin;

    float biggerPieceSize;
    float screenWidth;
    float screenHeight;

    NSTimer *timer;
    
    PieceView *movingPiece;
    
}


@property(nonatomic) float piceSize;
@property(nonatomic) float elapsedTime;
@property(nonatomic) int NumberSquare;
@property(nonatomic) float padding;

@property(nonatomic) int pieceNumber;
@property(nonatomic) int loadedPieces;
@property(nonatomic) int missedPieces;
@property(nonatomic) int imageSize;
@property(nonatomic) int moves;
@property(nonatomic) int rotations;

@property(nonatomic) BOOL loadingGame;
@property(nonatomic) BOOL puzzleCompete;
@property(nonatomic) BOOL drawerStopped;


@property (nonatomic, retain) IBOutlet UISwitch *panningSwitch;


@property (nonatomic, retain) AVAudioPlayer *positionedSound;
@property (nonatomic, retain) AVAudioPlayer *completedSound;
@property (nonatomic, retain) AVAudioPlayer *neighborSound;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (nonatomic,retain) CreatePuzzleOperation *puzzleOperation;
@property (nonatomic,retain) Puzzle *puzzleDB;


@property (nonatomic, retain) IBOutlet UIView *drawerView;
@property (nonatomic, retain) IBOutlet UIView *menuButtonView;
@property (nonatomic, retain) IBOutlet UIImageView *puzzleCompleteImage;
@property (nonatomic, retain) IBOutlet UILabel *elapsedTimeLabel;;


@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) Lattice *lattice;
@property (nonatomic, retain) UIPanGestureRecognizer *pan;
@property (nonatomic, retain) UIPanGestureRecognizer *panDrawer;
@property (nonatomic, retain) UIPinchGestureRecognizer *pinch;

@property (nonatomic, retain) MenuController *menu;
@property (nonatomic, retain) PuzzleCompletedController *completedController;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *imageViewLattice;



+ (float)computeFloat:(float)f modulo:(float)m;

- (BOOL)pieceIsOut:(PieceView *)piece;
- (PieceView*)pieceWithNumber:(int)j;
- (PieceView*)pieceWithPosition:(int)j;
- (int)positionOfPiece:(PieceView*)piece;

- (void)toggleImageWithDuration:(float)duration;

- (IBAction)restartPuzzle:(id)sender;
- (IBAction)scrollDrawerRight:(id)sender;
- (IBAction)scrollDrawerLeft:(id)sender;
- (IBAction)togglePanningMode:(id)sender;
- (IBAction)puzzleCompleted;
- (IBAction)toggleMenu:(id)sender;

- (void)loadPuzzle;
- (BOOL)drawerStoppedShouldBeStopped;

- (CGRect)frameOfLatticePiece:(int)i;


- (void)panDrawer:(UIPanGestureRecognizer*)gesture;
- (void)pan:(UIPanGestureRecognizer*)gesture;

- (BOOL)pieceIsOut:(PieceView*)piece;
- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated;
- (void)groupMoved:(GroupView*)group;


- (void)startNewGame;
- (void)print_free_memory;
- (void)removeOldPieces;


- (void)allPiecesLoaded;
- (Piece*)pieceOfCurrentPuzzleDB:(int)n;

- (void)startTimer;
- (void)stopTimer;

- (void)loadingFailed;

- (void)puzzleSaved:(NSNotification *)saveNotification;
- (void)addPiecesToView;
- (void)resetSizeOfAllThePieces;
- (IBAction)rateGame;
- (BOOL)saveGame;
- (BOOL)isPositioned:(PieceView*)piece;

- (UIView*)upperGroupBut:(GroupView*)group;

@end
