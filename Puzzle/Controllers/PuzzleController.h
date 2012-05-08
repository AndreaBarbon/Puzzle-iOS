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

#import "PieceView.h"
#import "MenuController.h"
#import "Lattice.h"
#import "Piece.h"
#import "Puzzle.h"
#import "Image.h"
#import "CreatePuzzleOperation.h"

#define QUALITY 1.5


@interface PuzzleController : UIViewController <UIScrollViewDelegate, PieceViewProtocol, MenuProtocol, CreatePuzzleDelegate, UIAlertViewDelegate> {
    
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
    IBOutlet UILabel *elapsedTimeLabel;
    
    IBOutlet UIView *HUDView;
    IBOutlet UIView *firstPointView;
    
    NSArray *directions;

    
    int numberOfPiecesInDrawer;
    
    int DrawerPosition;
    float drawerSize;
    float drawerMargin;

    float biggerPieceSize;
    
    NSTimer *timer;
    
    PieceView *movingPiece;
    
}


@property(nonatomic) float piceSize;
@property(nonatomic) float elapsedTime;
@property(nonatomic) float N;
@property(nonatomic) float padding;

@property(nonatomic) int pieceNumber;
@property(nonatomic) int loadedPieces;
@property(nonatomic) int missedPieces;
@property(nonatomic) int imageSize;

@property(nonatomic) BOOL loadingGame;
@property(nonatomic) BOOL puzzleCompete;


@property (nonatomic, retain) IBOutlet UISwitch *panningSwitch;


@property (nonatomic, strong) AVAudioPlayer *positionedSound;
@property (nonatomic, strong) AVAudioPlayer *completedSound;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

@property (nonatomic,retain) CreatePuzzleOperation *puzzleOperation;
@property (nonatomic,retain)  Puzzle *puzzleDB;


@property (nonatomic, retain) IBOutlet UIView *drawerView;
@property (nonatomic, retain) IBOutlet UIView *menuButtonView;


@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, retain) NSMutableArray *groups;
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
- (IBAction)togglePanningMode:(id)sender;

- (void)loadPuzzle;

- (CGRect)frameOfLatticePiece:(int)i;


- (void)panDrawer:(UIPanGestureRecognizer*)gesture;
- (void)pan:(UIPanGestureRecognizer*)gesture;

- (BOOL)pieceIsOut:(PieceView*)piece;
- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated;
- (void)groupMoved:(GroupView*)group;


- (void)startNewGame;
- (void)print_free_memory;
- (void)removeOldPieces;
- (UIImage*)clipImage:(UIImage*)img toRect:(CGRect)rect;


- (void)allPiecesLoaded;
- (Piece*)pieceOfCurrentPuzzleDB:(int)n;

- (void)startTimer;
- (void)stopTimer;

- (void)loadingFailed;

- (void)puzzleSaved:(NSNotification *)saveNotification;
- (void)addPiecesToView;
- (void)resetSizeOfAllThePieces;
- (void)refreshPieces;
- (IBAction)rateGame;
- (BOOL)saveGame;

@end
