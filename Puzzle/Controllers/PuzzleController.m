//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#define PIECE_NUMBER 4

#import "PuzzleController.h"
#import "UIImage+CWAdditions.h"

@interface PuzzleController ()

@end


@implementation PuzzleController

@synthesize pieces, image, piceSize, lattice, N, pieceNumber, imageView, positionedSound, completedSound, imageViewLattice, menu, loadedPieces, pan;

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
        if (imageView.alpha==0) {
            
            menuButtonView.userInteractionEnabled = NO;
            [self.view bringSubviewToFront:imageView];
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
    
    [UIView animateWithDuration:1 animations:^{
        
        imageViewLattice.alpha = 1;

    }];
    
    //[completedSound play];
}

- (void)computePieceSize {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        piceSize = 200;
        
    }else{  
        
        piceSize = 100;
    }
    
    self.padding = piceSize*0.15;
    
    drawerSize = piceSize+1.8*self.padding;
    
    //    piceSize = PUZZLE_SIZE*rect.size.width/(pieceNumber)+2*self.padding;
    
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
                      lattice.frame.origin.x + lattice.scale*(v.frame.origin.x-self.padding),
                      lattice.frame.origin.y + lattice.scale*(v.frame.origin.y-self.padding), 
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
            if (![self isPuzzleComplete]) {
                [positionedSound play];
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
        }];
        
    } else {
        
        piece.frame = [self frameOfLatticePiece:i];
        
    }
    
    
    piece.position = i;
    piece.oldPosition = [piece realCenter];
    
    
    if (!piece.isPositioned) {
        [self isPositioned:piece];
    }
    
    [self checkNeighborsOfPieceNumber:piece];
    
    
}

- (void)bringDrawerToTop {
    
    [self.view bringSubviewToFront:drawerView];
    [self.view bringSubviewToFront:stepperDrawer];
    [self.view bringSubviewToFront:menuButtonView];
    //[self.view bringSubviewToFront:stepper];
    
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
            [UIView animateWithDuration:0.4 animations:^{
                
                piece.transform = CGAffineTransformScale(piece.transform, piceSize/piece.bounds.size.width, piceSize/piece.bounds.size.height);
                
            }];
        }
        
    } else {
        piece.isFree = YES;
    }
    
    
    if (piece.isFree) {
        
        if ( [self pieceIsOut:piece] ) 
        {
            
            [UIView animateWithDuration:0.4 animations:^{
                
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
    
    [self organizeDrawerWithOrientation:self.interfaceOrientation];
    [self bringDrawerToTop];
    
    piece.oldPosition = [piece realCenter];
    //NSLog(@"OldPosition (%.1f, %.1f) set for piece #%d", [piece realCenter].x, [piece realCenter].y, piece.number);

    
    [self isPositioned:piece];

    
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


- (NSArray *)splitImage:(UIImage *)im{
    
    float x = pieceNumber;
    float y= pieceNumber;
    
    //CGSize size = [im size];
    
    float ww = self.padding;
    float hh = self.padding;
    
    
    //NSLog(@"Size = %.1f, %.1f", size.width, size.height);
    
    NSLog(@"Splitting image, Piece size = %.1f, number of pieces = %d", piceSize, pieceNumber*pieceNumber);
    [self print_free_memory];

    
    float w = piceSize;
    float h = piceSize;
    
    //NSLog(@"w, h = %.1f, %.1f", w, h);
    
    loadedPieces = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:N];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            
            CGRect portion = CGRectMake(i * (w-2*ww)-ww, j * (h-2*hh)-hh, w, h);
            
            //[arr addObject:[self clipImage:im toRect:portion]];            
            [arr addObject:[im subimageWithRect:portion]];            
            loadedPieces++;
        }
    }
    
    NSLog(@"All the images splitted");
    [self print_free_memory];

    
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

- (void)createPuzzleFromImage:(UIImage*)image_ {

    [self computePieceSize];
    [self createLattice];
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    float f = (float)(pieceNumber*(piceSize-2*self.padding));
    
    
    NSLog(@"Piece number %d, piece size %.1f, f = %.1f, padding = %.1f", pieceNumber, piceSize, f, self.padding);
    
    UIImage *img = [[UIImage imageWithCGImage:[image_ CGImage] scale:image_.size.width/f orientation:1] imageRotatedByDegrees:0];

    //UIImage *img = [[self class] imageWithImage:image_ scaledToSize:CGSizeMake(f, f)];
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    
    
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self splitImage:img]];
    NSLog(@"Pieces:%d", [array count]);
    
    
    
    for (int i=0;i<pieceNumber;i++){
        for (int j=0;j<pieceNumber;j++){
            
            CGRect portion = CGRectMake(
                                        i * (piceSize-2*self.padding)-self.padding,
                                        j * (piceSize-2*self.padding)-self.padding, 
                                        piceSize, 
                                        piceSize);
            
                        
            PieceView *piece = [[PieceView alloc] initWithFrame:portion padding:self.padding];
            piece.delegate = self;
            piece.image = [array objectAtIndex:j+pieceNumber*i];
            piece.number = j+pieceNumber*i;
            piece.size = piceSize;
            piece.position = -1;
            NSNumber *n = [NSNumber numberWithInt:N];
            piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
            
            NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
            
            for (int k=0; k<4; k++) {
                int e = arc4random_uniform(3)+1;
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
            
        }
    }
    
    pieces = [[NSArray alloc] initWithArray:arrayPieces];


    
    if (NO) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
            [self movePiece:p toLatticePoint:p.number animated:NO];
        }
        
    } else {
        [self shuffle];
        [self organizeDrawerWithOrientation:self.interfaceOrientation];
    }
    
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
    
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [lattice addGestureRecognizer:pinch];

    
    NSLog(@"Lattice created");
    
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
    self.completedSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.view.frame = rect;
    
    [self loadSounds];
    [self computePieceSize];
    
    //Add the image;
    image = [UIImage imageNamed:@"Cover.png"];
    
    imageView = [[UIImageView alloc] initWithImage:image];
    rect = CGRectMake(0, (rect.size.height-rect.size.width)/2, rect.size.width, rect.size.width);
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
        stepperFrame.origin.x = drawerFrame.size.width+10;
        
    } else {
        
        drawerFrame.size.height = drawerSize;
        drawerFrame.size.width = [[UIScreen mainScreen] bounds].size.height;
        stepperFrame.origin.y = drawerFrame.size.height+10;
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

    
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    
    
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
    

    [UIView animateWithDuration:0.5 animations:^{
        
        for (int i=0; i<[temp count]; i++) {
            
            PieceView *p = [temp objectAtIndex:i];
            
            CGRect rect = p.frame;
            PieceView *p2;
            
            if (i>0) {
                p2 = [temp objectAtIndex:i-1];
                CGRect rect2 = p2.frame;
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    rect.origin.y = rect2.origin.y+rect2.size.width+10;
                    rect.origin.x = (self.padding*0.75)/2;
                } else {
                    rect.origin.x = rect2.origin.x+rect2.size.width+10;
                    rect.origin.y = (self.padding*0.75)/2;
                }
                
            } else {
                
                if (UIInterfaceOrientationIsLandscape(orientation)) {
                    rect.origin.y = drawerFirstPoint.y+10;
                    rect.origin.x = (self.padding*0.75)/2;
                } else {
                    rect.origin.x = drawerFirstPoint.x+10;
                    rect.origin.y = (self.padding*0.75)/2;
                }
                
                //NSLog(@"FirstPoint was %.1f, %.1f", drawerFirstPoint.x, drawerFirstPoint.y);

            }

            if (!didRotate) {
                rect.origin.y += 20;
            }
            
            p.frame = rect;
            

        }
    }];
    
}

- (IBAction)scrollDrawer:(UIStepper*)sender {
    
    if (sender.value<DrawerPosition) {
        [self swipeInDirection:UISwipeGestureRecognizerDirectionRight];
    } else {
        [self swipeInDirection:UISwipeGestureRecognizerDirectionLeft];
    }
    
    DrawerPosition = sender.value;
    
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
    
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        if (direction==UISwipeGestureRecognizerDirectionRight && drawerFirstPoint.y>0) {
            return;
        }
        
        PieceView *p = [temp lastObject];
        if (direction==UISwipeGestureRecognizerDirectionLeft && p.frame.origin.y<self.view.frame.size.height-p.frame.size.height+self.padding) {
            return;
        }
        
        if (!swiping) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                swiping = YES;
                
                drawerFirstPoint.y += sgn*self.view.frame.size.height;
                [self organizeDrawerWithOrientation:self.interfaceOrientation];
                //NSLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
            }completion:^(BOOL finished){
                
                swiping = NO;
                
            }];
            
        }
        
    } else {
        
        if (direction==UISwipeGestureRecognizerDirectionRight && drawerFirstPoint.x>0) {
            return;
        }
        
        PieceView *p = [temp lastObject];
        if (direction==UISwipeGestureRecognizerDirectionLeft && p.frame.origin.x<self.view.frame.size.width-p.frame.size.width+self.padding) {
            return;
        }
        
        if (!swiping) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                swiping = YES;
                
                drawerFirstPoint.x += sgn*self.view.frame.size.width;
                [self organizeDrawerWithOrientation:self.interfaceOrientation];
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
    [self.view bringSubviewToFront:menu.view];
    [menu toggleMenu];
    
    
//    UIImagePickerController *c = [[UIImagePickerController alloc] init];
//    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    c.allowsEditing = YES;
//    c.delegate = self;
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        
//        popover = [[UIPopoverController alloc] initWithContentViewController:c];
//        popover.delegate = self;
//        [popover presentPopoverFromRect:menuButtonView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
//        
//    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        
//        [self presentModalViewController:c animated:YES];
//    }
    
}



- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
    
    
    for (int i=0; i<N; i++) {          
        PieceView *p = [pieces objectAtIndex:i];            
        CGRect rect = p.frame;
        rect.origin.x = piceSize*i+10;
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
            NSLog(@"Piece is #%d out, N= %.1f", piece.number, N);
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
    
    NSLog(@"Scaling Image to size %.1f", newSize.width);
    
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
        
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        
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
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        drawerFirstPoint = CGPointMake(5, drawerFirstPoint.x);
        
        drawerSize = piceSize+1.8*self.padding-20;
        rect.size.width = drawerSize;
        rect.size.height = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = rect.size.height - stepperFrame.size.height-30;
        stepperFrame.origin.x = rect.size.width+10;
        
    } else {
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, 5);
        
        drawerSize = piceSize+1.8*self.padding-20;
        rect.size.height = drawerSize;
        rect.size.width = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = rect.size.height+10;
        stepperFrame.origin.x = rect.size.width - stepperFrame.size.width-10;
    }
    
    
    
    if (!receivedFirstTouch) {
        
        [UIView animateWithDuration:duration animations:^{

            lattice.frame = [self frameForLatticeWithOrientation:toInterfaceOrientation];
            
        }];
        
    }
    
    
    
    
    [UIView animateWithDuration:duration animations:^{
        
        drawerView.frame = rect;
        stepperDrawer.frame = stepperFrame;

    }];
    
    
    [self organizeDrawerWithOrientation:toInterfaceOrientation];
    
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
    
    if(imageView.alpha == 1) {
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


@end
