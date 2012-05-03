//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#define PIECE_NUMBER 4
#define ORG_TIME 0.5
#define QUALITY 1


#import "PuzzleController.h"
#import "UIImage+CWAdditions.h"
#import "AppDelegate.h"


@interface PuzzleController ()

@end


@implementation PuzzleController

@synthesize pieces, image, piceSize, lattice, N, pieceNumber, imageView, positionedSound, completedSound, imageViewLattice, menu, loadedPieces, pan, panDrawer, drawerView, managedObjectContext, menuButtonView;


- (BOOL)saveGame {
    
    
    if (puzzleDB==nil) {
        
        [self createPuzzleIntDB];
        
    }
    
    puzzleDB.lastSaved = [NSDate date];
    
    if ([managedObjectContext save:nil]) {
        //NSLog(@"Puzzle saved");
    }
    
    return YES;
    
}


- (BOOL)piece:(PieceView*)piece isInFrame:(CGRect)frame {
    
    return frame.origin.x<[piece realCenter].x && frame.origin.y<[piece realCenter].y;
    
}

#import <mach/mach.h>
#import <mach/mach_host.h>

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


- (BOOL)isPuzzleComplete {
        
    for (PieceView *p in pieces) {
        if (!p.isPositioned) {
            //NSLog(@"Piece #%d is not positioned", p.number);
            
            return NO;
        }
    }
    
    [self puzzleCompleted];
    
    return YES;
    
}

- (void)toggleImage:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan && menu.view.alpha == 0) {
        
        [self toggleImageWithDuration:0.5];
    }
    
}
- (void)toggleImageWithDuration:(float)duration {
    
    [UIView animateWithDuration:duration animations:^{
        if (imageViewLattice.alpha==0) {
            
            menuButtonView.userInteractionEnabled = NO;
            [self.view bringSubviewToFront:imageView];
            imageViewLattice.alpha = 1;
            
        } else if (imageViewLattice.alpha==1) {
            
            menuButtonView.userInteractionEnabled = YES;
            imageViewLattice.alpha = 0;
        }
    }];
    
}

- (void)puzzleCompleted {
    
    //imageView.frame = lattice.bounds;
    
    [self.view bringSubviewToFront:lattice];
    for (UIView *v in lattice.pieces) {
        v.alpha = 0;
    }
    
    [UIView animateWithDuration:1 animations:^{
        
        imageViewLattice.alpha = 1;

    }];

    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying) {
    
        [completedSound play];

    }
}

- (void)computePieceSize {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        piceSize = 180;
        biggerPieceSize = 360;
        
    }else{  
        
        piceSize = 100;
        biggerPieceSize = 200;
        
    }
    
    self.padding = piceSize*0.15;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        drawerSize = piceSize+1.8*self.padding-15;   
    else   
        drawerSize = piceSize+1.8*self.padding+5;
    
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int n = screenWidth/(piceSize+1);
    float unusedSpace = screenWidth - n*piceSize;
    drawerMargin = (float)(unusedSpace/(n+1));
    
    //NSLog(@"n = %d, %.1f", n, drawerMargin);
    
    
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
        
        return (!( r==2 && (piece.position+1)%pieceNumber==0 )             //bottom piece checking down
        && !( r==0 && (piece.position)%pieceNumber==0 )               //top piece checking up
        && !( r==1 && pieceNumber%(piece.position+1)==0 )             //right piece checking right
        && !( r==3 && pieceNumber%(piece.position)==pieceNumber-1 ));   //left piece checking left
    
    } else {
        return (r==1 || r==2);
    }
    
}

- (void)checkNeighborsForAllThePieces {
    
    for (PieceView *p in pieces) {
        if (p.isFree) {
            [self checkNeighborsOfPieceNumber:p];
        }
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
        
        //NSLog(@"r=%d, rotation = %d", r, rotation);
        
        
        //Looks for neighbors
        
        
        
        
        if (j+i>=0 && j+i<N && [self shouldCheckNeighborsOfPiece:piece inDirection:r] ){
            
            
            otherPiece = [self pieceAtPosition:j+i];
            
            //NSLog(@"j+i = %d ; numbers are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d",j+i, piece.number+l, otherPiece.number,  piece.number, otherPiece.number, direction, rotation, r);    
            
            //NSLog(@"Checking position %d, number+l = %d, otherPiece.number = %d", piece.number+i, piece.number+l, otherPiece.number);
            
            if (otherPiece != nil) {
                
                if (piece.isFree && otherPiece.isFree) {
                    
                    //NSLog(@"Angles are %.1f (piece) and %.1f (other)", piece.angle, otherPiece.angle);
                    
                    
                    if (piece.number+l==otherPiece.number) {
                        
                        
                        if ((ABS(piece.angle-otherPiece.angle)<M_PI/4)) {
                            
                            [otherPiece setNeighborNumber:piece.number forEdge:(direction+2)%4];
                            [piece setNeighborNumber:otherPiece.number forEdge:direction%4];
                            
                            piece.hasNeighbors = YES;
                            otherPiece.hasNeighbors = YES;
                            
                        } else {
                            //NSLog(@"0 Wrong angles. They are %.1f and %.1f for pieces #%d and #%d", piece.angle, otherPiece.angle, piece.number, otherPiece.number);
                        }
                    } else {
                        //NSLog(@"-------> Wrong numbers. They are %d and %d for pieces #%d, and #%d. Direction = %d, rotation = %d, r = %d", piece.number+l, otherPiece.number, piece.number, otherPiece.number, direction, rotation, r);
                        
                    }
                    
                }
                
            }else {
                
                //NSLog(@"NIL");
                
            }
            
            
        }
        
    }
    
    //NSLog(@"\n");
    
}

- (CGRect)frameOfLatticePiece:(int)i {
    
    
    UIView *v = [lattice objectAtIndex:i];
    
    return CGRectMake(
                      lattice.frame.origin.x + lattice.scale*(v.frame.origin.x-self.padding)-1*lattice.scale,
                      lattice.frame.origin.y + lattice.scale*(v.frame.origin.y-self.padding)-1*lattice.scale, 
                      lattice.scale*piceSize, 
                      lattice.scale*piceSize);
    
}

- (BOOL)isPositioned:(PieceView*)piece  {
        
    if (piece.isFree && piece.number == piece.position && ABS(piece.angle) < 1) {
        
        //NSLog(@"Piece #%d positioned!", piece.number);
        //Flashes and block the piece
        if (!piece.isPositioned) {
            piece.isPositioned = YES;
            piece.userInteractionEnabled = NO;
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
    
    if (animated) {
        
        [UIView animateWithDuration:0.5 animations:^{
        
            piece.frame = [self frameOfLatticePiece:i];
        
        }completion:^(BOOL finished) {
            
            if (!piece.isPositioned) {
                [self isPositioned:piece];
            }
            [self checkNeighborsOfPieceNumber:piece];
            [self updatePercentage];
            [self updatePieceDB:piece];
        }];
        
    } else {
        
        piece.frame = [self frameOfLatticePiece:i];
        if (!piece.isPositioned) {
            [self isPositioned:piece];
        }

    }
    
    
    piece.position = i;
    piece.oldPosition = [piece realCenter];
    
    
}

- (void)bringDrawerToTop {
    
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:stepperDrawer];
    [self.view bringSubviewToFront:menuButtonView];
    [self.view bringSubviewToFront:percentageLabel];
    
    for (PieceView *p in pieces) {
        if (!p.isFree) {
            [self.view bringSubviewToFront:p];
        }
    }
    
}

- (void)pieceMoved:(PieceView *)piece {
    
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
            [UIView animateWithDuration:0.5 animations:^{
                
                CGRect rect = CGRectMake(piece.frame.origin.x, piece.frame.origin.y, piceSize, piceSize);
                piece.frame = rect;
                
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
    
    [UIView animateWithDuration:0.5 animations:^{
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
    }];
    
    [self bringDrawerToTop];
    
    piece.oldPosition = [piece realCenter];
    //NSLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);

    
    
    
    //[self isPositioned:piece];

    
}

- (void)updatePercentage {
    
    puzzleDB.percentage = [NSNumber numberWithFloat:[self completedPercentage]];
    percentageLabel.text = [NSString stringWithFormat:@"%.0f %%", [self completedPercentage]];
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
    
    for (PieceView *p in [piece allTheNeighborsBut:nil]) {
        p.oldPosition = [p realCenter];
        p.position = [self positionOfPiece:p];
    }
    piece.oldPosition = [piece realCenter];
    piece.position = [self positionOfPiece:piece]; 
    
    
    //NSLog(@"Position for piece #%d is %d", piece.number, piece.position);
    
    //NSLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);
    
    [self isPositioned:piece];
    [self checkNeighborsOfPieceNumber:piece];
    
    [self updatePieceDB:piece];
    [self updatePercentage];
    
}

- (void)refreshPositions {
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.position>-1) {
            [self movePiece:p toLatticePoint:p.position animated:NO];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer*)gesture {

    if (menu.view.alpha == 0) {
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        if (ABS(traslation.x>0.03) || ABS(traslation.y) > 0.03) {
            
            lattice.center = CGPointMake(lattice.center.x - traslation.x, lattice.center.y - traslation.y);            
            [self refreshPositions];
            [gesture setTranslation:CGPointZero inView:lattice.superview];
        }
    }
    
}

- (void)panDrawer:(UIPanGestureRecognizer*)gesture {
    
    if (menu.view.alpha == 0) {
        
        CGPoint traslation = [gesture translationInView:lattice.superview];
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            
            if (ABS(traslation.x>0.01) || ABS(traslation.y) > 0.01) {
                
                drawerFirstPoint.y += [gesture velocityInView:self.view].y/25;
                [gesture setTranslation:CGPointMake(traslation.x, 0) inView:lattice.superview];                
            }
            
        } else {
            
            if (ABS(traslation.x>0.01) || ABS(traslation.y) > 0.01) {
                
                drawerFirstPoint.x += [gesture velocityInView:self.view].x/25;
                [gesture setTranslation:CGPointMake(0, traslation.y) inView:lattice.superview];     
            }
        }
        
        
        [self organizeDrawerWithOrientation:self.interfaceOrientation];

        
    }
    
}

- (void)setup {
    
    
    pieceNumber = PIECE_NUMBER;
    N = pieceNumber*pieceNumber;
    
    //[self computePieceSize];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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

- (UIImage*)clipImage:(UIImage*)img toRect:(CGRect)rect {
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return newImage;
    
}


- (UIImage*)resizeImage:(UIImage*)img toSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, rect);
    //drawImage = CreateCGImageFromUIImageScaled(img, size.width/img.size.width);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return newImage;
    
}


- (NSArray *)splitImage:(UIImage *)im{
    
    float x = pieceNumber;
    float y= pieceNumber;
    
    //CGSize size = [im size];
    //NSLog(@"Size = %.1f, %.1f", size.width, size.height);
    //NSLog(@"Splitting image, Piece size = %.1f, number of pieces = %d", piceSize, pieceNumber*pieceNumber);

    //float f = (float)(pieceNumber*QUALITY*(piceSize-2*self.padding));


    float w = im.size.width/(pieceNumber*QUALITY*0.7);

    float ww = w*0.15;

    
    
    loadedPieces = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:N];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            
            CGRect portion = CGRectMake(i * (w-2*ww)-ww, j * (w-2*ww)-ww, w, w);
            //NSLog(@"Rect = %.1f, %.1f, %.1f, %.1f",i*(w-2*ww)-ww, j*(w-2*ww)-ww, w, w);

            [arr addObject:[self clipImage:im toRect:portion]];            
            //[arr addObject:[im subimageWithRect:portion]];            
        }
    }
    
    //NSLog(@"All the images splitted");

    
    return arr;
    
}

- (void)removeOldPieces {
        
    for (int i = 0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        [p removeFromSuperview];    
        p = nil;
    }
    

    //pieces = nil;
    
}

- (Piece*)pieceOfCurrentPuzzleDB:(int)n {
            
    for (Piece *p in puzzleDB.pieces) {
        if ([p.number intValue]==n) {
            return p;
        }
    }
    
    NSLog(@"------>  Piece #%d is NIL!", n);
        
    return nil;
    
}

- (void)loadPuzzle {
    
    if (managedObjectContext!=nil) {
        
        NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Puzzle"  inManagedObjectContext: managedObjectContext];
        
        [fetchRequest1 setEntity:entity];
        
        NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"lastSaved" ascending:NO];
        [fetchRequest1 setSortDescriptors:[NSArray arrayWithObject:dateSort]];
        dateSort = nil;
        
        [fetchRequest1 setFetchLimit:1];
        
        puzzleDB = [[managedObjectContext executeFetchRequest:fetchRequest1 error:nil] lastObject];
        fetchRequest1 = nil;
                
        [self setPieceNumber:[puzzleDB.pieceNumber intValue]];

        if (pieceNumber>0) {

            [self createPuzzleFromSavedGame];
            [menu toggleMenu];
        }
        
    }
    
}

- (void)createPuzzleFromSavedGame {
    
    loadingGame =YES;
    
    [self computePieceSize];
    [self createLattice];
    
    drawerFirstPoint = CGPointMake(-self.padding/2+10, -self.padding/2+10);
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    float f = (float)(pieceNumber*QUALITY*(piceSize-2*self.padding));

    
    NSLog(@"Piece number %d, piece size %.1f, f = %.1f, padding = %.1f", pieceNumber, piceSize, f, self.padding);
    
    image = [UIImage imageWithData:puzzleDB.image.data];

    float w = image.size.width;
    
    image = [[UIImage imageWithCGImage:[image CGImage] scale:w/f orientation:1] imageRotatedByDegrees:0];

    NSLog(@"New size = %.1f, f=%.1f, w= %.1f", image.size.width, f, w);
    
    imageView.image = image;
    imageViewLattice.image = image;
    
    if (image==nil) {
        return;
    }
    
    
    //UIImage *img = [[self class] imageWithImage:image_ scaledToSize:CGSizeMake(f, f)];
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    
    
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self splitImage:image]];
    NSLog(@"Pieces:%d", [array count]);
    
    
    
    for (int i=0;i<pieceNumber;i++){
        for (int j=0;j<pieceNumber;j++){
            
            CGRect portion = CGRectMake(
                                        i * QUALITY*(piceSize-2*self.padding)-QUALITY*self.padding,
                                        j * QUALITY*(piceSize-2*self.padding)-QUALITY*self.padding, 
                                        QUALITY*piceSize, 
                                        QUALITY*piceSize);
            
            
            Piece *pieceDB = [self pieceOfCurrentPuzzleDB:j+pieceNumber*i];
            
            if (pieceDB!=nil) {
                
                PieceView *piece = [[PieceView alloc] initWithFrame:portion padding:self.padding];
                piece.delegate = self;
                piece.image = [array objectAtIndex:j+pieceNumber*i];
                piece.number = j+pieceNumber*i;
                piece.size = piceSize;
                piece.isFree = (BOOL)pieceDB.isFree;
                piece.position = [pieceDB.position intValue];
                piece.angle = [pieceDB.angle floatValue];
                piece.transform = CGAffineTransformMakeRotation(piece.angle);
                
                CGRect rect = CGRectMake(piece.frame.origin.x, piece.frame.origin.y, piceSize, piceSize);
                piece.frame = rect;

                NSNumber *n = [NSNumber numberWithInt:N];
                piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
                
                
                NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
                [a addObject:pieceDB.edge0];
                [a addObject:pieceDB.edge1];
                [a addObject:pieceDB.edge2];
                [a addObject:pieceDB.edge3];
                
                piece.edges = [NSArray arrayWithArray:a];
                
                for (int k=0; k<4; k++) {
                    //NSLog(@"Edge of %d, %d is %d", i, j, [[piece.edges objectAtIndex:k] intValue]);
                }
                
                
                [arrayPieces addObject:piece];
                [piece setNeedsDisplay];
                [self.view addSubview:piece];

                
            }
            
        }
    }
    
    pieces = [[NSArray alloc] initWithArray:arrayPieces];
    
    
    BOOL debugging = NO;
    
    if (debugging) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            p.isPositioned = YES;
            p.userInteractionEnabled = NO;
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        [imageViewLattice removeFromSuperview];
        
    } else {
        pieces = [self shuffleArray:pieces];
        [self refreshPositions];
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
        [self bringDrawerToTop];
        [self checkNeighborsForAllThePieces];
        [self updatePercentage];
        loadingGame = NO;
    }
    
}

- (void)createPuzzleIntDB {
    
    NSLog(@"Starting creating puzzle in the DB");
    
    NSManagedObjectContext *tempContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    puzzleDB = [self newPuzzleInCOntext:tempContext];
    Image *imageDB = [self newImageInCOntext:tempContext];
    imageDB.data = UIImageJPEGRepresentation(image, 1);
    puzzleDB.image = imageDB;
    puzzleDB.pieceNumber = [NSNumber numberWithInt:pieceNumber];
    
    for (PieceView *piece in pieces) {
        
        //Creating the piece in the database
        Piece *pieceDB = [self newPieceInCOntext:tempContext];
        pieceDB.puzzle = puzzleDB;
        pieceDB.number = [NSNumber numberWithInt:piece.number];
        pieceDB.position = [NSNumber numberWithInt:piece.position];
        pieceDB.angle = [NSNumber numberWithFloat:piece.angle];
        
        pieceDB.edge0 = [piece.edges objectAtIndex:0];
        pieceDB.edge1 = [piece.edges objectAtIndex:1];
        pieceDB.edge2 = [piece.edges objectAtIndex:2];
        pieceDB.edge3 = [piece.edges objectAtIndex:3];
        
        loadedPieces++;

    }
    
    
}

- (void)createPuzzleFromImage:(UIImage*)image_ {
    
    
    puzzleDB = nil;
    
    NSLog(@"Memory b4 creating:");
    
    [self print_free_memory];

    [self computePieceSize];
    [self createLattice];
    
    drawerFirstPoint = CGPointMake(-self.padding/2+10, -self.padding/2+10);
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    
    
    
    //NSLog(@"Piece number %d, piece size %.1f, f = %.1f, padding = %.1f", pieceNumber, piceSize, f, self.padding);

    

    
    //This is fucking leaking!
        
    UIImage *img = image_;
    //img = [image_ resizedImage:CGSizeMake(f, f) interpolationQuality:1];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self splitImage:img]];
    
    //img = nil;

    
    //UIImage *img = [[self class] imageWithImage:image_ scaledToSize:CGSizeMake(f, f)];
    
    
    //NSLog(@"\n\n\n DC \n\n\n");
    //[self print_free_memory];
    
    //UIImage *img = [[self class] imageWithImage:image_ scaledToSize:CGSizeMake(f, f)];
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    

    
    
    for (int i=0;i<pieceNumber;i++){
    
        
        for (int j=0;j<pieceNumber;j++){
            
            CGRect portion = CGRectMake(
                                        i * QUALITY*(piceSize-2*self.padding)-QUALITY*self.padding,
                                        j * QUALITY*(piceSize-2*self.padding)-QUALITY*self.padding, 
                                        QUALITY*piceSize, 
                                        QUALITY*piceSize);
            
                        
            PieceView *piece = [[PieceView alloc] initWithFrame:portion padding:self.padding];
            piece.delegate = self;
            piece.image = [array objectAtIndex:j+pieceNumber*i];
            piece.number = j+pieceNumber*i;
            piece.size = piceSize;
            piece.position = -1;
            NSNumber *n = [NSNumber numberWithInt:N];
            piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
            
            CGRect rect = CGRectMake(piece.frame.origin.x, piece.frame.origin.y, piceSize, piceSize);
            piece.frame = rect;

            
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
                //NSLog(@"e = %d", e);
            }
            
            if (j>0) {
                int e = [[[[arrayPieces lastObject] edges] objectAtIndex:2] intValue];
                [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:-e]];
                //NSLog(@"e = %d", e);
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
            
            for (int k=0; k<4; k++) {
                //NSLog(@"Edge of %d, %d is %d", i, j, [[piece.edges objectAtIndex:k] intValue]);
            }
            
            
            [arrayPieces addObject:piece];
            [piece setNeedsDisplay];
            [self.view addSubview:piece];
            loadedPieces++;

            
        }
    }
    
    pieces = [[NSArray alloc] initWithArray:arrayPieces];


    BOOL debugging = NO;
    
    if (debugging) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            p.isPositioned = YES;
            p.userInteractionEnabled = NO;
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        [imageViewLattice removeFromSuperview];
        
    } else {
        [self shuffle];
        [self updatePercentage];
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
        [self createPuzzleIntDB];
    }
    
    NSLog(@"Memory after creating:");
    [self print_free_memory];
        
}

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

- (void)pinch:(UIPinchGestureRecognizer*)gesture {

    float z = [gesture scale];

    if (z>1.03 || z < 0.97) {
        
        [self adjustAnchorPointForGestureRecognizer:gesture];
        
        
        CGSize screen = [[UIScreen mainScreen] bounds].size;
        
        if (lattice.scale*z*pieceNumber*piceSize>piceSize && lattice.scale*z*piceSize<screen.width) {
            
            lattice.scale *= z;
            lattice.transform = CGAffineTransformScale(lattice.transform, z, z);
        }
        
        [self refreshPositions];        
        
        [gesture setScale:1];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    drawerView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    [self loadSounds];
    [self computePieceSize];
    
    //Add the image;
    image = [UIImage imageNamed:@"Cover.png"];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    rect = CGRectMake(0, (rect.size.height-rect.size.width)/1, rect.size.width, rect.size.width);
    imageView.frame = rect;
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    
    imageViewLattice = [[UIImageView alloc] initWithImage:image];
    

    
    //Resize the drawer
    CGRect drawerFrame = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        NSLog(@"Landscape!");
        
        drawerFrame.size.width = drawerSize;
        drawerFrame.size.height = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = 10;
        stepperFrame.origin.x = drawerFrame.size.width;
        
    } else {
        
        drawerFrame.size.height = drawerSize;
        drawerFrame.size.width = [[UIScreen mainScreen] bounds].size.height;
        stepperFrame.origin.y = drawerFrame.size.height;
        stepperFrame.origin.x = 10;
    }
    
    drawerView.frame = drawerFrame;
    stepperDrawer.frame = stepperFrame;
    
    
    //Add the meu
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
    
    
    UILongPressGestureRecognizer *longPressure = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImage:)];
    [longPressure setMinimumPressDuration:1.1];
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

- (void)organizeDrawerWithOrientation:(UIImageOrientation)orientation {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:pieces];
    
    if ([temp count] == 0) {
        return;
    }
    
    
    //Removes removed pieces
    for (int i=0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        if (p.isFree) {
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

            if (!didRotate) {
                rect.origin.y += 20;
            }
            
            p.frame = rect;
            
            p.isLifted = NO;
            

        }
    //}];
    
    
    
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

- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}

- (IBAction)toggleMenu:(id)sender {

    menu.duringGame = YES;
    [self.view bringSubviewToFront:menu.obscuringView];
    [self.view bringSubviewToFront:menu.view];
    [self.view bringSubviewToFront:menuButtonView];
    
    [menu toggleMenu];
    
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


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            //NSLog(@"Shuffle!");
            //[self shuffle];
            
        }];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}



+ (float)float:(float)f modulo:(float)m {

return f - floor(f/m)*m;

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

- (IBAction)pieceNumberChanged:(UIStepper*)sender {
    
    pieceNumber = floorf(sender.value);
    N = pieceNumber*pieceNumber;
    
    NSLog(@"Piece number=%d", pieceNumber);
    NSLog(@"N = %.1f", N);
    
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


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{       
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    //Rotate the drawer
    
    CGRect rect = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        drawerFirstPoint = CGPointMake(5, drawerFirstPoint.x);
        
        rect.size.width = drawerSize;
        rect.size.height = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = rect.size.height - stepperFrame.size.height-30;
        stepperFrame.origin.x = rect.size.width;
                
    } else {
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, 5);
        
        rect.size.height = drawerSize;
        rect.size.width = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = rect.size.height;
        stepperFrame.origin.x = rect.size.width - stepperFrame.size.width-10;
    }
    
    lattice.frame = CGRectMake(lattice.frame.origin.y, lattice.frame.origin.x, lattice.bounds.size.width, lattice.bounds.size.height);
    [self refreshPositions];
    
    
    if (!receivedFirstTouch) {
        
        [UIView animateWithDuration:duration animations:^{

            lattice.frame = [self frameForLatticeWithOrientation:toInterfaceOrientation];
            
        }];
        
    }
    
    
    
    
    [UIView animateWithDuration:duration animations:^{
        
        drawerView.frame = rect;
        stepperDrawer.frame = stepperFrame;

    }];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self organizeDrawerWithOrientation:toInterfaceOrientation];
    }];    
    //NSLog(@"FirstPoint = %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);

    
    //Center the board
    

    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    
    didRotate = YES;
    
    CGRect rect = imageView.frame;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        float pad = ([[UIScreen mainScreen] bounds].size.height - rect.size.width)/1;
        rect.origin.x = pad;
        rect.origin.y = 0;
        
    } else {
        
        float pad = ([[UIScreen mainScreen] bounds].size.height - rect.size.height)/1;
        rect.origin.y = pad;
        rect.origin.x = 0;
    }   
    
    imageView.frame = rect;
    

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    receivedFirstTouch = YES;
    
    if(imageViewLattice.alpha == 1) {
        [self toggleImageWithDuration:0.5];
    }
}

- (void)startNewGame {
    
    //NSLog(@"Starting a new game");
        
    [self createPuzzleFromImage:image];
    

    
    receivedFirstTouch = NO;
    [self bringDrawerToTop];
    
    

    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        lattice.frame = [self frameForLatticeWithOrientation:self.interfaceOrientation];
        
    }];
    
    //NSLog(@"Puzzle created");

    [menu.game gameStarted];
    
    
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





const double		kRadPerDeg	= 0.0174532925199433;	// pi / 180

const CGBitmapInfo kDefaultCGBitmapInfo	= (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
const CGBitmapInfo kDefaultCGBitmapInfoNoAlpha	= (kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host);

CGColorSpaceRef	GetDeviceRGBColorSpace() {
	static CGColorSpaceRef	deviceRGBSpace	= NULL;
	if( deviceRGBSpace == NULL )
		deviceRGBSpace	= CGColorSpaceCreateDeviceRGB();
	return deviceRGBSpace;
}

float GetScaleForProportionalResize( CGSize theSize, CGSize intoSize, bool onlyScaleDown, bool maximize )
{
	float	sx = theSize.width;
	float	sy = theSize.height;
	float	dx = intoSize.width;
	float	dy = intoSize.height;
	float	scale	= 1;
	
	if( sx != 0 && sy != 0 )
	{
		dx	= dx / sx;
		dy	= dy / sy;
		
		// if maximize is true, take LARGER of the scales, else smaller
		if( maximize )		scale	= (dx > dy)	? dx : dy;
		else				scale	= (dx < dy)	? dx : dy;
		
		if( scale > 1 && onlyScaleDown )	// reset scale
			scale	= 1;
	}
	else
	{
		scale	 = 0;
	}
	return scale;
}

CGContextRef CreateCGBitmapContextForWidthAndHeight( unsigned int width, unsigned int height, 
													CGColorSpaceRef optionalColorSpace, CGBitmapInfo optionalInfo )
{
	CGColorSpaceRef	colorSpace	= (optionalColorSpace == NULL) ? GetDeviceRGBColorSpace() : optionalColorSpace;
	CGBitmapInfo	alphaInfo	= ( (int32_t)optionalInfo < 0 ) ? kDefaultCGBitmapInfo : optionalInfo;
	return CGBitmapContextCreate( NULL, width, height, 8, 0, colorSpace, alphaInfo );
}

CGImageRef CreateCGImageFromUIImageScaled( UIImage* image, float scaleFactor )
{
	CGImageRef			newImage		= NULL;
	CGContextRef		bmContext		= NULL;
	BOOL				mustTransform	= YES;
	CGAffineTransform	transform		= CGAffineTransformIdentity;
	UIImageOrientation	orientation		= image.imageOrientation;
	
	CGImageRef			srcCGImage		= CGImageRetain( image.CGImage );
	
	size_t width	= CGImageGetWidth(srcCGImage) * scaleFactor;
	size_t height	= CGImageGetHeight(srcCGImage) * scaleFactor;
	
	// These Orientations are rotated 0 or 180 degrees, so they retain the width/height of the image
	if( (orientation == UIImageOrientationUp) || (orientation == UIImageOrientationDown) || (orientation == UIImageOrientationUpMirrored) || (orientation == UIImageOrientationDownMirrored)  )
	{	
		bmContext	= CreateCGBitmapContextForWidthAndHeight( width, height, NULL, kDefaultCGBitmapInfo );
	}
	else	// The other Orientations are rotated ±90 degrees, so they swap width & height.
	{	
		bmContext	= CreateCGBitmapContextForWidthAndHeight( height, width, NULL, kDefaultCGBitmapInfo );
	}
	
	//CGContextSetInterpolationQuality( bmContext, kCGInterpolationLow );
	CGContextSetBlendMode( bmContext, kCGBlendModeCopy );	// we just want to copy the data
	
	switch(orientation)
	{
		case UIImageOrientationDown:		// 0th row is at the bottom, and 0th column is on the right - Rotate 180 degrees
			transform	= CGAffineTransformMake(-1.0, 0.0, 0.0, -1.0, width, height);
			break;
			
		case UIImageOrientationLeft:		// 0th row is on the left, and 0th column is the bottom - Rotate -90 degrees
			transform	= CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, height, 0.0);
			break;
			
		case UIImageOrientationRight:		// 0th row is on the right, and 0th column is the top - Rotate 90 degrees
			transform	= CGAffineTransformMake(0.0, -1.0, 1.0, 0.0, 0.0, width);
			break;
			
		case UIImageOrientationUpMirrored:	// 0th row is at the top, and 0th column is on the right - Flip Horizontal
			transform	= CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, width, 0.0);
			break;
			
		case UIImageOrientationDownMirrored:	// 0th row is at the bottom, and 0th column is on the left - Flip Vertical
			transform	= CGAffineTransformMake(1.0, 0.0, 0, -1.0, 0.0, height);
			break;
			
		case UIImageOrientationLeftMirrored:	// 0th row is on the left, and 0th column is the top - Rotate -90 degrees and Flip Vertical
			transform	= CGAffineTransformMake(0.0, -1.0, -1.0, 0.0, height, width);
			break;
			
		case UIImageOrientationRightMirrored:	// 0th row is on the right, and 0th column is the bottom - Rotate 90 degrees and Flip Vertical
			transform	= CGAffineTransformMake(0.0, 1.0, 1.0, 0.0, 0.0, 0.0);
			break;
			
		default:
			mustTransform	= NO;
			break;
	}
	
	if( mustTransform )	CGContextConcatCTM( bmContext, transform );
	
	CGContextDrawImage( bmContext, CGRectMake(0.0, 0.0, width, height), srcCGImage );
	CGImageRelease( srcCGImage );
	newImage = CGBitmapContextCreateImage( bmContext );
	CFRelease( bmContext );
	
	return newImage;
}

UIImage* UImageFromPathScaledToSize(NSString* path, CGSize toSize)
{
	UIImage	*scaledImg	= nil;
	UIImage	*img = [[UIImage alloc] initWithContentsOfFile:path];	// get the image
	
	if( img )
	{
		float	scale	= GetScaleForProportionalResize( img.size, toSize, false, false );
		
		CGImageRef cgImage	= CreateCGImageFromUIImageScaled( img, scale );
				
		if( cgImage )
		{
			scaledImg	= [UIImage imageWithCGImage:cgImage];	// autoreleased
			CGImageRelease( cgImage );
		}
	}
	return scaledImg;	// autoreleased
}

@end

@implementation UIImage (scale)

-(UIImage*) scaleToSize:(CGSize)toSize
{
UIImage	*scaledImg	= nil;
float	scale		= GetScaleForProportionalResize( self.size, toSize, false, false );
CGImageRef cgImage	= CreateCGImageFromUIImageScaled( self, scale );

if( cgImage )
{
    scaledImg	= [UIImage imageWithCGImage:cgImage];	// autoreleased
    CGImageRelease( cgImage );
}
return scaledImg;
}


@end
