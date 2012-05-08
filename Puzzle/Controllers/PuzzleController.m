//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#define PIECE_NUMBER 4
#define ORG_TIME 0.5

#import "PuzzleController.h"
#import "UIImage+CWAdditions.h"
#import "AppDelegate.h"
#import "GroupView.h"

#import <mach/mach.h>
#import <mach/mach_host.h>


@interface PuzzleController ()

@end


@implementation PuzzleController

@synthesize pieces, image, piceSize, lattice, N, pieceNumber, imageView, positionedSound, completedSound, imageViewLattice, menu, loadedPieces, drawerView, managedObjectContext, menuButtonView, persistentStoreCoordinator, puzzleOperation, padding, puzzleDB, operationQueue, missedPieces, loadingGame, elapsedTime, puzzleCompete, groups, panningSwitch, imageSize;

@synthesize pan, panDrawer;


#pragma mark -
#pragma mark ••••••  View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    imageSize = QUALITY;
    
//    firstPointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    firstPointView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:firstPointView];
    
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        imageSize *= 0.5;
     
        percentageLabel.font = [UIFont boldSystemFontOfSize:20.0];
        percentageLabel.transform = CGAffineTransformMakeTranslation(10, 10);
        
        elapsedTimeLabel.font = [UIFont boldSystemFontOfSize:20.0];
        elapsedTimeLabel.transform = CGAffineTransformMakeTranslation(10, 10);

        menuButtonView.transform = CGAffineTransformMakeTranslation(5, 10);
        panningSwitch.transform = CGAffineTransformMakeTranslation(-8, 10);
        panningSwitch.transform = CGAffineTransformScale(panningSwitch.transform, 0.8, 0.8);
                
    }
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    [self loadSounds];
    [self computePieceSize];
    
    //Add the image;
    image = [UIImage imageNamed:@"Wood.jpg"];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    rect = CGRectMake(0, (rect.size.height-rect.size.width)/1, rect.size.width, rect.size.width);
    imageView.frame = rect;
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    
    imageViewLattice = [[UIImageView alloc] initWithImage:image];
    
    
    
    //Resize the drawer
    CGRect drawerFrame = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    
    float width = [[UIScreen mainScreen] bounds].size.width;
    float height = [[UIScreen mainScreen] bounds].size.height;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        NSLog(@"Landscape!");
        
        drawerFrame.size.width = drawerSize;
        drawerFrame.size.height = width;
        stepperFrame.origin.y = 10;
        stepperFrame.origin.x = drawerFrame.size.width;
        
    } else {
        
        drawerFrame.size.height = drawerSize;
        drawerFrame.size.width = height;
        stepperFrame.origin.y = drawerFrame.size.height;
        stepperFrame.origin.x = 10;
        
    }
    
    drawerView.frame = drawerFrame;
    stepperDrawer.frame = stepperFrame;
    
    
    //Add the menu
    menu = [[MenuController alloc] init];
    menu.delegate = self;
    menu.duringGame = NO;
    menu.view.center = self.view.center;
    [self.view addSubview:menu.view];
    
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];
    
    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    
    
    panDrawer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDrawer:)];
    [panDrawer setMinimumNumberOfTouches:1];
    [panDrawer setMaximumNumberOfTouches:1];
    [drawerView addGestureRecognizer:panDrawer];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateTap:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPressure = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImage:)];
    [longPressure setMinimumPressDuration:0.5];
    [self.view addGestureRecognizer:longPressure];
    
    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeR setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeL setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:swipeL];
    
    
    
    
}

- (void)setup {
    
    
    pieceNumber = PIECE_NUMBER;
    N = pieceNumber*pieceNumber;
    
    //[self computePieceSize];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setup];
}


#pragma mark -
#pragma mark ••••••  Puzzle

- (void)loadPuzzle {
    
    loadingFailed = NO;

    
    if (managedObjectContext) {
        
        puzzleDB = [self lastSavedPuzzle];
        
        if (puzzleDB!=nil) {
            
            [self setPieceNumber:[puzzleDB.pieceNumber intValue]];
            for (UIView *v in groups) {
                [v removeFromSuperview];
            }
            groups = [[NSMutableArray alloc] initWithCapacity:N/2];
            elapsedTime = [puzzleDB.elapsedTime floatValue];
            percentageLabel.text = [NSString stringWithFormat:@"%.0f %%", [puzzleDB.percentage intValue]];
            
            
            if ([puzzleDB.percentage intValue]==100) {
                puzzleCompete = YES;
            }
            
            [self createPuzzleFromSavedGame];
            
        } else {
            [menu startNewGame:nil];
        }
        
    }
    
}

- (Puzzle*)lastSavedPuzzle {
    
    NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Puzzle"  inManagedObjectContext: managedObjectContext];
    
    [fetchRequest1 setEntity:entity];
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastSaved" ascending:NO];
    [fetchRequest1 setSortDescriptors:[NSArray arrayWithObject:dateSort]];
    dateSort = nil;
    
    [fetchRequest1 setFetchLimit:1];
    
    return [[managedObjectContext executeFetchRequest:fetchRequest1 error:nil] lastObject];

}

- (IBAction)toggleMenu:(id)sender {
    
    menu.duringGame = YES;
    [self.view bringSubviewToFront:menu.obscuringView];
    [self.view bringSubviewToFront:menu.view];
    [self.view bringSubviewToFront:menuButtonView];
    
    [menu toggleMenuWithDuration:0.5];
    
}

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)puzzleSaved:(NSNotification *)saveNotification {
        
    if ([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(puzzleSaved:) withObject:saveNotification waitUntilDone:NO];
    }
}

- (void)addPiecesToView {
    
    if ([NSThread isMainThread]) {
        
        for (PieceView *p in pieces) {
            
            [self.view addSubview:p];
            loadedPieces++;
        }
    
    } else {
    
        [self performSelectorOnMainThread:@selector(addPiecesToView) withObject:nil waitUntilDone:NO];
    }
}

- (void)allPiecesLoaded {
    
    if (loadingFailed) {
        return;
    }
    
    [self bringDrawerToTop];
    
    for (PieceView *p in pieces) {
        if (!p.isFree) {
            p.frame = CGRectMake(0, 0, piceSize, piceSize);
        }
    }
    
    
    
    BOOL debugging = NO;
    
    if (debugging) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            [p setIsPositioned:YES];
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        [imageViewLattice removeFromSuperview];
        
    } else {
        
        
        if (loadingGame) {
            
            pieces = [self shuffleArray:pieces];
            
            NSLog(@"Name: %@", puzzleDB.name);

            [self resetSizeOfAllThePieces];
            [self refreshPositions];
            [self organizeDrawerWithOrientation:self.interfaceOrientation];
            [self bringDrawerToTop];
            [self checkNeighborsForAllThePieces];
            [self updatePercentage];
            loadingGame = NO;
            NSLog(@"-----------> All pieces Loaded");
            
        } else {
            
            puzzleDB = [self lastSavedPuzzle];
            NSLog(@"Name: %@", puzzleDB.name);
            [self resetSizeOfAllThePieces];
            [self shuffle];
            [self updatePercentage];
            [self organizeDrawerWithOrientation:self.interfaceOrientation];
            NSLog(@"-----------> All pieces created");
            
        }
        
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [menu.game gameStarted];
    
    NSLog(@"Memory after creating:");
    [self print_free_memory];
    
    
    self.view.userInteractionEnabled = YES;
    
}

- (void)loadingFailed {
    
    loadingFailed = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    menu.duringGame = NO;
    [menu.game loadingFailed];
    [puzzleOperation cancel];
    self.view.userInteractionEnabled = YES;
    [menu toggleMenuWithDuration:0];
    
}

- (void)createPuzzleFromSavedGame {
    
    missedPieces = 0;
    loadingGame = YES;
    self.view.userInteractionEnabled = NO;
    drawerView.hidden = NO;
    
    [self computePieceSize];
    [self createLattice];
    drawerFirstPoint = CGPointMake(-self.padding/2+10, -self.padding/2+10);
    
    // add the importer to an operation queue for background processing (works on a separate thread)
    puzzleOperation = [[CreatePuzzleOperation alloc] init];
    puzzleOperation.delegate = self;
    puzzleOperation.loadingGame = YES;
    puzzleOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    menu.game.view.frame = CGRectMake(0, 0, menu.game.view.frame.size.width, menu.game.view.frame.size.height);
    
    image = [UIImage imageWithData:puzzleDB.image.data];
    
    
    imageView.image = image;
    imageViewLattice.image = image;
    
    [menu.game startLoading];
    
    [self.operationQueue addOperations:[NSArray arrayWithObject:puzzleOperation] waitUntilFinished:NO];
    
    
}

- (void)createPuzzleFromImage:(UIImage*)image_ {
    
    missedPieces = 0;
    loadingGame = NO;
    drawerView.hidden = NO;

    
    [self computePieceSize];
    [self createLattice];
    drawerFirstPoint = CGPointMake(-self.padding/2+10, -self.padding/2+10);
    
    // add the importer to an operation queue for background processing (works on a separate thread)
    puzzleOperation = [[CreatePuzzleOperation alloc] init];
    puzzleOperation.delegate = self;
    puzzleOperation.loadingGame = NO;
    puzzleOperation.queuePriority = NSOperationQueuePriorityVeryHigh;

    [self.operationQueue addOperation:puzzleOperation];
    
    
}

- (BOOL)isPuzzleComplete {
    
    if (puzzleCompete) {
        return YES;
    } else {
        
        for (PieceView *p in pieces) {
            if (!p.isPositioned) {
                //NSLog(@"Piece #%d is not positioned", p.number);
                
                return NO;
            }
        }
        
        [self puzzleCompleted];
        
        puzzleCompete = YES;
    }
    
    return puzzleCompete;
    
}

- (void)toggleImage:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan && menu.view.alpha == 0) {
        
        [self toggleImageWithDuration:0.5];
    }
    
}

- (void)toggleImageWithDuration:(float)duration {
    
    [UIView animateWithDuration:duration animations:^{
        if (imageView.alpha==0) {
            
            menuButtonView.userInteractionEnabled = NO;
            [self.view bringSubviewToFront:imageView];
            //[self bringDrawerToTop];
            imageView.alpha = 1;
            
        } else if (imageView.alpha==1) {
            
            menuButtonView.userInteractionEnabled = YES;
            imageView.alpha = 0;
        }
    }];
    
}

- (void)puzzleCompleted {
    
    //imageView.frame = lattice.bounds;
    
    [self.view bringSubviewToFront:lattice];
    for (UIView *v in lattice.pieces) {
        v.alpha = 0;
    }
    
    [self stopTimer];
    
    
    [UIView animateWithDuration:1 animations:^{
        drawerView.hidden = YES;
    }];
    
    
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
        
        [completedSound play];
        
    }
}



#pragma mark -
#pragma mark ••••••  Gesture handling

- (void)rotateTap:(UITapGestureRecognizer*)gesture {
    
    CGPoint point = [gesture locationInView:lattice];

    movingPiece = nil;
    
    for (int i= 0; i<N; i++) {
        
        CGRect rect = [[[lattice pieces] objectAtIndex:i] frame];
        
        if ([self point:point isInFrame:rect]) {
            movingPiece = [self pieceWithPosition:i];
        }
        
    }
    
    if (movingPiece!=nil) {
        [movingPiece rotateTap:gesture];
    }
}

- (void)pan:(UIPanGestureRecognizer*)gesture {
    
    CGPoint point = [gesture locationInView:lattice];
    
    if (gesture.state==UIGestureRecognizerStateBegan) {
        
        movingPiece = nil;
        
        for (int i= 0; i<N; i++) {
            
            CGRect rect = [[[lattice pieces] objectAtIndex:i] frame];
            
            if ([self point:point isInFrame:rect]) {
                movingPiece = [self pieceWithPosition:i];
            }
            
        }
    }
    
    if (movingPiece!=nil && !panningSwitch.isOn) {
        [movingPiece move:gesture];
    }
    
    
    if (menu.view.alpha == 0) {
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        if (ABS(traslation.x>0.03) || ABS(traslation.y) > 0.03) {
            
            lattice.transform = CGAffineTransformTranslate(lattice.transform, traslation.x/lattice.scale, traslation.y/lattice.scale);
            [self refreshPositions];
            [gesture setTranslation:CGPointZero inView:lattice.superview];
        }
    }
    
}

- (void)pinch:(UIPinchGestureRecognizer*)gesture {
    
    
    if (CGRectContainsPoint(drawerView.frame, [gesture locationInView:self.view])) {
        
        return;
    }
    
    
    float z = [gesture scale];
    
    if (z>1.03 || z < 0.97) {
        
        CGPoint point = CGPointMake([gesture locationInView:lattice].x, [gesture locationInView:lattice].y);
        [self setAnchorPoint:point forView:lattice];
        
        
        CGSize screen = [[UIScreen mainScreen] bounds].size;
        
        if (lattice.scale*z*pieceNumber*piceSize>piceSize && lattice.scale*z*piceSize<screen.width) {
            
            lattice.scale *= z;
            lattice.transform = CGAffineTransformScale(lattice.transform, z, z);
            
            for (GroupView *g in groups) {

                g.transform = CGAffineTransformScale(g.transform, z, z);
            }
        }
        
        [self refreshPositions];        
        
        [gesture setScale:1];
    }
    
    
}



#pragma mark -
#pragma mark ••••••  Groups

- (void)groupMoved:(GroupView*)group {
    
    CGRect frame;
    
    for (int i=N-1; i>-1; i--) {
        
        frame = [self frameOfLatticePiece:i];
        if ([self group:group isInFrame:frame]) {
            
            //NSLog(@"Group is in lattice piece #%d", i);
            [self moveGroup:group toLatticePoint:i animated:YES];
            
            break;
        }
        
    }
    
    [self.view bringSubviewToFront:group];    
    [self bringDrawerToTop];
    
}

- (void)createNewGroupForPiece:(PieceView*)piece {
        
    GroupView *newGroup = nil;
    
    //Checks if a group already exists in the neighborhood
    for (PieceView *p in [piece allTheNeighborsBut:nil]) {
        if (p.group!=nil && p!=piece) {
            newGroup = p.group;
            break;
        }
    }
    
    if (newGroup==nil) {
        
        float w = 0.5*[[UIScreen mainScreen] bounds].size.height;
        
        newGroup = [[GroupView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
        newGroup.boss = piece;
        newGroup.transform = lattice.transform;
        
        //piece.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.1];
        piece.isBoss = YES;
        piece.transform = CGAffineTransformScale(piece.transform, 1/lattice.scale, 1/lattice.scale);
        [self addPiece:piece toGroup:newGroup];
        
        for (PieceView *p in [piece allTheNeighborsBut:nil]) {
            p.isBoss = NO;
            [self addPiece:p toGroup:newGroup];
        }
        
        [groups addObject:newGroup];
        [self.view addSubview:newGroup];
        
        NSLog(@"New group created. Groups count %d", [groups count]);
        
    } else {

        piece.isBoss = NO;

        if (piece.group!=newGroup) {
            
            [self addPiece:piece toGroup:newGroup];
            NSLog(@"Piece #%d added to existing group", piece.number);

        }        
    }
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.group==nil) {
            [self.view bringSubviewToFront:p];
        }
    }
    
    
    [self moveGroup:newGroup toLatticePoint:newGroup.boss.position animated:NO];
    [self bringDrawerToTop];
    
}

- (void)addPiece:(PieceView*)piece toGroup:(GroupView*)group {
    
    if (piece.group==group) {
       
        return;
        
    } else {
        
        piece.group = group;
    }

    [piece removeFromSuperview];
    [group.pieces addObject:piece];

        
        [group addSubview:piece];
        
        //Reset piece size
        piece.transform = group.boss.transform;
        
        CGPoint relative = [self coordinatesOfPiece:piece relativeToPiece:group.boss];
        
        CGAffineTransform matrix = CGAffineTransformMakeRotation(group.boss.angle-group.angle);
        relative = [self applyMatrix:matrix toVector:relative];
        
        float w = [[lattice objectAtIndex:0] bounds].size.width+2;
        
        CGPoint trans = CGPointMake(relative.y*w, relative.x*w);
        
        piece.center = CGPointMake(group.boss.center.x+trans.x, group.boss.center.y+trans.y);
            
        [self refreshPositions];
        

}

- (void)moveGroup:(GroupView*)group toLatticePoint:(int)i animated:(BOOL)animated {
    
    PieceView *piece = group.boss;
    piece.position = i;

    CGPoint centerLattice = [self centerOfLatticePiece:i];
    CGPoint centerGroup = group.center;
    CGPoint centerPiece = piece.center;
            centerPiece = [self.view convertPoint:centerPiece fromView:group];
    CGPoint difference = CGPointMake(-centerPiece.x+centerGroup.x, -centerPiece.y+centerGroup.y);
    
    
    CGPoint newCenter = CGPointMake((centerLattice.x+difference.x), (centerLattice.y+difference.y));
    
    if (animated) {
        
        [UIView animateWithDuration:0.5 animations:^{
                        
            group.center = newCenter;

        }completion:^(BOOL finished) {
            
            [self checkNeighborsForAllThePieces];
            [self updatePositionsInGroup:group withReferencePiece:group.boss];
            [self updatePercentage];
            [self updateGroupDB:group];
            
        }];
        
    } else {

        group.center = newCenter;
        
    }
        
}

- (BOOL)group:(GroupView*)group isInFrame:(CGRect)frame {
    
    PieceView *piece = group.boss;
    CGPoint center = [group.superview convertPoint:piece.center fromView:group];
    return frame.origin.x<center.x && frame.origin.y<center.y;
    
}

- (void)updatePositionsInGroup:(GroupView*)group withReferencePiece:(PieceView*)boss {
    
    
    for (PieceView *p in group.pieces) {
        
        if (p!=boss) {
                        
            CGPoint relativePosition = [self coordinatesOfPiece:p relativeToPiece:boss];
            
            //NSLog(@"Relative Position = %.1f, %.1f, p.number-boss.number = %d", relativePosition.x, relativePosition.y, p.number-boss.number);

            CGAffineTransform matrix = CGAffineTransformMakeRotation(boss.angle); 
            relativePosition = [self applyMatrix:matrix toVector:relativePosition];

            //NSLog(@"Relative Position after matrix = %.1f, %.1f, p.number-boss.number = %d", relativePosition.x, relativePosition.y, p.number-boss.number);

            p.position = boss.position + relativePosition.x + pieceNumber*relativePosition.y;

            //NSLog(@"NewPosition = %d. %.1f, boss position = %d, %.1f", p.position, p.angle, boss.position, boss.angle);
            
        }
    }
    
    
    if ([self isPositioned:group.boss]) {
        
        for (PieceView *p in pieces) {
            
            if (p.group==group) {
                
                [p setIsPositioned:YES];
                
            } else if (p.userInteractionEnabled) {
                
                [self.view bringSubviewToFront:p];
                [self.view bringSubviewToFront:p.group];
            }
            
        }
        
        group.userInteractionEnabled = NO;
        
    }
    
}

- (void)updateGroupDB:(GroupView*)group{
        
    for (PieceView *piece in group.pieces) {
        
        //Update piece in the DB
        Piece *pieceDB = [self pieceOfCurrentPuzzleDB:piece.number];
        pieceDB.position = [NSNumber numberWithInt:piece.position];
        pieceDB.angle = [NSNumber numberWithFloat:piece.angle];
        
        //NSLog(@"Position of piece #%d is %d", pieceDB.number.intValue, pieceDB.position.intValue);
    }

    [self saveGame];
    
}

- (void)checkNeighborsForAllThePieces {
    
    for (PieceView *p in pieces) {
        if (p.isFree && !p.isCompleted) {
            [self checkNeighborsOfPieceNumber:p];
        }
    }
        
    //Add lonely pieces to groups (create one if it doesn't exist)
    for (PieceView *p in pieces) {
        if (p.isFree && p.hasNeighbors) {
            
            if (YES) {
                
                [self createNewGroupForPiece:p];
                
            } else {
                
                NSLog(@"Piece #%d was already grouped", p.number);
            }
        }
    }
    
    
    
    //Join different groups
    
}



#pragma mark -
#pragma mark ••••••  Pieces

- (void)pieceMoved:(PieceView *)piece {
    
    //NSLog(@"%s", __FUNCTION__);
    
    CGPoint point = piece.frame.origin;   
    
    
    if (!piece.hasNeighbors) {
        
        BOOL outOfDrawer;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            outOfDrawer = point.y>drawerSize-self.padding;
        } else {
            outOfDrawer = point.x>drawerSize-self.padding;
        }
        
        if (outOfDrawer) {
            
            
            if (!piece.isFree && ![self pieceIsOut:piece]) {
                
                piece.isFree = YES;
                
            }            
            
        } else {
            piece.isFree = NO;
            piece.position = -1;
            [self updatePieceDB:piece];
            [UIView animateWithDuration:0.5 animations:^{
                
                float scale = piceSize/piece.frame.size.width;
                piece.transform = CGAffineTransformScale(piece.transform, scale, scale);
                
            }];
        }
        
    } else {
        piece.isFree = YES;
    }
    
    
    if (piece.isFree) {
        
        if ( [self pieceIsOut:piece] ) 
        {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                for (PieceView *p in [piece allTheNeighborsBut:nil]) {
                    CGRect rect = p.frame;
                    rect.origin.x = p.oldPosition.x-p.frame.size.width/2;
                    rect.origin.y = p.oldPosition.y-p.frame.size.height/2;
                    p.frame = rect;
                    //NSLog(@"Reset the old position (%.1f, %.1f) for piece #%d", p.oldPosition.x, p.oldPosition.y, p.number);
                    p.position = [self positionOfPiece:p];
                }
                CGRect rect = piece.frame;
                rect.origin.x = piece.oldPosition.x-piece.frame.size.width/2;
                rect.origin.y = piece.oldPosition.y-piece.frame.size.height/2;
                piece.frame = rect;                
                //NSLog(@"BOSS - Reset the old position (%.1f, %.1f) for piece #%d", piece.oldPosition.x, piece.oldPosition.y, piece.number);
                piece.position = [self positionOfPiece:piece]; 
            }];
            
        } else {
            
            for (int i=N-1; i>-1; i--) {
                
                
                //NSLog(@"v origin = %.1f, %.1f - [piece realCenter] = %.1f, %.1f", frame.origin.x, frame.origin.y, [piece realCenter].x, [piece realCenter].y);
                
                CGRect frame = [self frameOfLatticePiece:i];
                if ([self piece:piece isInFrame:frame]) {
                    
                    [self movePiece:piece toLatticePoint:i animated:YES];
                    
                    break;
                }
            }
        }
        
        
        
    }
    
    piece.isLifted = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
    }];
    
    [self bringDrawerToTop];
    
    piece.oldPosition = [piece realCenter];
    
    
    if (panningSwitch.isOn && piece.isFree) {
        piece.userInteractionEnabled = NO;
    }
    
    
    
    //NSLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);
    
}

- (int)positionOfPiece:(PieceView*)piece {
    
    
    for (int i=N-1; i>-1; i--) {
        
        CGRect frame = [self frameOfLatticePiece:i];
        
        if ([self piece:piece isInFrame:frame]) {
            
            //NSLog(@"-> Returning position %d",i);
            return i;
        }
    }
    
    //NSLog(@"-> \nReturning position -1");    
    return -1;
}

- (void)pieceRotated:(PieceView *)piece {
    
    //NSLog(@"Piece rotated! Angle = %.1f", piece.angle);
    
    if (piece.group==nil) {
        
        for (PieceView *p in [piece allTheNeighborsBut:nil]) {
            p.oldPosition = [p realCenter];
            p.position = [self positionOfPiece:p];
        }
        piece.oldPosition = [piece realCenter];
        piece.position = [self positionOfPiece:piece];

        [self isPositioned:piece];

    } else { //In a group
        
        for (PieceView *p in piece.group.pieces) {
            
            p.angle = piece.angle;

        }

        [self updatePositionsInGroup:piece.group withReferencePiece:piece];
    }
    
    
    //NSLog(@"Position for piece #%d is %d", piece.number, piece.position);
    //NSLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);
    
    if (piece.group) {
        
        [self checkNeighborsForAllThePieces];
        
    } else {
        
        [self checkNeighborsOfPieceNumber:piece];
    }
    
    [self updatePieceDB:piece];
    [self updatePercentage];
    [self bringDrawerToTop];
    
}

- (PieceView*)pieceAtPosition:(int)j {
    
    for (PieceView *p in pieces) {
        
        if (p.position == j) {
            
            //NSLog(@"Piece at position %d is #%d", j, p.number);
            return p;
        }
    }
    
    return nil;
}

- (BOOL)shouldCheckNeighborsOfPiece:(PieceView*)piece inDirection:(int)r {
    
    if (piece.position!=0) {
        
        if (r==2 && (piece.position+1)%pieceNumber==0) {
            //NSLog(@"bottom piece (#%d) checking down", piece.number);
            return NO;
        }
        if ( r==0 && (piece.position)%pieceNumber==0) {
            //NSLog(@"top piece (#%d) checking up", piece.number);
            return NO;
        }
        if (r==3 && (piece.position)/pieceNumber==pieceNumber-1) {
            //NSLog(@"right piece (#%d) checking right", piece.number);
            return NO;
        }
        if (r==1 && (piece.position)/pieceNumber==0) {
            //NSLog(@"left piece (#%d) checking left", piece.number);
            return NO;
        }
        
        return YES;
        
    } else {
        return (r==1 || r==2);
    }
    
}

- (void)checkNeighborsOfPieceNumber:(PieceView*)piece {
    
    int rotation = floor(piece.angle/(M_PI/2));
    rotation = rotation%4;    
    
    NSArray *a = [NSArray arrayWithObjects:
                  [NSNumber numberWithInt:-1],              //up = 0
                  [NSNumber numberWithInt:+pieceNumber],    //right = 1
                  [NSNumber numberWithInt:1],               //down = 2
                  [NSNumber numberWithInt:-pieceNumber],    //left = 3
                  nil];
    
    PieceView *otherPiece;
    int j = piece.position;
    
    if (j==-1) {
        return;
    }
    
    
    for (int direction=0; direction<4; direction++) {
        
        int r = (direction+rotation)%4;
        
        int i = [[a objectAtIndex:r] intValue];
        int l = [[a objectAtIndex:direction] intValue];
                
        
        //Looks for neighbors       
        
        if (j+i>=0 && j+i<N && [self shouldCheckNeighborsOfPiece:piece inDirection:r] )
        {
            
            otherPiece = [self pieceAtPosition:j+i];
            
            //NSLog(@"j+i = %d ; numbers are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d",j+i, piece.number+l, otherPiece.number,  piece.number, otherPiece.number, direction, rotation, r);    
            
            //NSLog(@"Checking position %d, number+l = %d, otherPiece.number = %d", piece.number+i, piece.number+l, otherPiece.number);
            
            if (otherPiece != nil) {
                
                if (piece.isFree && otherPiece.isFree) {
                    
                    //NSLog(@"Angles are %.1f (piece) and %.1f (other)", piece.angle, otherPiece.angle);
                    
                    
                    if (piece.number+l==otherPiece.number) {
                        
                        
                        if ((ABS(piece.angle-otherPiece.angle)<M_PI/4)) {
                            
                            if ([[piece.neighbors objectAtIndex:direction%4] intValue]!=otherPiece.number) {
                                
                                [otherPiece setNeighborNumber:piece.number forEdge:(direction+2)%4];
                                [piece setNeighborNumber:otherPiece.number forEdge:direction%4];
                                
                                piece.hasNeighbors = YES;
                                otherPiece.hasNeighbors = YES;
                            }
                            
                        } else {
                            //NSLog(@"0 -------> Wrong angles. They are %.1f and %.1f for pieces #%d and #%d", piece.angle, otherPiece.angle, piece.number, otherPiece.number);
                        }
                    } else {
                        //NSLog(@"-------> Wrong numbers. They are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d", piece.number+l, otherPiece.number, piece.number, otherPiece.number, direction, rotation, r);
                        
                    }
                }
                
            }else {
                
                //NSLog(@"NIL");
                
            }
            
        } else {
            //NSLog(@"Shouldn't check");
        }
        
    }
    
    //NSLog(@"\n");
    
}

- (BOOL)isPositioned:(PieceView*)piece  {
    
    if (piece.isFree && piece.number == piece.position && ABS(piece.angle) < 1) {
        
        //NSLog(@"Piece #%d positioned!", piece.number);
        //Flashes and block the piece
        if (!piece.isPositioned) {
            [piece setIsPositioned:YES];
            
            for (PieceView *p in pieces) {
                if (p.isFree && p!=piece && !p.isPositioned) {
                    
                    [self.view bringSubviewToFront:p];
                    [self.view bringSubviewToFront:p.group];
                }
            }

            
            if (![self isPuzzleComplete] && !loadingGame) {
               
                [piece pulse];
                
                if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
                    [positionedSound play];
                }
            }
        }        
        return YES;
    }
    return NO;
}

- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated {
    
    //NSLog(@"Moving piece #%d to position %d", piece.number, i);
    
    piece.position = i;
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            piece.center = [self centerOfLatticePiece:i];
            CGAffineTransform trans = CGAffineTransformMakeScale(lattice.scale, lattice.scale);
            piece.transform = CGAffineTransformRotate(trans, piece.angle);
            
        }completion:^(BOOL finished) {
            
            if (!piece.isPositioned) {
                [self isPositioned:piece];
            }
            [self checkNeighborsForAllThePieces];
            [self updatePercentage];
            [self updatePieceDB:piece];
        }];
        
    } else {
        
        piece.center = [self centerOfLatticePiece:i];
        CGAffineTransform trans = CGAffineTransformMakeScale(lattice.scale, lattice.scale);
        piece.transform = CGAffineTransformRotate(trans, piece.angle);

        if (!piece.isPositioned) {
            [self isPositioned:piece];
        }
        
    }
        
    piece.oldPosition = [piece realCenter];
    
}

- (BOOL)piece:(PieceView*)piece isInFrame:(CGRect)frame {
    
    return frame.origin.x<[piece realCenter].x && frame.origin.y<[piece realCenter].y;
}

- (BOOL)point:(CGPoint)point isInFrame:(CGRect)frame {
    
    //NSLog(@"Point = %.1f, %.1f", point.x, point.y);
    
    return (frame.origin.x<point.x && 
            frame.origin.y<point.y &&
            frame.origin.x+frame.size.width>point.x &&
            frame.origin.y+frame.size.height>point.y
            );
}

- (void)updatePieceDB:(PieceView*)piece {
    
    //Update piece in the DB
    Piece *pieceDB = [self pieceOfCurrentPuzzleDB:piece.number];
    pieceDB.position = [NSNumber numberWithInt:piece.position];
    pieceDB.angle = [NSNumber numberWithFloat:piece.angle];
    pieceDB.isFree = (BOOL)piece.isFree;
    
    pieceDB.edge0 = [piece.edges objectAtIndex:0];
    pieceDB.edge1 = [piece.edges objectAtIndex:1];
    pieceDB.edge2 = [piece.edges objectAtIndex:2];
    pieceDB.edge3 = [piece.edges objectAtIndex:3];
    
    [self saveGame];
    
}

- (CGPoint)coordinatesOfPiece:(PieceView*)piece relativeToPiece:(PieceView*)boss {
    
//    NSLog(@"relative = (%.0f, %.0f), boss.number = %d, piece.number = %d, ", 
//          (float)((piece.number%pieceNumber-boss.number%pieceNumber)%pieceNumber), 
//          (float)(piece.number/pieceNumber-boss.number/pieceNumber),
//          boss.number,
//          piece.number);

    return CGPointMake(
                       (float)((piece.number%pieceNumber-boss.number%pieceNumber)%pieceNumber), 
                       (float)(piece.number/pieceNumber-boss.number/pieceNumber)
                       );
        
}



#pragma mark -
#pragma mark ••••••  Lattice

- (void)createLattice {
    
    [lattice removeFromSuperview];
    
    
    float w = (piceSize-2*self.padding)*pieceNumber;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    //Center the lattice
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        rect = CGRectMake((rect.size.height-w)/2+drawerSize/2, (rect.size.width-w)/2, w, w);
        
    } else {
        
        rect = CGRectMake((rect.size.width-w)/2, (rect.size.height-w)/2+drawerSize/2, w, w);
        
    }
    
    lattice = [[Lattice alloc] init];
    [lattice initWithFrame:rect withNumber:pieceNumber withDelegate:self];
    lattice.frame = [self frameForLatticeWithOrientation:self.interfaceOrientation];
    
    //float optimalPiceSize = PUZZLE_SIZE*rect.size.width/(pieceNumber)+2*self.padding;
    lattice.scale = 1; //optimalPiceSize/piceSize;
    //[self resizeLattice];
    
    [self.view addSubview:lattice];
    
    [self.view bringSubviewToFront:menuButtonView];
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:menu.obscuringView];
    [self.view bringSubviewToFront:menu.view];
    
    
    //Add the image to lattice
    imageViewLattice.image = image;
    imageViewLattice.frame = CGRectMake(0 ,0, pieceNumber*lattice.scale*(piceSize-2*self.padding), pieceNumber*lattice.scale*(piceSize-2*self.padding));
    imageViewLattice.alpha = 0;
    [lattice addSubview:imageViewLattice];
    
    
    //NSLog(@"Lattice created");
    
}

- (void)resizeLatticeWithCenter:(CGPoint)center {
    
    float z = lattice.scale;
    lattice.contentScaleFactor = z;
    
    float w = (piceSize-2*self.padding)*pieceNumber*lattice.scale;
    
    CGPoint latticeCenter = CGPointMake(lattice.frame.origin.x+0.5*w, 
                                        lattice.frame.origin.y+0.5*w);
    
    NSLog(@"Lattice center = %.1f, %.1f", latticeCenter.x, latticeCenter.y);
    
    CGPoint translation = CGPointMake(latticeCenter.x-center.x, latticeCenter.y-center.y);
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
    transform = CGAffineTransformScale(transform, z, z);
    transform = CGAffineTransformTranslate(transform, -translation.x, -translation.y);
    
    lattice.transform = transform;
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(center.x, center.y, 10, 10)];
    UIView *originView = [[UIView alloc] initWithFrame:CGRectMake(lattice.center.x, lattice.center.y, 10, 10)];
    centerView.backgroundColor = [UIColor blueColor];
    originView.backgroundColor = [UIColor redColor];
    [lattice addSubview:centerView];
    [self.view addSubview:originView];
    
}

- (CGRect)frameOfLatticePiece:(int)i {
    
    if (0<=i && i<N) {
        UIView *v = [lattice objectAtIndex:i];
        return CGRectMake(
                          lattice.frame.origin.x + lattice.scale*(v.frame.origin.x-self.padding)-1*lattice.scale,
                          lattice.frame.origin.y + lattice.scale*(v.frame.origin.y-self.padding)-1*lattice.scale, 
                          lattice.scale*piceSize, 
                          lattice.scale*piceSize);
    } else {
        
        return CGRectZero;
    }
    
}

- (CGPoint)centerOfLatticePiece:(int)i {
    
//    UIView *v = [lattice objectAtIndex:i];
//    return [lattice.superview convertPoint:v.center fromView:lattice];


    CGRect rect = [self frameOfLatticePiece:i];
    return CGPointMake(rect.origin.x+lattice.scale*piceSize/2.0, rect.origin.y+lattice.scale*piceSize/2.0);
    
}



#pragma mark -
#pragma mark ••••••  Drawer

- (void)organizeDrawerWithOrientation:(UIImageOrientation)orientation {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:pieces];
    
    if ([temp count] == 0) {
        return;
    }
    
    
    //Removes removed pieces
    for (int i=0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        if (p.isFree || p.isLifted) {
            [temp removeObject:p];
        }
    }
    
    
    if ((drawerFirstPoint.x==0 && drawerFirstPoint.y==0) ){//|| removed) {
        
        drawerFirstPoint.x = [[temp objectAtIndex:0] frame].origin.x;
        drawerFirstPoint.y = [[temp objectAtIndex:0] frame].origin.y;
        //NSLog(@"FirstPoint = %.1f, %.1f", drawerView.frame.origin.x, drawerView.frame.origin.y);

    }
    

    //[UIView animateWithDuration:ORG_TIME animations:^{
        
        for (int i=0; i<[temp count]; i++) {
            
            PieceView *p = [temp objectAtIndex:i];
            
            CGRect rect = p.frame;
            PieceView *p2;
            
            if (i>0) {
                p2 = [temp objectAtIndex:i-1];
                CGRect rect2 = p2.frame;
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    rect.origin.y = rect2.origin.y+rect2.size.width+drawerMargin;
                    rect.origin.x = (self.padding*0.75)/2;
                } else {
                    rect.origin.x = rect2.origin.x+rect2.size.width+drawerMargin;
                    rect.origin.y = (self.padding*0.75)/2;
                }
                
            } else {
                
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    rect.origin.y = drawerFirstPoint.y+drawerMargin;
                    rect.origin.x = (self.padding*0.75)/2;
                } else {
                    rect.origin.x = drawerFirstPoint.x+drawerMargin;
                    rect.origin.y = (self.padding*0.75)/2;
                }
                
                //NSLog(@"FirstPoint was %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);

            }

            if (!didRotate && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                rect.origin.y += 20;
            }
            
            p.frame = rect;

        }
    //}];
    
    
    
}

- (void)panDrawer:(UIPanGestureRecognizer*)gesture {
    
    if (menu.view.alpha == 0) {

        if ([self numberOfPiecesInDrawerAtTheMoment]<=numberOfPiecesInDrawer) {
            
            drawerFirstPoint = CGPointMake(-self.padding/2+10, -self.padding/2+10);
            [UIView animateWithDuration:0.5 animations:^{
                [self organizeDrawerWithOrientation:self.interfaceOrientation];
            }];
            return;
        }
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            
            if ([gesture velocityInView:self.view].y<0) {
            
                if ([self lastPieceInDrawer].frame.origin.y<[[UIScreen mainScreen] bounds].size.width-piceSize) {

                    [self moveNegativePieces];
                }

            } else {
                
                if ([self firstPieceInDrawer].frame.origin.y>0) {

                    [self movePositivePieces];
                }

            }
            
#define PANNING_SPEED 0.06
            
            if (ABS(traslation.x>0.01) || ABS(traslation.y) > 0.01) {
                
                for (PieceView *p in pieces) {
                    if (!p.isFree) {
                        
                        CGRect frame = p.frame;
                        frame.origin.y += [gesture velocityInView:self.view].y*PANNING_SPEED;
                        p.frame = frame;
                    }
                }                
                drawerFirstPoint.y += [gesture velocityInView:self.view].y*PANNING_SPEED;
                [gesture setTranslation:CGPointMake(traslation.x, 0) inView:lattice.superview];                
            }
            
            
        } else {
            
            if ([gesture velocityInView:self.view].x<0) {
                
                if ([self lastPieceInDrawer].frame.origin.x<[[UIScreen mainScreen] bounds].size.width-piceSize) {
                    
                    [self moveNegativePieces];
                }
                
            } else {
                
                if ([self firstPieceInDrawer].frame.origin.x>0) {
                    
                    [self movePositivePieces];
                }
                
            }
            
            if (ABS(traslation.x>0.01) || ABS(traslation.y) > 0.01) {
                
                for (PieceView *p in pieces) {
                    if (!p.isFree) {
                        
                        CGRect frame = p.frame;
                        frame.origin.x += [gesture velocityInView:self.view].x*PANNING_SPEED;
                        p.frame = frame;
                    }
                }    
                drawerFirstPoint.x += [gesture velocityInView:self.view].x*PANNING_SPEED;
                [gesture setTranslation:CGPointMake(0, traslation.y) inView:lattice.superview];     
            }
        }
        
        
        //[self organizeDrawerWithOrientation:self.interfaceOrientation];
        
        PieceView *first = [self firstPieceInDrawer];
        drawerFirstPoint = first.center;
        firstPointView.center = drawerFirstPoint;
                
    }
    
}

- (int)numberOfPiecesInDrawerAtTheMoment {
    
    int i = 0;
    
    for (PieceView *p in pieces) {
        if (!p.isFree) {
            i++;
        }
    }
    
    return i;
    
}

- (PieceView*)firstPieceInDrawer {
    
    for (int i=0; i<[pieces count]; i++) {
        PieceView *p = [pieces objectAtIndex:i];
        if (!p.isFree) {
            return p;
        }
    }

    return nil;
    
}

- (PieceView*)lastPieceInDrawer {
    
    for (int i=[pieces count]-1; i>-1; i--) {
        PieceView *p = [pieces objectAtIndex:i];
        if (!p.isFree) {
            return p;
        }
    }
    
    return nil;
    
}

- (CGRect)frameUnderPiece:(PieceView*)piece {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        return CGRectMake((self.padding*0.75)/2, 
                          piece.frame.origin.y+piceSize+drawerMargin, 
                          piece.frame.size.width, 
                          piece.frame.size.height);
    } else {
        
        return CGRectMake(piece.frame.origin.x+piceSize+drawerMargin,
                          (self.padding*0.75)/2,
                          piece.frame.size.width, 
                          piece.frame.size.height);
    }    
}

- (CGRect)frameOverPiece:(PieceView*)piece {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        return CGRectMake((self.padding*0.75)/2, 
                          piece.frame.origin.y-piceSize-drawerMargin, 
                          piece.frame.size.width, 
                          piece.frame.size.height);
    } else {
        
        return CGRectMake(piece.frame.origin.x-piceSize-drawerMargin,
                          (self.padding*0.75)/2,
                          piece.frame.size.width, 
                          piece.frame.size.height);
    }
}

- (void)moveNegativePieces {
    
    PieceView *swap = [self firstPieceInDrawer];
    [pieces removeObject:swap];
    swap.frame = [self frameUnderPiece:[self lastPieceInDrawer]];
    [pieces addObject:swap];
    
    return;
    
}

- (void)movePositivePieces {
    
    if ([self numberOfPiecesInDrawerAtTheMoment]<numberOfPiecesInDrawer) {
        return;
    }
        
    PieceView *swap = [self lastPieceInDrawer];
    [pieces removeObject:swap];
    swap.frame = [self frameOverPiece:[self firstPieceInDrawer]];
    [pieces insertObject:swap atIndex:0];
    
    return;
    
}

- (IBAction)scrollDrawerRight:(id)sender {
    
    [self swipeInDirection:UISwipeGestureRecognizerDirectionRight];
    
    
}

- (IBAction)scrollDrawerLeft:(id)sender {
    
    [self swipeInDirection:UISwipeGestureRecognizerDirectionLeft];
        
}

- (void)swipeInDirection:(UISwipeGestureRecognizerDirection)direction {
    
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:pieces];
    for (PieceView *p in pieces) {
        if (p.isFree) {
            [temp removeObject:p];
        }
    }
    
    
    int sgn = 1;
    if (direction==UISwipeGestureRecognizerDirectionLeft) {
        sgn *= -1;
    }
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float traslation = screenWidth-drawerMargin;
    
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        if (direction==UISwipeGestureRecognizerDirectionRight && drawerFirstPoint.y>=-piceSize) {
            return;
        }
        
        PieceView *p = [temp lastObject];
        if (
            direction==UISwipeGestureRecognizerDirectionLeft && 
            p.frame.origin.y<screenWidth-p.frame.size.height+self.padding
            ) {
            return;
        }
        
        if (!swiping) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                swiping = YES;
                
                drawerFirstPoint.y += sgn*(traslation);
                [UIView animateWithDuration:0.5 animations:^{
                    [self organizeDrawerWithOrientation:self.interfaceOrientation];
                }];                //NSLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
            }completion:^(BOOL finished){
                
                swiping = NO;
                
            }];
            
        }
        
    } else {
        
        if (direction==UISwipeGestureRecognizerDirectionRight && drawerFirstPoint.x>=-piceSize) {
            return;
        }
        
        PieceView *p = [temp lastObject];
        if (direction==UISwipeGestureRecognizerDirectionLeft && p.frame.origin.x<screenWidth-p.frame.size.width+self.padding) {
            return;
        }
        
        if (!swiping) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                swiping = YES;
                
                drawerFirstPoint.x += sgn*traslation;
                [UIView animateWithDuration:0.5 animations:^{
                    [self organizeDrawerWithOrientation:self.interfaceOrientation];
                }];
                
                //NSLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
            }completion:^(BOOL finished){
                
                swiping = NO;
                
            }];
            
        }
    }
    
}

- (void)swipeR:(UISwipeGestureRecognizer*)swipe {
    
    if (menu.view.alpha == 0) {
        [self swipeInDirection:UISwipeGestureRecognizerDirectionRight];
    }
    
}

- (void)swipeL:(UISwipeGestureRecognizer*)swipe {

    if (menu.view.alpha == 0) {
        [self swipeInDirection:UISwipeGestureRecognizerDirectionLeft];
    }
}




#pragma mark -
#pragma mark ••••••  Tools

- (IBAction)togglePanningMode:(id)sender {
    
    if (panningSwitch.isOn) {
        for (PieceView *p in pieces) {
            if (p.isFree) {
                p.userInteractionEnabled = NO;
            }
        }
        
    } else {
        
        for (PieceView *p in pieces) {
            if (p.isFree && !p.isPositioned) {
                p.userInteractionEnabled = YES;
            }
        }
    }    
}

- (void)refreshPositions {
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.position>-1 && p.group==nil) {
            [self movePiece:p toLatticePoint:p.position animated:NO];
        }
    }
    
    for (GroupView *g in groups) {
        [self moveGroup:g toLatticePoint:g.boss.position animated:NO];
    }
}

- (void)loadSounds {
    
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"PiecePositioned" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    positionedSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    positionedSound.volume = 0.3;
    
    if ([positionedSound respondsToSelector:@selector(setEnableRate:)]) {
        positionedSound.enableRate = YES;
        positionedSound.rate = 1.5; 
    }
    
    soundPath =[[NSBundle mainBundle] pathForResource:@"PuzzleCompleted" ofType:@"wav"];
    soundURL = [NSURL fileURLWithPath:soundPath];
    completedSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    
}

- (BOOL)saveGame {
    
    if (puzzleDB==nil) {
        
        NSLog(@"PuzzleDB is nil");
        [self createPuzzleInDB];
    }
    
    puzzleDB.lastSaved = [NSDate date];
    
    if ([managedObjectContext save:nil]) {
        //NSLog(@"Puzzle saved");
    }
    
    return YES;
    
}

- (UIImage*)clipImage:(UIImage*)img toRect:(CGRect)rect {
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return newImage;
    
}

- (CGPoint)applyMatrix:(CGAffineTransform)matrix toVector:(CGPoint)vector {
    
    return CGPointMake(matrix.a*vector.x+matrix.b*vector.y, matrix.c*vector.x+matrix.d*vector.y);
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    anchorPoint = CGPointMake(anchorPoint.x / lattice.bounds.size.width, anchorPoint.y / lattice.bounds.size.height);
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint pos = view.layer.position;
    
    pos.x -= oldPoint.x;
    pos.x += newPoint.x;
    
    pos.y -= oldPoint.y;
    pos.y += newPoint.y;
    
    view.layer.position = pos;
    view.layer.anchorPoint = anchorPoint;
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIView *piece = gestureRecognizer.view;
        //Change this!!!
        piece = lattice;
        
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)resetSizeOfAllThePieces {
    
    CGRect rect;
    
    for (PieceView *p in pieces) {
        
        rect = p.frame;
        rect.size.width = piceSize;
        rect.size.height = piceSize;
        p.frame = rect;
    }
}

- (void)refreshPieces {
    
    NSLog(@"Pieces refreshed");
}

- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
    
    
    for (int i=0; i<N; i++) {          
        PieceView *p = [pieces objectAtIndex:i];            
        CGRect rect = p.frame;
        rect.origin.x = piceSize*i+drawerMargin;
        rect.origin.y = 5;
        p.frame = rect;
        
        int r = arc4random_uniform(4);
        p.transform = CGAffineTransformMakeRotation(r*M_PI/2);
        p.angle = r*M_PI/2;
        //NSLog(@"angle=%.1f", p.angle);
    }
    
}

- (void)computePieceSize {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        piceSize = 180;
        
    }else{  
        
        piceSize = 100;
        
    }
    
    self.padding = piceSize*0.15;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        drawerSize = piceSize+1.8*self.padding-15;   
    else   
        drawerSize = piceSize+1.8*self.padding-15;
    
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    numberOfPiecesInDrawer = screenWidth/(piceSize+1);
    float unusedSpace = screenWidth - numberOfPiecesInDrawer*piceSize;
    drawerMargin = (float)(unusedSpace/(numberOfPiecesInDrawer+1));
    
    //NSLog(@"n = %d, %.1f", n, drawerMargin);
    
    
}

- (void)bringDrawerToTop {
    
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:stepperDrawer];

    for (PieceView *p in pieces) {
        if (!p.isFree) {
            [self.view bringSubviewToFront:p];
        }
    }
    [self.view bringSubviewToFront:HUDView];
    [self.view bringSubviewToFront:firstPointView];

    
}

- (void)updatePercentage {
    
    puzzleDB.percentage = [NSNumber numberWithFloat:[self completedPercentage]];
    percentageLabel.text = [NSString stringWithFormat:@"%.0f %%", [self completedPercentage]];
}

- (NSMutableArray*)shuffleArray:(NSMutableArray*)array {
        
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [array exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    for (int i=0; i<[array count]; i++) {
        
        [[array objectAtIndex:i] setPositionInDrawer:i];
        
    }
    
    return array;
}

- (Piece*)pieceOfCurrentPuzzleDB:(int)n {
    
    for (Piece *p in puzzleDB.pieces) {
        if ([p.number intValue]==n) {
            return p;
        }
    }
    
    NSLog(@"------>  Piece #%d is NIL!", n);
    
    missedPieces++;
    
    return nil;
    
}

- (void)removeOldPieces {
    
    for (int i = 0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        [p removeFromSuperview];    
        p = nil;
    }
    
    
    //pieces = nil;
    
}

- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

-(void)print_free_memory {
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used/ 100000, mem_free/ 100000, mem_total/ 100000);
}

+ (float)float:(float)f modulo:(float)m {

    float result = f - floor((f)/m)*m;

    if (result>m-0.2) result = 0;

    if (result<0) result = 0;
    
    return result;

}



#pragma mark -
#pragma mark ••••••  Rest


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            //NSLog(@"Shuffle!");
            //[self shuffle];
            
        }];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (PieceView*)pieceWithNumber:(int)j {
    
    for (PieceView *p in pieces) {
        if (p.number==j) {
            return p;
        }
    }
    
    return nil;
}

- (PieceView*)pieceWithPosition:(int)j {
    
    for (PieceView *p in pieces) {
        if (p.position==j) {
            return p;
        }
    }
    
    return nil;
}

- (BOOL)pieceIsOut:(PieceView *)piece {
    
    CGRect frame1 = [self frameOfLatticePiece:0];
    CGRect frame2 = [self frameOfLatticePiece:N-1];
    
    
    if ([piece realCenter].x > frame2.origin.x+frame2.size.width ||
        [piece realCenter].y > frame2.origin.y+frame2.size.width ||
        [piece realCenter].x < frame1.origin.x ||
        [piece realCenter].y < frame1.origin.y
        )
    {
        NSLog(@"Piece is #%d out, N= %.1f", piece.number, N);
        return YES;
    }
    
    for (PieceView *p in [piece allTheNeighborsBut:nil]) {
        
        if ([p realCenter].x > frame2.origin.x+frame2.size.width ||
            [p realCenter].y > frame2.origin.y+frame2.size.width ||
            [p realCenter].x < frame1.origin.x ||
            [p realCenter].y < frame1.origin.y
            )        {
            NSLog(@"Piece is #%d out, N= %.1f (neighbor)", piece.number, N);
            return YES;
        }
    }
    
    //NSLog(@"IN");
    
    return NO;
}

- (IBAction)restartPuzzle:(id)sender {
    
    [self createPuzzleFromImage:image];
    
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    //NSLog(@"Scaling Image to size %.1f", newSize.width);
    
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {       
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        return YES;
        
    } else {  
        
        return (interfaceOrientation==UIInterfaceOrientationPortrait);
        
    }
    
    
}

- (CGRect)frameForLatticeWithOrientation:(UIInterfaceOrientation)orientation {
    
    float w = (piceSize-2*self.padding)*pieceNumber;
    
    CGRect latticeRect = [[UIScreen mainScreen] bounds];
        
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        latticeRect = CGRectMake((latticeRect.size.height-w)/2+drawerSize/2, (latticeRect.size.width-w)/2, w, w);
        
    } else {
        
        latticeRect = CGRectMake((latticeRect.size.width-w)/2, (latticeRect.size.height-w)/2+drawerSize/2, w, w);
        
    }
            
    return latticeRect;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    
    
    //Rotate the drawer
    
    CGRect rect = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    CGRect imageFrame = imageView.frame;
    
    float width = [[UIScreen mainScreen] bounds].size.width;
    
 
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && !UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                
        drawerFirstPoint = CGPointMake(5, drawerFirstPoint.x);
        
        rect.size.width = drawerSize;
        rect.size.height = width;
        stepperFrame.origin.y = rect.size.height - stepperFrame.size.height-30;
        stepperFrame.origin.x = rect.size.width;
        float pad = ([[UIScreen mainScreen] bounds].size.height - imageFrame.size.width)/1;
        imageFrame.origin.x = pad;
        imageFrame.origin.y = 0;
        
        panningSwitch.center = CGPointMake(panningSwitch.center.x+drawerSize, panningSwitch.center.y);
        
        lattice.frame = CGRectMake(lattice.frame.origin.y, lattice.frame.origin.x, lattice.bounds.size.width, lattice.bounds.size.height);
                
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && !UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, 5);
        
        rect.size.height = drawerSize;
        rect.size.width = width;
        stepperFrame.origin.y = rect.size.height;
        stepperFrame.origin.x = rect.size.width - stepperFrame.size.width-10;
        float pad = ([[UIScreen mainScreen] bounds].size.height - imageFrame.size.height)/1;
        imageFrame.origin.y = pad;
        imageFrame.origin.x = 0;
        
        panningSwitch.center = CGPointMake(panningSwitch.center.x-drawerSize, panningSwitch.center.y);
        
        lattice.frame = CGRectMake(lattice.frame.origin.y, lattice.frame.origin.x, lattice.bounds.size.width, lattice.bounds.size.height);

    }
    
    
    [self refreshPositions];

    
    if (!receivedFirstTouch) {
        
        [UIView animateWithDuration:duration animations:^{

            lattice.frame = [self frameForLatticeWithOrientation:toInterfaceOrientation];
            
        }];
        
    }
    
    
    
    
    [UIView animateWithDuration:duration animations:^{
        
        drawerView.frame = rect;
        stepperDrawer.frame = stepperFrame;
        imageView.frame = imageFrame;

    }];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self organizeDrawerWithOrientation:toInterfaceOrientation];
    }];    
    //NSLog(@"FirstPoint = %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);

    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    
    didRotate = YES;
    

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    receivedFirstTouch = YES;
        
    if(imageView.alpha == 1) {
        [self toggleImageWithDuration:0.5];
    }
}

- (void)oneSecondElapsed {
    
    elapsedTime += 0.1;
    puzzleDB.elapsedTime = [NSNumber numberWithFloat:elapsedTime];
    
    
    int seconds = (int)elapsedTime%60;
    int minutes = (int)elapsedTime/60;
    
            
    if (elapsedTime - (int)elapsedTime < 0.1) {

        elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]; 
    }    
    
    //NSLog(@"%d, %f", (int)elapsedTime, elapsedTime);
    
}

- (void)startTimer {
     
    if (!loadingFailed && ![self isPuzzleComplete]) {
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(oneSecondElapsed) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer {
    
    [timer invalidate];
    
}

- (void)startNewGame {

    elapsedTime = 0.0;
    puzzleCompete = NO;

    for (UIView *v in groups) {
        [v removeFromSuperview];
    }
    
    for (PieceView *p in pieces) {
        [p removeFromSuperview];
    }
    
    groups = [[NSMutableArray alloc] initWithCapacity:N/2];
    pieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    
    [self createPuzzleFromImage:image];
    
    receivedFirstTouch = NO;    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        lattice.frame = [self frameForLatticeWithOrientation:self.interfaceOrientation];
        
    }];
    
}

- (void)setPieceNumber:(int)pieceNumber_ {
    
    pieceNumber = pieceNumber_;
    N = pieceNumber*pieceNumber;

}

- (float)completedPercentage {
        
    float positioned = 0.0;
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.isPositioned) {
            positioned += 1.0;
        }
    }
    
    return (positioned/N*100);
    
}

- (void)createPuzzleInDB {
    
    self.view.userInteractionEnabled = NO;
    
    NSLog(@"Starting creating puzzle in the DB");
    
    puzzleDB = [self newPuzzleInCOntext:managedObjectContext];
    Image *imageDB = [self newImageInCOntext:managedObjectContext];
    imageDB.data = UIImageJPEGRepresentation(image, 1);
    puzzleDB.image = imageDB;
    puzzleDB.pieceNumber = [NSNumber numberWithInt:pieceNumber];
    
    for (PieceView *piece in pieces) {
        
        //Creating the piece in the database
        Piece *pieceDB = [self newPieceInCOntext:managedObjectContext];
        pieceDB.puzzle = puzzleDB;
        pieceDB.number = [NSNumber numberWithInt:piece.number];
        pieceDB.position = [NSNumber numberWithInt:piece.position];
        pieceDB.angle = [NSNumber numberWithFloat:piece.angle];
        Image *imagePieceDB = [self newImageInCOntext:managedObjectContext];
        imagePieceDB.data = UIImageJPEGRepresentation(piece.image, 0.5);
        pieceDB.image = imagePieceDB;
        
        pieceDB.edge0 = [piece.edges objectAtIndex:0];
        pieceDB.edge1 = [piece.edges objectAtIndex:1];
        pieceDB.edge2 = [piece.edges objectAtIndex:2];
        pieceDB.edge3 = [piece.edges objectAtIndex:3];
        
    }

    self.view.userInteractionEnabled = YES;
   
    
}

-(Puzzle*)newPuzzleInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Puzzle" 
            inManagedObjectContext:context];
}

-(Image*)newImageInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Image" 
            inManagedObjectContext:context];
}

-(Piece*)newPieceInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Piece" 
            inManagedObjectContext:context];
}



- (IBAction)rateGame {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (![prefs boolForKey:@"Reviewed"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Give your opinion" message:@"Would you like to rate this game?" delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Sure!", nil];
        [alertView show];
        
    } else {
        
        NSLog(@"Already rated");
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:YES forKey:@"Reviewed"];
        
     
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", APP_STORE_APP_ID];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        
    }
    
}



@end
