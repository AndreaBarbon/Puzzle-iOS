//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#define PIECE_NUMBER 4
#define ORG_TIME 0.5


#define IMAGE_SIZE_BOUND_IPAD 2*PIECE_SIZE_IPAD
#define IMAGE_SIZE_BOUND_IPHONE 3*PIECE_SIZE_IPHONE

#define JPG_QUALITY 1
#define SHAPE_QUALITY_IPAD 1
#define SHAPE_QUALITY_IPHONE 3


#import "PuzzleController.h"
#import "AppDelegate.h"
#import "GroupView.h"
#import "LoadGameController.h"
#import "iAdViewController.h"

#import <mach/mach.h>
#import <mach/mach_host.h>


@interface PuzzleController ()

@end


@implementation PuzzleController



@synthesize pieces, image, lattice, imageView, imageViewLattice, drawerView, menuButtonView, groups, panningSwitch, puzzleCompleteImage, elapsedTimeLabel;

@synthesize puzzleOperation, operationQueue;

@synthesize managedObjectContext, persistentStoreCoordinator, puzzleDB;

@synthesize padding, pieceNumber, piceSize, elapsedTime, imageSize;

@synthesize loadedPieces, NumberSquare, missedPieces, moves, rotations, score;

@synthesize pan, panDrawer, pinch;

@synthesize drawerStopped;

@synthesize positionedSound, completedSound, neighborSound;

@synthesize puzzleCompete, loadingGame, duringGame, creatingGame;

@synthesize menu, completedController, adViewController;



#pragma mark -
#pragma mark View Lifecycle

- (void)piecesNotificationResponse:(NSNotification*)notification {
   
    //PieceView *piece = notification.object;
    //DLog(@"Piece #%d sent a notification", piece.number);
}

- (void)viewDidLoad {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(piecesNotificationResponse:) name:@"PiecesNotifications" object:nil];
    
    //DLog(@"%@", [UIFont fontNamesForFamilyName:@"Bello Pro"]);
        
    scoreLabel.font = [UIFont fontWithName:@"Bello-Pro" size:40];

    
    [super viewDidLoad];
    
    screenWidth = [[UIScreen mainScreen] bounds].size.width;
    screenHeight = [[UIScreen mainScreen] bounds].size.height;

    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
      
        self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        HUDView.frame = CGRectMake(0, 20, screenWidth, HUDView.frame.size.height);
        panningSwitch.hidden = YES;
        percentageLabel.center = CGPointMake(elapsedTimeLabel.center.x, elapsedTimeLabel.center.y + 30);
        percentageLabel.textAlignment = UITextAlignmentRight;
        
    
    } else {
        
        HUDView.frame = CGRectMake(0, -10, screenWidth, HUDView.frame.size.height);
        imageSize *= 0.5;
        panningSwitch.transform = CGAffineTransformScale(panningSwitch.transform, 0.8, 0.8);
    } 

    
    directions_numbers = [[NSArray alloc] init];    
    directions_positions = [[NSArray alloc] init];    
    
    imageSize = QUALITY;
    
//    firstPointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    firstPointView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:firstPointView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    drawerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    [self loadSounds];
    [self computePieceSize];
    
    //Add the images;    
    imageView = [[UIImageView alloc] init];
    rect = CGRectMake(0, 0, rect.size.width, rect.size.width);
    imageView.frame = rect;
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    
    imageViewLattice = [[UIImageView alloc] initWithImage:image];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        puzzleCompleteImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PuzzleComplete"]];
    } else {  
        puzzleCompleteImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PuzzleComplete_iPhone"]];
    }
    
    [self.view addSubview:puzzleCompleteImage];
    puzzleCompleteImage.alpha = 0;    
    
    
    //Resize the drawer
    CGRect drawerFrame = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    

    drawerFrame.size.height = drawerSize;
    drawerFrame.size.width = screenHeight;
    drawerFrame.origin.y = screenHeight-drawerSize;
    
    stepperFrame.origin.y = drawerFrame.size.height;
    stepperFrame.origin.x = 10;
        
    
    drawerView.frame = drawerFrame;
    stepperDrawer.frame = stepperFrame;
    
    
    //Add the menu
    menu = [[MenuController alloc] init];
    menu.delegate = self;
    menu.duringGame = NO;
    menu.view.center = self.view.center;
    [self.view addSubview:menu.view];
    
    
    //Add the puzzleCompletedController
    NSString *nibName = @"PuzzleCompletedController";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) nibName = [nibName stringByAppendingFormat:@"_iPhone"];
    completedController = [[PuzzleCompletedController alloc] initWithNibName:nibName bundle:nil];
    completedController.delegate = self;
    [self.view addSubview:completedController.view];
    completedController.view.center = CGPointMake(self.view.center.x, screenHeight-30);
    completedController.view.alpha = 0;

    
    //gesture recognizers
    [self addGestures];    

}

- (NSArray*)directionsUpdated_numbers {
    
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:-1],              //up = 0
            [NSNumber numberWithInt:+pieceNumber],    //right = 1
            [NSNumber numberWithInt:1],               //down = 2
            [NSNumber numberWithInt:-pieceNumber],    //left = 3
            nil];

}

- (NSArray*)directionsUpdated_positions {
    
    return [NSArray arrayWithObjects:
            [NSNumber numberWithInt:-1],              //up = 0
            [NSNumber numberWithInt:+3*pieceNumber],    //right = 1
            [NSNumber numberWithInt:1],               //down = 2
            [NSNumber numberWithInt:-3*pieceNumber],    //left = 3
            nil];
    
}

- (void)setup {
    
    
    pieceNumber = PIECE_NUMBER;
    NumberSquare = pieceNumber*pieceNumber;
    
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
#pragma mark Score

- (void)addPoints:(int)add {
        
    score += add;
    
    [self updateScoreLabel];
    
}

- (void)updateScoreLabel {
    
    scoreLabel.text = [NSString stringWithFormat:@"%d ", score];
}

- (int)pointsForPiece:(PieceView*)piece {
    
    int points = 1000 + 1000/piece.moves + 1000/(piece.rotations+1) + NumberSquare*1000/(int)(elapsedTime+10);
    
    DLog(@"Points:%d", points);
    
    return points;
}



#pragma mark -
#pragma mark Puzzle

- (void)showCompleteImage {
    
    [self centerCompletedImage];
    puzzleCompleteImage.transform = CGAffineTransformIdentity;
    
    
    [self.view bringSubviewToFront:puzzleCompleteImage];
    [self.view bringSubviewToFront:self.adBannerView];

    [UIView animateWithDuration:1 animations:^{
        
        puzzleCompleteImage.alpha = 1;
    }];
    
    puzzleCompleteImage.transform = CGAffineTransformScale(puzzleCompleteImage.transform, 1/1.8, 1/1.8);
    
    
    
    IF_IPHONE [self resetLatticePositionAndSizeWithDuration:1.75];
    
    [UIView beginAnimations:@"pulseAnimation" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationRepeatCount:2.5];
    [UIView setAnimationDelegate:self];
    
    puzzleCompleteImage.transform = CGAffineTransformScale(puzzleCompleteImage.transform, 1.8, 1.8);
    
    [UIView commitAnimations];
    
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

    if ([finished boolValue]) {
        
        if ([animationID isEqualToString:@"pulseAnimation"]) {
            
            float f = (screenWidth)/(pieceNumber+1)/(piceSize-2*padding);
            
            [UIView animateWithDuration:1.5 animations:^{
               
                completedController.view.alpha = 1;
            }];
            
            [UIView animateWithDuration:0.5 animations:^{
                
//                for (GroupView *g in groups) {
//                    g.alpha = 0;
//                }
//                for (PieceView *p in pieces) {
//                    if (!p.group) {
//                        p.alpha = 0;
//                    }
//                }
                
            }completion:^(BOOL finished) {
                
                [self resizeLatticeToScale:f];
                IF_IPAD [self moveLatticeToLeftWithDuration:0.5];
        
            }];
            
            float translation = 0;
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                translation = -screenWidth/2+puzzleCompleteImage.bounds.size.height/2;
            } else {
                translation = -screenHeight/2+puzzleCompleteImage.bounds.size.height/2;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                 translation += 30;   
                }
            }
            translation += 30;
            
            if (!didRotate) {
                translation +=20;
            }

            
            [UIView animateWithDuration:1 animations:^{
               
                puzzleCompleteImage.transform = CGAffineTransformMakeTranslation(0, translation);
                
            }];
        }
        
        DLog(@"Deleting");
        [self.managedObjectContext deleteObject:puzzleDB];
        DLog(@"Deleted");
    }
}

- (void)loadPuzzle:(Puzzle*)puzzleDB_ {
    
    puzzleDB = puzzleDB_;
    loadingFailed = NO;
    
    [self prepareForNewPuzzle];
    [self computePieceSize];
        
    if (puzzleDB!=nil) {
    
        [self removeOldPieces];
        [self setPieceNumber:[puzzleDB.pieceNumber intValue]];
    
        image = [UIImage imageWithData:puzzleDB.image.data];
        groups = [[NSMutableArray alloc] initWithCapacity:NumberSquare/2];
        elapsedTime = [puzzleDB.elapsedTime floatValue];
        percentageLabel.text = [NSString stringWithFormat:@"%.0f %%", [puzzleDB.percentage intValue]];
        moves = puzzleDB.moves.intValue;
        rotations = puzzleDB.rotations.intValue;
        score = puzzleDB.score.intValue;
        [self updateScoreLabel];
        
        DLog(@"Score = %d, piece number = %d, percentage = %d", score, NumberSquare, [puzzleDB.percentage intValue]);
        
        if (puzzleDB.percentage.intValue==100) {
            puzzleCompete = YES;
            [menu startNewGame:nil];
            return;
        }
        
        [self createPuzzleFromSavedGame];
        
    } else {
        
        [menu startNewGame:nil];
    }
        
}

- (IBAction)toggleMenu:(id)sender {
    
    if (sender!=nil) [menu playMenuSound];
    
    menu.duringGame = (puzzleDB!=nil);
    [self.view bringSubviewToFront:menu.obscuringView];
    [self.view bringSubviewToFront:menu.view];
    [self.view bringSubviewToFront:menuButtonView];
    [self.view bringSubviewToFront:self.adBannerView];
    
    [menu toggleMenuWithDuration:(sender!=nil)*0.5];
    
}

- (void)prepareForLoading {
        
    menu.duringGame = (puzzleDB!=nil);
    [self.view bringSubviewToFront:menu.obscuringView];
    [self.view bringSubviewToFront:menu.game.view];
    [self.view bringSubviewToFront:menuButtonView];
    menu.game.view.frame = CGRectMake(0, 0, menu.game.view.frame.size.width, menu.game.view.frame.size.height);
    menu.mainView.frame = CGRectMake(-menu.mainView.frame.size.width, 0, menu.mainView.frame.size.width, menu.mainView.frame.size.height);
    
    [menu toggleMenuWithDuration:0];
    [self.view bringSubviewToFront:self.adBannerView];

}

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)puzzleSaved:(NSNotification *)saveNotification {
        
    if (![NSThread isMainThread]) {
        
        [self performSelectorOnMainThread:@selector(puzzleSaved:) withObject:saveNotification waitUntilDone:NO];
        
    } else {

        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
    
        puzzleDB = [self lastSavedPuzzle];

    }
}

- (void)merged:(NSNotification *)saveNotification {
    
}

- (void)addPiecesToView {
    
    if ([NSThread isMainThread]) {
        
        for (PieceView *p in pieces) {
            
            [self.view addSubview:p];
            //loadedPieces++;
        }
    
    } else {
    
        [self performSelectorOnMainThread:@selector(addPiecesToView) withObject:nil waitUntilDone:NO];
    }
}

- (void)allPiecesLoaded {
    
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];   
    }
    //HUDView.frame = CGRectMake(0, 20, screenWidth, HUDView.frame.size.height);

    
    if (loadingFailed) {
        return;
    }
    
    duringGame = YES;

        
    for (PieceView *p in pieces) {
        if (!p.isFree) {
            p.frame = CGRectMake(0, 0, piceSize, piceSize);
        }
    }
    
    
    
    BOOL debugging = NO;
    
    if (debugging) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            p.isPositioned = YES;
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        [imageViewLattice removeFromSuperview];
        
    } else {
        
        

        drawerFirstPoint = CGPointMake(-4, 5);
        
        
        if (loadingGame) {
            
            pieces = [self shuffleArray:pieces];
            
            DLog(@"Name: %@", puzzleDB.name);
            
            for (PieceView *p in pieces) {
                [self isPositioned:p];
            }


            [self resetSizeOfAllThePieces];
            [self shuffleAngles];
            [self refreshPositions];
            [self organizeDrawerWithOrientation:self.interfaceOrientation];
            [self checkNeighborsForAllThePieces];
            [self updatePercentage];
            loadingGame = NO;
            DLog(@"-----------> All pieces Loaded");
            
        } else {
            
            puzzleDB = [self lastSavedPuzzle];
            DLog(@"Name: %@", puzzleDB.name);
            [self resetSizeOfAllThePieces];
            [self shuffle];
            [self updatePercentage];
            [self organizeDrawerWithOrientation:self.interfaceOrientation];
            creatingGame = NO;
            DLog(@"-----------> All pieces created");
            
        }
                
        //Create the AD
        [self.adBannerView removeFromSuperview];
        self.adBannerView = nil;
        [self createAdBannerView];
        [self bringDrawerToTop];

        
    }

    [menu.game gameStarted];
    
    DLog(@"Memory after creating:");
    [self print_free_memory];
    
    
    self.view.userInteractionEnabled = YES;

    [self resetLatticePositionAndSizeWithDuration:0.0];

    [self.view bringSubviewToFront:self.adBannerView];

}

- (void)loadingFailed {
    
    loadingFailed = YES;
    menu.duringGame = NO;
    [menu.game loadingFailed];
    [puzzleOperation cancel];
    self.view.userInteractionEnabled = YES;
    [menu toggleMenuWithDuration:0];
    
}

- (void)centerCompletedImage {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        puzzleCompleteImage.center = CGPointMake(self.view.center.y, self.view.center.x);
        
    } else {
        
        puzzleCompleteImage.center = CGPointMake(self.view.center.x, self.view.center.y);
    }
}

- (void)prepareForNewPuzzle {
    
    DLog(@"Preparing for new puzzle");    
    
    [self.view bringSubviewToFront:lattice];
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:HUDView];
    [self.view bringSubviewToFront:self.adBannerView];
    
    missedPieces = 0;
    loadedPieces = 0;

    panningSwitch.alpha = 0.5;
    drawerView.alpha = 1;
    percentageLabel.alpha = 1;
    elapsedTimeLabel.alpha = 1;
    scoreLabel.alpha = 1;

    drawerStopped = NO;
    panningMode = NO;
    duringGame = NO;
    
    puzzleCompleteImage.alpha = 0;
    completedController.view.alpha = 0;
    
    if (!loadingGame) {
        
        elapsedTime = 0.0;
        score = 0;
        scoreLabel.text = @"0 ";
    }
    
    directions_numbers = [NSArray arrayWithArray:[self directionsUpdated_numbers]];
    directions_positions = [NSArray arrayWithArray:[self directionsUpdated_positions]];
    [self computePieceSize];
    [self createLattice];
    drawerFirstPoint = CGPointMake(-4, 5);
    
    // add the importer to an operation queue for background processing (works on a separate thread)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myNotificationResponse:) name:@"GTCNotification" object:nil];
    puzzleOperation = [[CreatePuzzleOperation alloc] init];
    puzzleOperation.delegate = self;
    puzzleOperation.loadingGame = loadingGame;
    puzzleOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
        
}

- (void)myNotificationResponse:(NSNotification*)note {
    NSNumber *count = [note object];
    [self.view addSubview:[pieces objectAtIndex:count.intValue]];
    //[self performSelectorOnMainThread:@selector(updateView:) withObject:count waitUntilDone:YES];
}

- (void)updateView:(NSNumber*)count {
    
    [self.view addSubview:[pieces objectAtIndex:count.intValue]];
    
}

- (void)createPuzzleFromSavedGame {

    loadingGame = YES;
    self.view.userInteractionEnabled = NO;    
    [self prepareForNewPuzzle];

    
    menu.game.view.frame = CGRectMake(0, 0, menu.game.view.frame.size.width, menu.game.view.frame.size.height);
    
    image = [UIImage imageWithData:puzzleDB.image.data];
    
    
    imageView.image = image;
    imageViewLattice.image = image;
    
    [menu.game startLoading];
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{
        
        [self createPieces];
        
        dispatch_async(main_queue, ^{
            
            [self addAnothePieceToView];
            
        });
    });
    
}

- (void)createPuzzleFromImage:(UIImage*)image_ {
    
    loadingGame = NO;
    creatingGame = YES;
    moves = 0;
    rotations = 0;
    
    [self prepareForNewPuzzle];
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    dispatch_async(main_queue, ^{
        
        [self createPieces];
        
        dispatch_async(main_queue, ^{
            
            [self addAnothePieceToView];
            
        });
    });
       
    
}

- (void)createPieces {
    
    DLog(@"Creating pieces");
    float IMAGE_SIZE_BOUND = 0;
    float SHAPE_QUALITY = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        IMAGE_SIZE_BOUND = IMAGE_SIZE_BOUND_IPAD;
        SHAPE_QUALITY = SHAPE_QUALITY_IPAD;
        
    } else {  
        
        IMAGE_SIZE_BOUND = IMAGE_SIZE_BOUND_IPHONE;
        SHAPE_QUALITY = SHAPE_QUALITY_IPHONE;
        
    } 
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    NSMutableArray *array;
    
    if (loadingGame) {
        
        if (self.image==nil) {
            return;
        }
        
    } else {
        
        //Compute the optimal part size
        
        float partSize = image.size.width/(pieceNumber*0.7);
        
        if (partSize>IMAGE_SIZE_BOUND) {
            
            partSize = IMAGE_SIZE_BOUND;
        }
        
        //and split the big image using computed size
                
        float f = (float)(pieceNumber*partSize*0.7);
        image = [image imageCroppedToSquareWithSide:f];
        imageView.image = image;
        array = [[NSMutableArray alloc] initWithArray:[self splitImage:image partSize:partSize]];
        
    }
    
    
    if (loadingGame) {
    
        for (int i=0;i<pieceNumber;i++){
            for (int j=0;j<pieceNumber;j++){
                
                CGRect rect = CGRectMake( 0, 0, SHAPE_QUALITY*piceSize, SHAPE_QUALITY*piceSize);
                
                Piece *pieceDB = [self pieceOfCurrentPuzzleDB:j+pieceNumber*i];
                
                if (pieceDB!=nil) {
                    
                    PieceView *piece = [[PieceView alloc] initWithFrame:rect];
                    piece.delegate = self;
                    piece.image = [UIImage imageWithData:pieceDB.image.data];
                    piece.number = j+pieceNumber*i;
                    piece.size = piceSize;
                    piece.isFree = [pieceDB isFreeScalar];
                    piece.position = [pieceDB.position intValue];
                    piece.angle = [pieceDB.angle floatValue];
                    piece.moves = [pieceDB.moves intValue];
                    piece.rotations = [pieceDB.rotations intValue];
                    piece.transform = CGAffineTransformMakeRotation(piece.angle);
                    
                    piece.frame = rect;
                    
                    NSNumber *n = [NSNumber numberWithInt:NumberSquare];
                    piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
                    
                    
                    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
                    [a addObject:pieceDB.edge0];
                    [a addObject:pieceDB.edge1];
                    [a addObject:pieceDB.edge2];
                    [a addObject:pieceDB.edge3];
                    
                    piece.edges = [NSArray arrayWithArray:a];
                    
                    [arrayPieces addObject:piece];
                    
                }
            }
        }
        
    } 
    else {
        
        
        for (int i=0;i<pieceNumber;i++){
            
            for (int j=0;j<pieceNumber;j++){
                
                CGRect rect = CGRectMake( 0, 0, SHAPE_QUALITY*piceSize, SHAPE_QUALITY*piceSize);
                
                PieceView *piece = [[PieceView alloc] initWithFrame:rect];
                piece.delegate = self;
                piece.image = [array objectAtIndex:j+pieceNumber*i];
                piece.number = j+pieceNumber*i;
                piece.size = piceSize;
                piece.position = -1;
                NSNumber *n = [NSNumber numberWithInt:NumberSquare];
                piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
                
                //piece.frame = rect;
                
                
                NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
                
                for (int k=0; k<4; k++) {
                    int e = arc4random_uniform(3)+1;
                    
                    if (arc4random_uniform(2)>0) {
                        e *= -1;
                    }
                                        
                    [a addObject:[NSNumber numberWithInt:e]];
                }
                
                if (i>0) {
                    int l = [arrayPieces count]-pieceNumber;
                    int e = [[[[arrayPieces objectAtIndex:l] edges] objectAtIndex:1] intValue];
                    [a replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:-e]];
                    //DLog(@"e = %d", e);
                }
                
                if (j>0) {
                    int e = [[[[arrayPieces lastObject] edges] objectAtIndex:2] intValue];
                    [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:-e]];
                    //DLog(@"e = %d", e);
                }
                
                if (i==0) {
                    [a replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:0]];
                }
                if (i==pieceNumber-1) {
                    [a replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
                }
                if (j==0) {
                    [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
                }
                if (j==pieceNumber-1) {
                    [a replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
                }
                
                
                piece.edges = [NSArray arrayWithArray:a];                
                
                [arrayPieces addObject:piece];
                
            }
        }
    
    } //end if loadingGame   
            
            
    
    
    pieces = [[NSMutableArray alloc] initWithArray:arrayPieces];
    
    loadedPieces = 0;
            
    [self.operationQueue addOperations:[NSArray arrayWithObject:puzzleOperation] waitUntilFinished:NO];
    
    
}

- (void)addAnothePieceToView {
        
    [self.view insertSubview:[pieces objectAtIndex:loadedPieces] belowSubview:menu.obscuringView];
}

- (void)moveBar {
    
    float a = (float)loadedPieces;
    float b = (float)NumberSquare;
    
    if (loadingGame) {
        
        b = NumberSquare;
    }
    
    menu.game.progressView.progress = a/b;
    
}

- (NSArray *)splitImage:(UIImage *)im partSize:(float)partSize {
    
    float x = pieceNumber;
    float y= pieceNumber;
    
    float padding_temp = partSize*0.15;
    
    DLog(@"Splitting image w=%.1f, ww=%.1f, imageSize=%.1f", partSize, padding_temp, im.size.width);
        
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            
            CGRect rect = CGRectMake(i * (partSize-2*padding_temp)-padding_temp, 
                                     j * (partSize-2*padding_temp)-padding_temp, 
                                     partSize, partSize);
            
            [arr addObject:[im subimageWithRect:rect]]; 
            
            //loadedPieces++;
            
            //[arr addObject:[self clipImage:im toRect:rect]];          
        }
    }
    
    DLog(@"Image splitted");

    return arr;
    
}

- (BOOL)isPuzzleComplete {
    
    if (puzzleCompete) {
        return YES;
    } else {
        
        for (PieceView *p in pieces) {
            if (!p.isPositioned && !p.group.isPositioned) {
                //DLog(@"Piece #%d is not positioned", p.number);
                
                return NO;
            }
        }
                
        [self puzzleCompleted];
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
            //
            imageView.alpha = 1;
            HIDE_STATUS_BAR

        } else if (imageView.alpha==1) {
            
            menuButtonView.userInteractionEnabled = YES;
            imageView.alpha = 0;
            SHOW_STATUS_BAR
        }
    }];
    
    [self.view bringSubviewToFront:self.adBannerView];
    
}

- (IBAction)puzzleCompleted {
    
    puzzleCompete = YES;
    
    [self stopTimer];
    [completedController updateValues];

    
    [UIView animateWithDuration:2 animations:^{
    
        drawerView.alpha = 0;
        panningSwitch.alpha = 0;
        percentageLabel.alpha = 0;
        elapsedTimeLabel.alpha = 0;
        scoreLabel.alpha = 0;

        for (UIView *v in lattice.pieces) {
            v.alpha = 0;
        }
        
    }completion:^(BOOL finished) {
        
        //puzzleDB.percentage = [NSNumber numberWithInt:100];
        [self saveGame];
        [self.view bringSubviewToFront:lattice];
        [self.view bringSubviewToFront:completedController.view];
        [self.view bringSubviewToFront:HUDView];
        [self.view bringSubviewToFront:self.adBannerView];

    }];
    
    
    if (!IS_DEVICE_PLAUYING_MUSIC) {
        
        [completedSound play];
        
    }
    
    [self showCompleteImage];
    
}

- (IBAction)restartPuzzle:(id)sender {
    
    [self createPuzzleFromImage:image];
}



#pragma mark -
#pragma mark Gesture handling

- (void)addGestures {
    
    pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:2];
    
    panDrawer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDrawer:)];
    [panDrawer setMinimumNumberOfTouches:1];
    [panDrawer setMaximumNumberOfTouches:1];
    [drawerView addGestureRecognizer:panDrawer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPressure = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImage:)];
    [longPressure setMinimumPressDuration:0.5];
    [self.view addGestureRecognizer:longPressure];
    
//    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
//    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
//    [swipeR setNumberOfTouchesRequired:2];
//    [self.view addGestureRecognizer:swipeR];
//    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
//    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [swipeL setNumberOfTouchesRequired:2];
//    [self.view addGestureRecognizer:swipeL];
    
}

- (void)doubleTap:(UITapGestureRecognizer*)gesture {
    
    CGPoint point = [gesture locationInView:lattice];

    movingPiece = nil;
    
    for (int i= 0; i<9*NumberSquare; i++) {
        
        CGRect rect = [[[lattice pieces] objectAtIndex:i] frame];
        
        if ([self point:point isInFrame:rect]) {
            movingPiece = [self pieceWithPosition:i];
        }
        
    }
    
    if (movingPiece!=nil) {
        [movingPiece rotateTap:gesture];
        
    } else {
        
        [self resetLatticePositionAndSizeWithDuration:0.5];
    }
}

- (void)pan:(UIPanGestureRecognizer*)gesture {
        
    CGPoint point = [gesture locationInView:lattice];
    
    if (gesture.state==UIGestureRecognizerStateBegan) {
        
        movingPiece = nil;
        
        for (int i= 0; i<9*NumberSquare; i++) {
            
            CGRect rect = [[[lattice pieces] objectAtIndex:i] frame];
            
            if ([self point:point isInFrame:rect]) {
                DLog(@"Position %d ", i);
                movingPiece = [self pieceWithPosition:i];
                
            }
            
        }
    }
    
    if (movingPiece!=nil && !panningMode) {

        [movingPiece move:gesture];
        return;
    }
  
    
    if (menu.view.alpha == 0) {
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        if (YES) {//ABS(traslation.x>0.03) || ABS(traslation.y) > 0.03) {
            
            lattice.transform = CGAffineTransformTranslate(lattice.transform, traslation.x/lattice.scale, traslation.y/lattice.scale);
            [self refreshPositions];
            [gesture setTranslation:CGPointZero inView:lattice.superview];
        }
    }
    
}

- (void)pinch:(UIPinchGestureRecognizer*)gesture {
    
    
    if (CGRectContainsPoint(drawerView.frame, [gesture locationInView:self.view])) return;
    
    
    float z = [gesture scale];
    
    if (YES) {//z>1.03 || z < 0.97) {
        
        CGPoint point = CGPointMake([gesture locationInView:lattice].x, [gesture locationInView:lattice].y);
        [self setAnchorPoint:point forView:lattice];
        
        [self resizeLatticeToScale:lattice.scale*z];
        
        [gesture setScale:1];
    }
}

- (void)resizeLatticeToScale:(float)newScale {

    float z = newScale/lattice.scale;
        
    if (lattice.scale*z*3*pieceNumber*(piceSize-2*padding)>screenWidth && lattice.scale*z*piceSize<screenWidth) {
    
        lattice.scale = newScale;

        lattice.transform = CGAffineTransformScale(lattice.transform, z, z);
        
        for (GroupView *g in groups) {
            
            g.transform = CGAffineTransformScale(g.transform, z, z);
        }
        
        [self refreshPositions];        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return (    (gestureRecognizer==pan && otherGestureRecognizer==pinch)   ||
            (gestureRecognizer==pinch && otherGestureRecognizer==pan)   );
}



#pragma mark -
#pragma mark Groups

- (void)groupMoved:(GroupView*)group {
    
    CGRect frame;
    
    for (int i=9*NumberSquare-1; i>-1; i--) {
        
        frame = [self frameOfLatticePiece:i];
        if ([self group:group isInFrame:frame]) {
            
            //DLog(@"Group is in lattice piece #%d", i);
            [self moveGroup:group toLatticePoint:i animated:YES];
            
            return;
        }
    }

    [self moveGroup:group toLatticePoint:group.boss.position animated:YES];

}

- (UIView*)upperGroupBut:(GroupView*)group {
    
    for (int i =[self.view.subviews count]-1; i>-1; i--) {
        
        GroupView *g = [self.view.subviews objectAtIndex:i];
        if ([g isKindOfClass:[GroupView class]] && g!=group) {
            return g;
        }
        
//        PieceView *p = [self.view.subviews objectAtIndex:i];
//        if ([p isKindOfClass:[PieceView class]] && p.isPositioned) {
//            return p;
//        }
    }
    
    return lattice;
}

- (void)createNewGroupForPiece:(PieceView*)piece {
    
    if ([self isTheFuckingPiecePositioned:piece] && !loadingGame) {
        return;
    }
        
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
        newGroup.delegate = self;
        newGroup.isPositioned = (piece.isPositioned && loadingGame);

        
        //piece.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.1];
        piece.isBoss = YES;
        piece.transform = CGAffineTransformScale(piece.transform, 1/lattice.scale, 1/lattice.scale);
        [self addPiece:piece toGroup:newGroup];
        
        for (PieceView *p in [piece allTheNeighborsBut:nil]) {
            p.isBoss = NO;
            [self addPiece:p toGroup:newGroup];
        }
        
        [groups addObject:newGroup];
        [self.view insertSubview:newGroup aboveSubview:[self upperGroupBut:newGroup]];
        
        if ([self isTheFuckingPiecePositioned:piece]) {
            newGroup.isPositioned = YES;
        }
        
        DLog(@"New group created, isPositioned = %d. Groups count %d", newGroup.isPositioned, [groups count]);
        
    } else {

        piece.isBoss = NO;

        if (piece.group!=newGroup) {
            
            [self addPiece:piece toGroup:newGroup];
            DLog(@"Piece #%d added to existing group", piece.number);

        }        
    }
    
    [self moveGroup:newGroup toLatticePoint:newGroup.boss.position animated:NO];
    
}

- (void)addPiece:(PieceView*)piece toGroup:(GroupView*)group {
        
    if ([self isTheFuckingPiecePositioned:piece] && !loadingGame) {
        return;
    }
    
    if (piece.group==group) {
       
        return;
        
    } else {
        
        piece.group = group;
    }

    DLog(@"%s", __PRETTY_FUNCTION__);

    piece.isBoss = NO;
    [piece removeFromSuperview];
    [group.pieces addObject:piece];

        
    [group addSubview:piece];
    
    //Reset piece size
    piece.transform = group.boss.transform;
    
    CGPoint relative = [self coordinatesOfPiece:piece relativeToPiece:group.boss];
    
    CGAffineTransform matrix = CGAffineTransformMakeRotation(group.boss.angle-group.angle);
    relative = [self applyMatrix:matrix toVector:relative];
    
    float w = [[lattice objectAtIndex:0] bounds].size.width+4;
    
    CGPoint trans = CGPointMake(relative.y*w, relative.x*w);
    
    piece.center = CGPointMake(group.boss.center.x+trans.x, group.boss.center.y+trans.y);
        
    //[self refreshPositions];
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
            
            [self updatePositionsInGroup:group withReferencePiece:group.boss];
            [self checkNeighborsForGroup:group];
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
            
            //DLog(@"Relative Position = %.1f, %.1f, p.number-boss.number = %d", relativePosition.x, relativePosition.y, p.number-boss.number);

            CGAffineTransform matrix = CGAffineTransformMakeRotation(boss.angle); 
            relativePosition = [self applyMatrix:matrix toVector:relativePosition];

            //DLog(@"Relative Position after matrix = %.1f, %.1f, p.number-boss.number = %d", relativePosition.x, relativePosition.y, p.number-boss.number);

            p.position = boss.position + relativePosition.x + 3*pieceNumber*relativePosition.y;

            //DLog(@"NewPosition = %d. %.1f, boss position = %d, %.1f", p.position, p.angle, boss.position, boss.angle);
            
        }
    }
    
    
    if ([self isPositioned:group.boss]) {
        
        for (PieceView *p in pieces) {
            
            if (p.group==group) {
                
                [self isPositioned:p];   
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
        
        //DLog(@"Position of piece #%d is %d", pieceDB.number.intValue, pieceDB.position.intValue);
    }

    [self saveGame];
    
}

- (void)checkNeighborsForAllThePieces {
    
    for (PieceView *p in pieces) {
        if (p.isFree) {
            [self checkNeighborsOfPiece:p];
            if (p.hasNeighbors) {
                            
                [self createNewGroupForPiece:p];
            }
        }
    }    
    

}

- (void)checkNeighborsForGroup:(GroupView*)group {
    
    DLog(@"Starting %s", __FUNCTION__);

    for (int i=0; i<[group.pieces count]; i++) {
        
        PieceView *p = [group.pieces objectAtIndex:i];
        
        if (!p.isCompleted) {
            [self checkNeighborsOfPiece:p];

        }
    }
    
    //DLog(@"Finished %s", __FUNCTION__);
}



#pragma mark -
#pragma mark Pieces

- (void)pieceMoved:(PieceView *)piece {
    
    //DLog(@"%s", __FUNCTION__);
    
    CGPoint point = piece.center;   
    
    if (!piece.hasNeighbors) {
        
        BOOL outOfDrawer;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            outOfDrawer = point.y<screenHeight-drawerSize;
        } else {
            outOfDrawer = point.x>drawerSize-self.padding;
        }
        
        point = [drawerView convertPoint:point fromView:self.view];
        
        
        if (![drawerView pointInside:point withEvent:nil]) {
            
            
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
        piece.moves++;
        moves++;    
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
                    //DLog(@"Reset the old position (%.1f, %.1f) for piece #%d", p.oldPosition.x, p.oldPosition.y, p.number);
                    p.position = [self positionOfPiece:p];
                }
                CGRect rect = piece.frame;
                rect.origin.x = piece.oldPosition.x-piece.frame.size.width/2;
                rect.origin.y = piece.oldPosition.y-piece.frame.size.height/2;
                piece.frame = rect;                
                //DLog(@"BOSS - Reset the old position (%.1f, %.1f) for piece #%d", piece.oldPosition.x, piece.oldPosition.y, piece.number);
                piece.position = [self positionOfPiece:piece]; 
            }];
            
        } else {
            
            for (int i=9*NumberSquare-1; i>-1; i--) {
                
                
                //DLog(@"v origin = %.1f, %.1f - [piece realCenter] = %.1f, %.1f", frame.origin.x, frame.origin.y, [piece realCenter].x, [piece realCenter].y);
                
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
    
    
    
    piece.oldPosition = [piece realCenter];
    
    
    if (panningMode && piece.isFree) {
        piece.userInteractionEnabled = NO;
    }
    
    
    
    //DLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);
    
}

- (int)positionOfPiece:(PieceView*)piece {
    
    
    for (int i=9*NumberSquare-1; i>-1; i--) {
        
        CGRect frame = [self frameOfLatticePiece:i];
        
        if ([self piece:piece isInFrame:frame]) {
            
            //DLog(@"-> Returning position %d",i);
            return i;
        }
    }
    
    //DLog(@"-> \nReturning position -1");    
    return -1;
}

- (void)pieceRotated:(PieceView *)piece {
    
    if (piece.isFree) {
        piece.rotations++;
        rotations++;
    }

    //DLog(@"Piece rotated! Angle = %.1f", piece.angle);
    
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
    
    
    //DLog(@"Position for piece #%d is %d", piece.number, piece.position);
    //DLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);
    
    if (piece.group!=nil) {
        
        [self checkNeighborsForGroup:piece.group];
        
    } else {
        
        [self checkNeighborsOfPiece:piece];
        if (piece.hasNeighbors) {
            [self createNewGroupForPiece:piece];
        }
    }
    
    [self updatePieceDB:piece];
    [self updatePercentage];
    
    
}

- (PieceView*)pieceAtPosition:(int)j {
    
    for (PieceView *p in pieces) {
        
        if (p.position == j) {
            
            //DLog(@"Piece at position %d is #%d", j, p.number);
            return p;
        }
    }
    
    return nil;
}

- (BOOL)shouldCheckNeighborsOfPiece:(PieceView*)piece inDirection:(int)r {
    
    if (piece.position!=0) {
        
        return YES;

        
        if (r==2 && (piece.position+1)%pieceNumber==0) {
            DLog(@"bottom piece (#%d) checking down", piece.number);
            return NO;
        }
        if ( r==0 && (piece.position)%pieceNumber==0) {
            DLog(@"top piece (#%d) checking up", piece.number);
            return NO;
        }
        if (r==3 && (piece.position)/pieceNumber==pieceNumber-1) {
            DLog(@"right piece (#%d) checking right", piece.number);
            return NO;
        }
        if (r==1 && (piece.position)/pieceNumber==0) {
            DLog(@"left piece (#%d) checking left", piece.number);
            return NO;
        }
        
        return YES;
        
    } else {
        return (r==1 || r==2);
    }
    
}

- (int)rotationFormAngle:(float)angle {
    
    int rotation = 3;
    
         if (angle<1) rotation = 0;
    else if (angle<3) rotation = 1;
    else if (angle<4) rotation = 2;
    
    return rotation;
}

- (void)checkNeighborsOfPiece:(PieceView*)piece {
    
    int rotation = [self rotationFormAngle:piece.angle];    
    
    PieceView *otherPiece;
    int j = piece.position;
    
    if (j==-1) {
        return;
    }
    
    
    for (int direction=0; direction<4; direction++) {
        
        int r = (direction+rotation)%4;
        
        int i = [[directions_positions objectAtIndex:r] intValue];
        int l = [[directions_numbers objectAtIndex:direction] intValue];
                
        
        //Looks for neighbors       
        
        if (j+i>=0 && j+i<9*NumberSquare && [self shouldCheckNeighborsOfPiece:piece inDirection:r] )
        {
            
            otherPiece = [self pieceAtPosition:j+i];
            
            DLog(@"j+i = %d ; numbers are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d",j+i, piece.number+l, otherPiece.number,  piece.number, otherPiece.number, direction, rotation, r);    
            
            DLog(@"Checking position %d, number+l = %d, otherPiece.number = %d", piece.number+i, piece.number+l, otherPiece.number);
            
            if (otherPiece != nil) {
                
                if (otherPiece.isFree) {
                    
                    DLog(@"Angles are %.1f (piece) and %.1f (other)\n\n", piece.angle, otherPiece.angle);
                    
                    
                    if (piece.number+l==otherPiece.number) {
                        
                        
                        if ((ABS(piece.angle-otherPiece.angle)<M_PI/4)) {
                            
                            if ([[piece.neighbors objectAtIndex:direction%4] intValue]!=otherPiece.number) {
                                
                                [otherPiece setNeighborNumber:piece.number forEdge:(direction+2)%4];
                                [piece setNeighborNumber:otherPiece.number forEdge:direction%4];
                                
                                piece.hasNeighbors = YES;
                                otherPiece.hasNeighbors = YES;
                                
                                if (
                                    !loadingGame &&
                                    !IS_DEVICE_PLAUYING_MUSIC &&
                                    !([self isTheFuckingPiecePositioned:piece])
                                    ) {
                                    
                                    [neighborSound play];
                                }
                                
                                //DLog(@"piece.isPositioned = %d, otherpiece.isPositioned = %d", piece.isPositioned, otherPiece.isPositioned);
                                
                                if ((![self isTheFuckingPiecePositioned:piece] || ![self isTheFuckingPiecePositioned:otherPiece]) && !loadingGame) {
                                                                        
                                    if (otherPiece.group!=nil && !otherPiece.group.isPositioned) {
                                        
                                        if (piece.group!=nil) {
                                            for (PieceView *p in piece.group.pieces) {
                                                [self addPiece:p toGroup:otherPiece.group];
                                            }
                                        } else {
                                            [self addPiece:piece toGroup:otherPiece.group];
                                        }
                                        
                                    } else if (piece.group!=nil && !piece.group.isPositioned) {
                                        
                                        if (otherPiece.group!=nil) {
                                            for (PieceView *p in otherPiece.group.pieces) {
                                                [self addPiece:p toGroup:piece.group];
                                            }
                                        } else {
                                            [self addPiece:otherPiece toGroup:piece.group];
                                        }
                                        
                                    }
                                }
                            }
                            
                        } else {
                            //DLog(@"0 -------> Wrong angles. They are %.1f and %.1f for pieces #%d and #%d", piece.angle, otherPiece.angle, piece.number, otherPiece.number);
                        }
                    } else {
                        //DLog(@"-------> Wrong numbers. They are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d", piece.number+l, otherPiece.number, piece.number, otherPiece.number, direction, rotation, r);
                        
                    }
                }
                
            }else {
                
                //DLog(@"NIL");
                
            }
            
        } else {
            //DLog(@"Shouldn't check");
        }
        
    }
    
    //DLog(@"\n");
    
}

- (BOOL)isTheFuckingPiecePositioned:(PieceView*)piece {
    
    return (firstPiecePlace + 3*pieceNumber*(piece.number/pieceNumber) + (piece.number%pieceNumber) == piece.position);
}

- (BOOL)isPositioned:(PieceView*)piece  {
    
    //DLog(@"isPositioned? Position %d, number %d -> %d", piece.position, piece.number, firstPiecePlace + 3*pieceNumber*(piece.number/pieceNumber) + (piece.number%pieceNumber));
    
    if (piece.isFree && ([self isTheFuckingPiecePositioned:piece]) && ABS(piece.angle) < 1) {
        
        //DLog(@"Piece #%d positioned!", piece.number);
        //Flashes and block the piece
        if (!piece.isPositioned) {
            
            
            if (!loadingGame) {
                                
                [self addPoints:[self pointsForPiece:piece]];
            }
            
            
            piece.isPositioned = YES;
            piece.userInteractionEnabled = NO;
            if (!piece.group) {
                [piece removeFromSuperview];
                [self.view insertSubview:piece aboveSubview:lattice];
            }
    
            
            //DLog(@"Salvi! Piece #%d is positioned! :-)", piece.number);
            
            [piece pulse];

            
            if (![self isPuzzleComplete] && !loadingGame) {
                               
                if (!IS_DEVICE_PLAUYING_MUSIC) {
                    [positionedSound play];
                }
            }
        }        
        return YES;
    }
    return NO;
}

- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated {
    
    //DLog(@"Moving piece #%d to position %d", piece.number, i);
    
    piece.position = i;
    
    if (animated) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            piece.center = [self centerOfLatticePiece:i];
            CGAffineTransform trans = CGAffineTransformMakeScale(lattice.scale, lattice.scale);
            piece.transform = CGAffineTransformRotate(trans, piece.angle);
            
        }completion:^(BOOL finished) {
            
            [self checkNeighborsOfPiece:piece];
            
            if (piece.hasNeighbors) {
                [self createNewGroupForPiece:piece];
            }
            
            if (!piece.isPositioned) {
                [self isPositioned:piece];
            }
            
            [self updatePercentage];
            [self updatePieceDB:piece];
        }];
        
    } else {
        
        piece.center = [self centerOfLatticePiece:i];
        CGAffineTransform trans = CGAffineTransformMakeScale(lattice.scale, lattice.scale);
        piece.transform = CGAffineTransformRotate(trans, piece.angle);
        
    }
        
    piece.oldPosition = [piece realCenter];
    
}

- (BOOL)piece:(PieceView*)piece isInFrame:(CGRect)frame {
    
    return frame.origin.x<[piece realCenter].x && frame.origin.y<[piece realCenter].y;
}

- (BOOL)point:(CGPoint)point isInFrame:(CGRect)frame {
    
    //DLog(@"Point = %.1f, %.1f", point.x, point.y);
    
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
    pieceDB.moves = [NSNumber numberWithInt:piece.rotations];
    pieceDB.rotations = [NSNumber numberWithInt:piece.moves];
    [pieceDB setisFreeScalar:piece.isFree];
    
    pieceDB.edge0 = [piece.edges objectAtIndex:0];
    pieceDB.edge1 = [piece.edges objectAtIndex:1];
    pieceDB.edge2 = [piece.edges objectAtIndex:2];
    pieceDB.edge3 = [piece.edges objectAtIndex:3];
    
    [self saveGame];
    
}

- (CGPoint)coordinatesOfPiece:(PieceView*)piece relativeToPiece:(PieceView*)boss {
    
//    DLog(@"relative = (%.0f, %.0f), boss.number = %d, piece.number = %d, ", 
//          (float)((piece.number%pieceNumber-boss.number%pieceNumber)%pieceNumber), 
//          (float)(piece.number/pieceNumber-boss.number/pieceNumber),
//          boss.number,
//          piece.number);

    return CGPointMake(
                       (float)((piece.number%pieceNumber-boss.number%pieceNumber)%pieceNumber), 
                       (float)(piece.number/pieceNumber-boss.number/pieceNumber)
                       );
        
}

- (Piece*)pieceOfCurrentPuzzleDB:(int)n {
    
    for (Piece *p in puzzleDB.pieces) {
        if ([p.number intValue]==n) {
            return p;
        }
    }
    
    DLog(@"------>  Piece #%d is NIL!", n);
    
    missedPieces++;
    
    return nil;
    
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

- (void)setPieceNumber:(int)pieceNumber_ {
    
    pieceNumber = pieceNumber_;
    NumberSquare = pieceNumber*pieceNumber;
    
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
        
        if (p.position==j && p.userInteractionEnabled) {
            return p;
        }
    }
    
    DLog(@"None of the pieces is in position %d", j);
    
    return nil;
}

- (BOOL)pieceIsOut:(PieceView *)piece {
    
    CGRect frame1 = [self frameOfLatticePiece:0];
    CGRect frame2 = [self frameOfLatticePiece:9*NumberSquare-1];
    
    if ([piece realCenter].x > frame2.origin.x+frame2.size.width ||
        [piece realCenter].y > frame2.origin.y+frame2.size.width ||
        [piece realCenter].x < frame1.origin.x ||
        [piece realCenter].y < frame1.origin.y
        )
    {
        DLog(@"Piece #%d is out, N= %.1d", piece.number, NumberSquare);
        return YES;
    }
    
    for (PieceView *p in [piece allTheNeighborsBut:nil]) {
        
        if ([p realCenter].x > frame2.origin.x+frame2.size.width ||
            [p realCenter].y > frame2.origin.y+frame2.size.width ||
            [p realCenter].x < frame1.origin.x ||
            [p realCenter].y < frame1.origin.y
            )        {
            DLog(@"Piece is #%d out, N= %.1d (neighbor)", piece.number, NumberSquare);
            return YES;
        }
    }
    
    //DLog(@"IN");
    
    return NO;
}

- (UIView*)upperPositionedThing {
    
    int N = self.view.subviews.count;
    
    for (int i=0; i<self.view.subviews.count; i++) {
        
        UIView *v = [self.view.subviews objectAtIndex:N-i-1];
        
        if ([v isKindOfClass:[GroupView class]]) {            
                        
            return v;
        }
        if ([v isKindOfClass:[PieceView class]]) {            
                        
            if (!v.userInteractionEnabled) {
                return v;
            }
        }
    }
    
    return lattice;
}



#pragma mark -
#pragma mark Lattice

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
    
    [self.view bringSubviewToFront:self.adBannerView];

    //DLog(@"Lattice created");
    
}

- (void)resetLatticePositionAndSizeWithDuration:(float)duration {
    
    float f = (screenWidth)/(pieceNumber+1)/(piceSize-2*padding);

        
    [UIView animateWithDuration:duration animations:^{

        [self resizeLatticeToScale:f];

    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:duration animations:^{
            
            CGPoint center = [self.view convertPoint:[[lattice objectAtIndex:firstPiecePlace] center] fromView:lattice];
            int topBar = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))*20;

            float ad = self.adPresent*self.adBannerView.frame.size.height;

            
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                
                lattice.transform = CGAffineTransformTranslate(lattice.transform, 
                -center.x/lattice.scale+(piceSize-2*padding)+(drawerSize)/lattice.scale, 
                -center.y/lattice.scale+(piceSize-2*padding)+10-ad/lattice.scale/2);
            } else {
                
                lattice.transform = CGAffineTransformTranslate(lattice.transform, 
                -center.x/lattice.scale+(piceSize-2*padding), 
                -center.y/lattice.scale+(piceSize-2*padding)+(HUDView.bounds.size.height-ad)/lattice.scale-topBar);
            }
            
                        
            [self refreshPositions];
            
        }];
    }];
    
}

- (void)moveLatticeToLeftWithDuration:(float)duration {
        
    CGPoint center = [self.view convertPoint:[[lattice objectAtIndex:firstPiecePlace] center] fromView:lattice];
    int topBar = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))*20;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        lattice.transform = CGAffineTransformTranslate(lattice.transform, 
                                                       -center.x/lattice.scale+(piceSize-2*padding)/2+30, 
                                                       -center.y/lattice.scale+(piceSize-2*padding)-topBar);
    } else {
        
        lattice.transform = CGAffineTransformTranslate(lattice.transform, 
                    -center.x/lattice.scale+(piceSize-2*padding), 
                    -center.y/lattice.scale+(piceSize-2*padding)/2+puzzleCompleteImage.bounds.size.height/lattice.scale+topBar);
    }

    
    [self refreshPositions];
    
    [UIView animateWithDuration:duration animations:^{
        
        for (GroupView *g in groups) {
            g.alpha = 1;
        }
        
        for (PieceView *p in pieces) {
            if (!p.group) {
                p.alpha = 1;
            }
        }
    }];    
}

- (CGRect)frameOfLatticePiece:(int)i {
    
    UIView *v = [lattice objectAtIndex:i];
    return CGRectMake(
                      lattice.frame.origin.x + lattice.scale*(v.frame.origin.x-self.padding)-2.0*lattice.scale,
                      lattice.frame.origin.y + lattice.scale*(v.frame.origin.y-self.padding)-2.0*lattice.scale, 
                      lattice.scale*piceSize, 
                      lattice.scale*piceSize
                      );
    
}

- (CGPoint)centerOfLatticePiece:(int)i {

    CGRect rect = [self frameOfLatticePiece:i];
    return CGPointMake(rect.origin.x+lattice.scale*piceSize/2.0, rect.origin.y+lattice.scale*piceSize/2.0);
    
}



#pragma mark -
#pragma mark Drawer

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
        
        PieceView *p = [temp objectAtIndex:0];
        drawerFirstPoint.x = [p frame].origin.x+p.bounds.size.height/2;
        drawerFirstPoint.y = [p frame].origin.y+p.bounds.size.height/2;
        //DLog(@"FirstPoint = %.1f, %.1f", drawerView.frame.origin.x, drawerView.frame.origin.y);

    }
    

    float bannerHeight = (self.adBannerView.frame.size.height)*self.adBannerView.bannerLoaded;
    IF_IPAD bannerHeight -= 20*self.adBannerView.bannerLoaded;
    
    //[UIView animateWithDuration:ORG_TIME animations:^{
        
        for (int i=0; i<[temp count]; i++) {
            
            PieceView *p = [temp objectAtIndex:i];
            
            CGPoint point = p.center;
            PieceView *p2;
            
            if (i>0) {
                p2 = [temp objectAtIndex:i-1];
                CGPoint point2 = p2.center;
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    point.y = point2.y+p2.bounds.size.width+drawerMargin;
                    point.x = drawerView.center.x; //(self.padding*0.75)/2+p.bounds.size.width/2;;
                } else {
                    point.x = point2.x+p2.bounds.size.width+drawerMargin;
                    point.y = screenHeight-drawerSize+(self.padding*0.75)/2+p.bounds.size.height/2-bannerHeight;
                }
                
            } else {
                
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    point.y = drawerFirstPoint.y+p.bounds.size.height/2+drawerMargin;
                    point.x = drawerView.center.x; //(self.padding*0.75)/2+p.bounds.size.width/2;;
                } else {
                    point.x = drawerFirstPoint.x+p.bounds.size.width/2+drawerMargin;
                    point.y = screenHeight-drawerSize+(self.padding*0.75)/2+p.bounds.size.height/2-bannerHeight;
                }
                
                //DLog(@"FirstPoint was %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);

            }

            if (!didRotate && UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
                //point.y += 20;
            }
            
            p.center = point;

        }
    //}];
    
    
    
}

- (BOOL)drawerStoppedShouldBeStopped {
    
    if ([self numberOfPiecesInDrawerAtTheMoment]<=numberOfPiecesInDrawer) {
        
        if (!drawerStopped) {
            drawerStopped = YES;
            drawerFirstPoint = CGPointMake(-4, 5);
            [UIView animateWithDuration:0.5 animations:^{
                [self organizeDrawerWithOrientation:self.interfaceOrientation];
            }];
        }
        return YES;
    }
    return NO;
}

- (void)panDrawer:(UIPanGestureRecognizer*)gesture {
    
    if (menu.view.alpha == 0) {

        if ([self drawerStoppedShouldBeStopped]) return;
        
        drawerStopped = NO;
        
        
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        
        
#define PANNING_SPEED 0.07
        
#define VELOCITY_LIMIT 1000.0
        
#define PAN_DRAWER_ACCURACY 0.01

        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) { //Landscape
            
            float velocity = [gesture velocityInView:self.view].y;
            
            if (velocity<0) {
                
                if (velocity < -VELOCITY_LIMIT) velocity = -VELOCITY_LIMIT;
            
                if ([self lastPieceInDrawer].frame.origin.y<screenWidth-piceSize) {

                    [self moveNegativePieces];
                }

            } else {
                
                if (velocity>VELOCITY_LIMIT) velocity = VELOCITY_LIMIT;

                if ([self firstPieceInDrawer].frame.origin.y>0) {

                    [self movePositivePieces];
                }

            }

            if (ABS(traslation.x > PAN_DRAWER_ACCURACY) || ABS(traslation.y) > PAN_DRAWER_ACCURACY) {
                
                for (PieceView *p in pieces) {
                    if (!p.isFree) {
                        
                        CGPoint point = p.center;
                        point.y += velocity*PANNING_SPEED;
                        p.center = point;
                    }
                }                
                drawerFirstPoint.y += velocity*PANNING_SPEED;
                [gesture setTranslation:CGPointMake(traslation.x, 0) inView:lattice.superview];                
            }
            
            
        } else {    //Portrait
            
            float velocity = [gesture velocityInView:self.view].x;
            
            if (velocity<0) {
                
                if (velocity < -VELOCITY_LIMIT) velocity = -VELOCITY_LIMIT;
                
                if ([self lastPieceInDrawer].frame.origin.x<screenWidth-piceSize) {
                    
                    [self moveNegativePieces];
                }
                
            } else {

                if (velocity>VELOCITY_LIMIT) velocity = VELOCITY_LIMIT;

                if ([self firstPieceInDrawer].frame.origin.x>0) {
                    
                    [self movePositivePieces];
                }
                
            }
            
            if (ABS(traslation.x > PAN_DRAWER_ACCURACY) || ABS(traslation.y) > PAN_DRAWER_ACCURACY) {
                
                for (PieceView *p in pieces) {
                    if (!p.isFree) {
                        
                        CGPoint point = p.center;
                        point.x += velocity*PANNING_SPEED;
                        p.center = point;
                    }
                }    
                drawerFirstPoint.x += velocity*PANNING_SPEED;
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
        
        return CGRectMake(drawerView.frame.origin.x+drawerMargin, 
                          piece.frame.origin.y+piceSize+drawerMargin, 
                          piece.frame.size.width, 
                          piece.frame.size.height);
    } else {
        
        return CGRectMake(piece.frame.origin.x+piceSize+drawerMargin,
                          drawerView.frame.origin.y+drawerMargin,
                          piece.frame.size.width, 
                          piece.frame.size.height);
    }    
}

- (CGRect)frameOverPiece:(PieceView*)piece {
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        return CGRectMake(drawerView.frame.origin.x+drawerMargin, 
                          piece.frame.origin.y-piceSize-drawerMargin, 
                          piece.frame.size.width, 
                          piece.frame.size.height);
    } else {
        
        return CGRectMake(piece.frame.origin.x-piceSize-drawerMargin,
                          drawerView.frame.origin.y+drawerMargin,
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
                }];                //DLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
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
                
                //DLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
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



#pragma mark -
#pragma mark Core Data

- (BOOL)saveGame {
    
    if (puzzleDB==nil) {
        
        DLog(@"PuzzleDB is nil");
        //[self createPuzzleInDB];
    }
    
    
    puzzleDB.moves = [NSNumber numberWithInt:moves];
    puzzleDB.rotations = [NSNumber numberWithInt:rotations];
    puzzleDB.score = [NSNumber numberWithInt:score];
    puzzleDB.lastSaved = [NSDate date];
    puzzleDB.percentage = [NSNumber numberWithInt:[self completedPercentage]];

    if ([managedObjectContext save:nil]) {
        //DLog(@"Puzzle saved");
    }
    
    return YES;
    
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

- (void)createPuzzleInDB {
    
    self.view.userInteractionEnabled = NO;
    
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

- (Puzzle*)newPuzzleInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Puzzle" 
            inManagedObjectContext:context];
}

- (Image*)newImageInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Image" 
            inManagedObjectContext:context];
}

- (Piece*)newPieceInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Piece" 
            inManagedObjectContext:context];
}


#pragma mark -
#pragma mark iAd

- (void)adjustForAd:(int)direction {
    
    CGRect drawerFrame = drawerView.frame;
    float bannerHeight = self.adBannerView.frame.size.height;

    if (direction==0) {
        return;
        
    } else {
        
        //Adjust the drawer
        
        drawerFrame.origin.x = 0;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            
            drawerFrame.size.width = drawerSize;
            drawerFrame.size.height = screenWidth;
            drawerFrame.origin.y = 0;
            
        } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
            
            if (direction>0) { //Move UP
                drawerFrame.size.height = drawerSize+bannerHeight;
                drawerFrame.size.width = screenWidth;
                drawerFrame.origin.y = screenWidth;
                IF_IPHONE drawerFrame.origin.y += 25;
                
            } else { //Move DOWN
                drawerFrame.size.height = drawerSize;
                drawerFrame.size.width = screenWidth;
                drawerFrame.origin.y = screenHeight-drawerSize;
            }
        }
        
        
        //Move the lattice and the menu
        
        IF_IPHONE {
            
            CGRect menuFrame = menu.mainView.frame;
            menuFrame.origin.y -= direction*bannerHeight/2;
            menu.mainView.frame = menuFrame;
            
            CGRect newGameFrame = menu.game.view.frame;
            newGameFrame.origin.y -= direction*bannerHeight/2;
            menu.game.view.frame = newGameFrame;
            
            
            [UIView animateWithDuration:0.5 animations:^{
                
                float f = direction*self.adBannerView.frame.size.height;
                
                lattice.center = CGPointMake(lattice.center.x, lattice.center.y - f);
                
                for (PieceView *p in pieces) {
                    if (!p.isFree) {
                        p.center = CGPointMake(p.center.x, p.center.y - f);
                    }
                }
                
            }];
        }

    } //end if 0 or not 

    
    [UIView animateWithDuration:0.5 animations:^{

        [self refreshPositions];    
        drawerView.frame = drawerFrame;
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
        
    }];
    
}


#pragma mark -
#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        if (puzzleCompete && menu.view.alpha<1) {
            return NO;
        }
        
        return YES;
        
    } else {  
        
        return (interfaceOrientation==UIInterfaceOrientationPortrait);
        
    }    
}

- (CGRect)rotatedFrame:(CGRect)frame {
    
    return CGRectMake(frame.origin.y, frame.origin.x, frame.size.width, frame.size.height);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
        
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    IF_IPAD [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    
    [completedController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //Rotate the drawer
    
    CGRect drawerFrame = drawerView.frame;
    CGRect HUDFrame = HUDView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    CGRect imageFrame = imageView.frame;    
    CGRect statsFrame = completedController.view.frame;    
    CGPoint chooseCenter = CGPointZero;
    CGPoint completedCenter = CGPointZero;
    
    float bannerHeight = self.adBannerView.frame.size.height*self.adBannerView.bannerLoaded;
    
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && !UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        
        drawerFirstPoint = CGPointMake(5, drawerFirstPoint.x);
        
        drawerFrame.size.width = drawerSize;
        drawerFrame.size.height = screenWidth;
        drawerFrame.origin.x = 0;
        drawerFrame.origin.y = -10;


        
        stepperFrame.origin.y = drawerFrame.size.height - stepperFrame.size.height-30;
        stepperFrame.origin.x = drawerFrame.size.width;
        float pad = ([[UIScreen mainScreen] bounds].size.height - imageFrame.size.width)/1;
        imageFrame.origin.x = pad;
        imageFrame.origin.y = 0;
        
        chooseCenter = CGPointMake(self.view.center.x+128, self.view.center.y-425);
        panningSwitch.center = CGPointMake(panningSwitch.center.x+drawerSize, panningSwitch.center.y);
        IF_IPHONE percentageLabel.center = CGPointMake(percentageLabel.center.x+drawerSize, percentageLabel.center.y);
        
        lattice.center = CGPointMake(lattice.center.x+drawerSize, lattice.center.y);
        
        completedCenter = CGPointMake(self.view.center.y, self.view.center.x);
        
        statsFrame = CGRectMake(screenWidth/2-160+10, screenHeight/2-160, statsFrame.size.width, statsFrame.size.height);

        
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && !UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){

        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, 5);
        
        drawerFrame.size.height = drawerSize;
        drawerFrame.size.width = screenWidth;
        drawerFrame.origin.x = 0;
        drawerFrame.origin.y = screenWidth-drawerSize-bannerHeight/2;
        
        stepperFrame.origin.y = drawerFrame.size.height;
        stepperFrame.origin.x = drawerFrame.size.width - stepperFrame.size.width-10;
        imageFrame.origin.y = 0;
        imageFrame.origin.x = 0;
        
        chooseCenter = CGPointMake(self.view.center.x-10, self.view.center.y-290);
        panningSwitch.center = CGPointMake(panningSwitch.center.x-drawerSize, panningSwitch.center.y);
        IF_IPHONE percentageLabel.center = CGPointMake(percentageLabel.center.x-drawerSize, percentageLabel.center.y);
        
        lattice.center = CGPointMake(lattice.center.x-drawerSize, lattice.center.y);
        
        completedCenter = CGPointMake(self.view.center.x, self.view.center.y);
        
        statsFrame = CGRectMake((screenHeight-statsFrame.size.width)/2, screenWidth-240-20, statsFrame.size.width, statsFrame.size.height);
        
        //DLog(@"self.view.center = (%.0f, %.0f)", self.view.center.x, self.view.center.y);

    }
    
    
    [self refreshPositions];    
    
    HUDFrame.origin.x = 0;
    HUDFrame.origin.y = 20;
    
    [UIView animateWithDuration:duration animations:^{
        
        drawerView.frame = drawerFrame;
        stepperDrawer.frame = stepperFrame;
        imageView.frame = imageFrame;
        menu.chooseLabel.center = chooseCenter;
        puzzleCompleteImage.center = completedCenter;
        completedController.view.frame = statsFrame;
        HUDView.frame = HUDFrame;
        
    }];
    
    
    [UIView animateWithDuration:duration animations:^{
        [self organizeDrawerWithOrientation:toInterfaceOrientation];
    }];    
    //DLog(@"FirstPoint = %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);
    
    
    
}

- (void)fuckingRotateTo:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    NSLog(@"Will fucking rotate");
            
    [completedController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    //Rotate the drawer
    
    CGRect drawerFrame = drawerView.frame;
    CGRect HUDFrame = HUDView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    CGRect imageFrame = imageView.frame;    
    CGRect statsFrame = completedController.view.frame;    
    CGPoint chooseCenter = CGPointZero;
    CGPoint completedCenter = CGPointZero;
    
    
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        
        drawerFirstPoint = CGPointMake(5, drawerFirstPoint.x);
        
        drawerFrame.size.width = drawerSize;
        drawerFrame.size.height = screenWidth;
        drawerFrame.origin.x = 0;
        drawerFrame.origin.y = -10;
        
        
        
        stepperFrame.origin.y = drawerFrame.size.height - stepperFrame.size.height-30;
        stepperFrame.origin.x = drawerFrame.size.width;
        float pad = ([[UIScreen mainScreen] bounds].size.height - imageFrame.size.width)/1;
        imageFrame.origin.x = pad;
        imageFrame.origin.y = 0;
        
        chooseCenter = CGPointMake(self.view.center.x+128, self.view.center.y-425);
        panningSwitch.center = CGPointMake(panningSwitch.center.x+drawerSize, panningSwitch.center.y);
        IF_IPHONE percentageLabel.center = CGPointMake(percentageLabel.center.x+drawerSize, percentageLabel.center.y);
        
        lattice.center = CGPointMake(lattice.center.x+drawerSize, lattice.center.y);
        
        completedCenter = CGPointMake(self.view.center.y, self.view.center.x);
        
        statsFrame = CGRectMake(screenWidth/2-160+10, screenHeight/2-160, statsFrame.size.width, statsFrame.size.height);
        
        
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, 5);
        
        drawerFrame.size.height = drawerSize;
        drawerFrame.size.width = screenWidth;
        drawerFrame.origin.x = 0;
        drawerFrame.origin.y = screenWidth;
        
        stepperFrame.origin.y = drawerFrame.size.height;
        stepperFrame.origin.x = drawerFrame.size.width - stepperFrame.size.width-10;
        imageFrame.origin.y = 0;
        imageFrame.origin.x = 0;
        
        chooseCenter = CGPointMake(self.view.center.x-10, self.view.center.y-290);
        panningSwitch.center = CGPointMake(panningSwitch.center.x-drawerSize, panningSwitch.center.y);
        IF_IPHONE percentageLabel.center = CGPointMake(percentageLabel.center.x-drawerSize, percentageLabel.center.y);
        
        lattice.center = CGPointMake(lattice.center.x-drawerSize, lattice.center.y);
        
        completedCenter = CGPointMake(self.view.center.x, self.view.center.y);
        
        statsFrame = CGRectMake((screenHeight-statsFrame.size.width)/2, screenWidth-240-20, statsFrame.size.width, statsFrame.size.height);
        
        //DLog(@"self.view.center = (%.0f, %.0f)", self.view.center.x, self.view.center.y);
        
    }
    
    
    [self refreshPositions];    
    
    HUDFrame.origin.x = 0;
    HUDFrame.origin.y = 20;
    
    [UIView animateWithDuration:duration animations:^{
        
        CGRect rect = drawerFrame;
        NSLog(@"Rect = %.1f, %.1f, %.1f, %.1f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        
        drawerView.frame = drawerFrame;
        stepperDrawer.frame = stepperFrame;
        imageView.frame = imageFrame;
        menu.chooseLabel.center = chooseCenter;
        puzzleCompleteImage.center = completedCenter;
        completedController.view.frame = statsFrame;
        HUDView.frame = HUDFrame;
        
    }];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self organizeDrawerWithOrientation:toInterfaceOrientation];
    }];    
    //DLog(@"FirstPoint = %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);
    
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
      
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    } 
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && 
        [menu.game.popover isPopoverVisible]
        ) {
        
        [menu.game.popover dismissPopoverAnimated:NO];
        CGRect rect = CGRectMake(menu.game.view.center.x, -20, 1, 1);
        [menu.game.popover presentPopoverFromRect:rect inView:menu.game.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];        
    }
    
    didRotate = YES;
    
}



#pragma mark -
#pragma mark Tools

- (IBAction)togglePanningMode:(id)sender {
    
    if (panningMode) {
        
        for (PieceView *p in pieces) {
            if (p.isFree && !p.isPositioned) {
                p.userInteractionEnabled = YES;
            }
        }

        panningSwitch.alpha = 0.5;
        panningMode = NO;
        
    } else {
        
        for (PieceView *p in pieces) {
            if (p.isFree) {
                p.userInteractionEnabled = NO;
            }
        }

        panningSwitch.alpha = 1;
        panningMode = YES;
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
    
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"PiecePositioned" ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    positionedSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    positionedSound.volume = 0.3;
    [positionedSound prepareToPlay];
    
    if ([positionedSound respondsToSelector:@selector(setEnableRate:)]) {
        positionedSound.enableRate = YES;
        positionedSound.rate = 1.5; 
    }
    
    soundPath =[[NSBundle mainBundle] pathForResource:@"PuzzleCompleted" ofType:@"mp3"];
    soundURL = [NSURL fileURLWithPath:soundPath];   
    completedSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [completedSound prepareToPlay];

    soundPath =[[NSBundle mainBundle] pathForResource:@"NeighborFound" ofType:@"wav"];
    soundURL = [NSURL fileURLWithPath:soundPath];   
    neighborSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    [neighborSound prepareToPlay];

}

- (CGPoint)applyMatrix:(CGAffineTransform)matrix toVector:(CGPoint)vector {
    
    return CGPointMake(matrix.a*vector.x+matrix.b*vector.y, matrix.c*vector.x+matrix.d*vector.y);
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
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

- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
    
    for (int i=0; i<NumberSquare; i++) {          
        PieceView *p = [pieces objectAtIndex:i];            
        CGRect rect = p.frame;
        rect.origin.x = piceSize*i+drawerMargin;
        rect.origin.y = screenHeight-drawerSize+5;
        p.frame = rect;
        
        int r = arc4random_uniform(4);
        p.transform = CGAffineTransformMakeRotation(r*M_PI/2);
        p.angle = r*M_PI/2;
        //DLog(@"angle=%.1f", p.angle);
    }
    
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

- (void)shuffleAngles {
    
    for (int i=0; i<NumberSquare; i++) {          

        PieceView *p = [pieces objectAtIndex:i];            
        if (!p.isFree) {
            
            int r = arc4random_uniform(4);
            p.transform = CGAffineTransformMakeRotation(r*M_PI/2);
            p.angle = r*M_PI/2;
        }
    }
    
}

- (void)computePieceSize {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        piceSize = PIECE_SIZE_IPAD;
        
    }else{  
        
        piceSize = PIECE_SIZE_IPHONE;
        
    }
    
    self.padding = piceSize*0.15;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        drawerSize = piceSize+1.8*self.padding-15;   
    else   
        drawerSize = piceSize+1.8*self.padding-10;
    
    
    numberOfPiecesInDrawer = screenWidth/(piceSize+1);
    float unusedSpace = screenWidth - numberOfPiecesInDrawer*piceSize;
    drawerMargin = (float)(unusedSpace/(numberOfPiecesInDrawer+1));
    
    firstPiecePlace =  3*NumberSquare+pieceNumber;
    
    //DLog(@"n = %d, %.1f", n, drawerMargin);
    
    
}

- (void)bringDrawerToTop {
    
    for (PieceView *p in pieces) {
        if (p.isFree && !p.isPositioned) {
            
            [self.view bringSubviewToFront:p];
        }
    }
    
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:HUDView];
        
    for (PieceView *p in pieces) {
        if (!p.isFree) {

            [self.view bringSubviewToFront:p];
        }
    }
    
    [self.view bringSubviewToFront:self.adBannerView];


//    [self.view bringSubviewToFront:stepperDrawer];
//    [self.view bringSubviewToFront:firstPointView];

    
}

- (void)updatePercentage {
    
    puzzleDB.percentage = [NSNumber numberWithFloat:[self completedPercentage]];
    percentageLabel.text = [NSString stringWithFormat:@"%.0f %%", [self completedPercentage]];
}

- (void)removeOldPieces {
    
    for (int i = 0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        [p removeFromSuperview];    
        p = nil;
    }
    
    for (UIView *v in groups) {
        [v removeFromSuperview];
    }
    
    
    //pieces = nil;
    
}

- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    receivedFirstTouch = YES;
    
    if(imageView.alpha == 1) {
        [self toggleImageWithDuration:0.5];
    }
}

- (float)completedPercentage {
    
    float positioned = 0.0;
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.isPositioned) {
            positioned += 1.0;
        }
    }
    
    return (positioned/NumberSquare*100);
    
}

- (IBAction)rateGame {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (![prefs boolForKey:@"Reviewed"]) {
        
        alertView = [[UIAlertView alloc] initWithTitle:@"Give your opinion!" message:@"Do you like this game? Give us\n★★★★★!\nDo you have any suggestions?\nWrite a review and we will try to improve the app to fulfill your desires." delegate:self cancelButtonTitle:@"No thanks" otherButtonTitles:@"Sure!", nil];
        [alertView show];
        
    } else {
        
        DLog(@"Already rated");
    }
    
}

- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setBool:YES forKey:@"Reviewed"];
        
        
        [alertView_ dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", APP_STORE_APP_ID];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        
    }
    
}

- (void)print_free_memory {
    
#ifdef FRACTAL_DEBUG
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");;
    
    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used/ 100000, mem_free/ 100000, mem_total/ 100000);
#endif
}

+ (float)computeFloat:(float)f modulo:(float)m {

    float result = f - floor((f)/m)*m;

    if (result>m-0.2) result = 0;

    if (result<0) result = 0;
    
    return result;

}



#pragma mark -
#pragma mark Timer

- (void)oneSecondElapsed {
    
    elapsedTime += 0.1;
    puzzleDB.elapsedTime = [NSNumber numberWithFloat:elapsedTime];
    
    
    int seconds = (int)elapsedTime%60;
    int minutes = (int)elapsedTime/60;
    
    
    if (elapsedTime - (int)elapsedTime < 0.1) {
        
        elapsedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]; 
    }    
    
    //DLog(@"%d, %f", (int)elapsedTime, elapsedTime);
    
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
    
    puzzleCompete = NO;
    
    [self removeOldPieces];
    
    groups = nil;
    pieces = nil;
    groups = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    pieces = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    
    
    [self createPuzzleFromImage:image];
    
    receivedFirstTouch = NO;    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        lattice.frame = [self frameForLatticeWithOrientation:self.interfaceOrientation];
        
    }];
    
}



#pragma mark -
#pragma mark Unuseful

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    return;
    
    if (motion == UIEventSubtypeMotionShake)
    {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        
    [self refreshPositions];
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

@end
