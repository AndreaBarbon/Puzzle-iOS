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

@synthesize pieces, popover, image, piceSize, lattice, N, pieceNumber, imageView, positionedSound, completedSound;

- (BOOL)piece:(PieceView*)piece isInFrame:(CGRect)frame {

    return frame.origin.x<[piece realCenter].x && frame.origin.y<[piece realCenter].y;

}

- (BOOL)isPuzzleComplete {
    
    for (PieceView *p in pieces) {
        if (!p.isPositioned) {
            //NSLog(@"Piece #%d is not positioned", p.number);
            return NO;
        }
    }
    
    return YES;
    
}

- (void)toggleImage:(UILongPressGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        [self toggleImage];
    }
    
}
- (void)toggleImage {
            
        [UIView animateWithDuration:0.5 animations:^{
            if (imageView.alpha==0) {
                [self.view bringSubviewToFront:imageView];
                imageView.alpha = 1;
            } else if (imageView.alpha==1) {
                imageView.alpha = 0;
            }
        }];
    
}

- (void)puzzleCompleted {
        
    [self toggleImage];
    [completedSound play];
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
        


        
        if (j+i>=0 && j+i<N                                             //Evita di andare fuori board
            
            && !( r==2 && (piece.number+1)%pieceNumber==0 )             //bottom piece checking down
            && !( r==0 && (piece.number)%pieceNumber==0 )               //top piece checking up
            && !( r==1 && pieceNumber%(piece.number+1)==0 )             //right piece checking right
            && !( r==3 && pieceNumber%(piece.number)==pieceNumber-1 )   //left piece checking left
            ){
            
            
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
                                //NSLog(@"0 Wrong angles. ");
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
        
        NSLog(@"Piece #%d positioned!", piece.number);
        //Flashes and block the piece
        if (!piece.isPositioned) {
            piece.isPositioned = YES;
            piece.userInteractionEnabled = NO;
            [positionedSound play];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i animated:(BOOL)animated {
    
    //NSLog(@"Moving piece #%d to position %d", piece.number, i);

    if (animated) {
        
        [UIView animateWithDuration:0.4 animations:^{
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
    [self.view bringSubviewToFront:stepper];

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

            piece.transform = CGAffineTransformMakeScale(piceSize/piece.bounds.size.width, piceSize/piece.bounds.size.height);

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
    
    if ([self isPuzzleComplete]) {
        [self puzzleCompleted];
    }

    
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
    
    if ([self isPuzzleComplete]) {
        [self puzzleCompleted];
    }
    
}

- (void)refreshPositions {
    
    for (PieceView *p in pieces) {
        if (p.isFree && p.position>-1) {
            [self movePiece:p toLatticePoint:p.position animated:NO];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer*)gesture {
    
    //NSLog(@"Panning");
    
    CGPoint traslation = [gesture translationInView:lattice.superview];
    
    traslation.x = lattice.frame.origin.x - traslation.x;
    traslation.y = lattice.frame.origin.y - traslation.y;
    lattice.frame = CGRectMake(traslation.x, traslation.y, lattice.bounds.size.width, lattice.bounds.size.height);
    
//    for (PieceView *p in pieces) {
//        if (p.isFree) {
//            
//            traslation = [gesture translationInView:lattice.superview];
//            
//            traslation.x = p.frame.origin.x - traslation.x;
//            traslation.y = p.frame.origin.y - traslation.y;
//            p.frame = CGRectMake(traslation.x, traslation.y, p.bounds.size.width, p.bounds.size.height);
//        }
//    }
    
    
//    traslation = [gesture translationInView:imageView.superview];
//    
//    traslation.x = imageView.frame.origin.x - traslation.x;
//    traslation.y = imageView.frame.origin.y - traslation.y;
//    imageView.frame = CGRectMake(traslation.x, traslation.y, imageView.bounds.size.width, imageView.bounds.size.height);

//    lattice.transform = CGAffineTransformMakeTranslation(-traslation.x, -traslation.y);
    
    [self refreshPositions];
    [gesture setTranslation:CGPointZero inView:lattice.superview];
    
}


- (void)setup {
        
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    pieceNumber = PIECE_NUMBER;
    N = pieceNumber*pieceNumber;
    
    [self computePieceSize];
    
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



- (NSArray *)splitImage:(UIImage *)im{
    
    float x = pieceNumber;
    float y= pieceNumber;
    
    //CGSize size = [im size];
    
    float ww = self.padding;
    float hh = self.padding;
    
    
    //NSLog(@"Size = %.1f, %.1f", size.width, size.height);

    NSLog(@"Piece size = %.1f", piceSize);
    
    float w = piceSize;
    float h = piceSize;
    
    //NSLog(@"w, h = %.1f, %.1f", w, h);

    

    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:N];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            CGRect portion = CGRectMake(i * (w-2*ww)-ww, j * (h-2*hh)-hh, w, h);
            //NSLog(@"===> w, h = %.1f, %.1f", portion.origin.x, portion.origin.y);
            [arr addObject:[im subimageWithRect:portion]];
        }
    }

    return arr;
    
}

- (void)createPuzzleFromImage:(UIImage*)image_ {

    [self computePieceSize];
    
    for (PieceView *p in pieces) {
        [p removeFromSuperview];
    }
    
    [self createLattice];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:N];
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    float f = piceSize*pieceNumber-2*(pieceNumber)*self.padding;
    
    UIImage *img = [[UIImage imageWithCGImage:[image_ CGImage] scale:image_.size.width/f orientation:1] imageRotatedByDegrees:0];
    
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    
    array = [NSMutableArray arrayWithArray:[self splitImage:img]];
    NSLog(@"Pieces:%d", [array count]);
    
    
    
    for (int i=0;i<pieceNumber;i++){
        for (int j=0;j<pieceNumber;j++){
            
            CGRect portion = CGRectMake(i * (piceSize-2*self.padding)-self.padding+50, j * (piceSize-2*self.padding)-self.padding+50, piceSize, piceSize);
            
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
    
    if (FALSE) {
        
        for (PieceView *p in pieces) {
            p.isFree = YES;
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
        
    float marginTop = (rect.size.height - w + piceSize)/2;
    
    rect = CGRectMake((rect.size.width-w)/2, marginTop, w, w);
    
    lattice = [[Lattice alloc] init];
    [lattice initWithFrame:rect withNumber:pieceNumber withDelegate:self];
    
    //CGRect screen = [[UIScreen mainScreen] bounds];
    //float optimalPiceSize = PUZZLE_SIZE*screen.size.width/(pieceNumber)+2*self.padding;
    lattice.scale = 1; //optimalPiceSize/piceSize;
    [self resizeLattice];

    //lattice.frame = self.view.frame;
    [self.view addSubview:lattice];

    [self.view bringSubviewToFront:stepper];
    [self.view bringSubviewToFront:menuButtonView];
    [self.view bringSubviewToFront:drawerView];

    
}

- (void)resizeLattice {
    
    float z = lattice.scale;
    lattice.contentScaleFactor = z;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(self.view.center.x, self.view.center.y);
    transform = CGAffineTransformScale(transform, z, z);
    transform = CGAffineTransformTranslate(transform, -self.view.center.x, -self.view.center.y);
    lattice.transform = transform;
    
}

- (void)pinch:(UIPinchGestureRecognizer*)gesture {
    
    float z = [gesture scale];
    lattice.scale *= z;
    z = lattice.scale;
    
    [self resizeLattice];
    [self refreshPositions];        
    

    
    [gesture setScale:1];
    
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

    
    
    image = [UIImage imageNamed:@"Cover.png"];
    
    [self loadSounds];

    [self createLattice];
    [self createPuzzleFromImage:image];
    
    
    //Resize the drawer
    CGRect drawerFrame = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
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
        
    
    
    
    
    //Add the image;
    imageView = [[UIImageView alloc] initWithImage:image];
    rect = CGRectMake(0, (rect.size.height-rect.size.width)/2, rect.size.width, rect.size.width);
    imageView.frame = rect;
    imageView.alpha = 0;
    [self.view addSubview:imageView];
    
    //imageView.transform = CGAffineTransformMakeRotation(-M_PI/2);
    
    
//    CGRect rect = [[UIScreen mainScreen] bounds];
//    rect = CGRectMake(rect.size.width, piceSize+50, rect.size.width-150, rect.size.width-150);
//    imageView = [[UIImageView alloc] initWithFrame:rect];
//    imageView.image = image;
//    [self.view addSubview:imageView];
    
    
    UILongPressGestureRecognizer *longPressure = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImage:)];
    [longPressure setMinimumPressDuration:1];
    [self.view addGestureRecognizer:longPressure];

    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeR setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeL setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:swipeL];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:pan];
    
}

- (void)organizeDrawerWithOrientation:(UIImageOrientation)orientation {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:pieces];
    
    
    //Removes removed pieces
    bool removed = NO;
    for (int i=0; i<[pieces count]; i++) {
        
        PieceView *p = [pieces objectAtIndex:i];
        if (p.isFree) {
            [temp removeObject:p];
            removed = YES;
        }
    }
    
    
    if ((drawerFirstPoint.x==0 && drawerFirstPoint.y==0) ){//|| removed) {
        
        drawerFirstPoint.x = [[temp objectAtIndex:0] frame].origin.x;
        drawerFirstPoint.y = [[temp objectAtIndex:0] frame].origin.y;
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
                    rect.origin.x = (self.padding*0.75)/4;
                } else {
                    rect.origin.x = rect2.origin.x+rect2.size.width+10;
                    rect.origin.y = 20+(self.padding*0.75)/4;
                }
                
            } else {
                rect.origin = drawerFirstPoint;
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
                
                drawerFirstPoint.y = drawerFirstPoint.y+sgn*self.view.frame.size.height;
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
                
                drawerFirstPoint.x = drawerFirstPoint.x+sgn*self.view.frame.size.width;
                [self organizeDrawerWithOrientation:self.interfaceOrientation];
                //NSLog(@"first point = %.1f", drawerFirstPoint.x);
                
                
            }completion:^(BOOL finished){
                
                swiping = NO;
                
            }];
            
        }
    }
    
}

- (void)swipeR:(UISwipeGestureRecognizer*)swipe {

    [self swipeInDirection:UISwipeGestureRecognizerDirectionRight];
}


- (void)swipeL:(UISwipeGestureRecognizer*)swipe {
        
    [self swipeInDirection:UISwipeGestureRecognizerDirectionLeft];
    
}

- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}

- (IBAction)dc:(id)sender {
        
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.allowsEditing = YES;
    c.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
        popover = [[UIPopoverController alloc] initWithContentViewController:c];
        popover.delegate = self;
        [popover presentPopoverFromRect:menuButtonView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        [self presentModalViewController:c animated:YES];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){

        [popover dismissPopoverAnimated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        [self dismissModalViewControllerAnimated:YES];
    }

    image = [info objectForKey:UIImagePickerControllerEditedImage];
    imageView.image = image;

    [self createLattice];
    [self createPuzzleFromImage:image];

}

- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
            
        
        for (int i=0; i<N; i++) {          
            PieceView *p = [pieces objectAtIndex:i];            
            CGRect rect = p.frame;
            rect.origin.x = piceSize*i+10;
            rect.origin.y = 15+(self.padding)/2;;
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    //Rotate the drawer

    CGRect rect = drawerView.frame;
    CGRect stepperFrame = stepperDrawer.frame;

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y-20, drawerFirstPoint.x);
        
        drawerSize = piceSize+1.8*self.padding-20;
        rect.size.width = drawerSize;
        rect.size.height = [[UIScreen mainScreen] bounds].size.width;
        stepperFrame.origin.y = 10;
        stepperFrame.origin.x = rect.size.width+10;
        
    } else {
        
        drawerFirstPoint = CGPointMake(drawerFirstPoint.y, drawerFirstPoint.x+20);
        
        drawerSize = piceSize+1.8*self.padding;
        rect.size.height = drawerSize;
        rect.size.width = [[UIScreen mainScreen] bounds].size.height;
        stepperFrame.origin.y = rect.size.height+10;
        stepperFrame.origin.x = 10;
    }
        
    
    [UIView animateWithDuration:duration animations:^{
        
        drawerView.frame = rect;
        stepperDrawer.frame = stepperFrame;
        
    }];
    
    
    [self organizeDrawerWithOrientation:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
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

@end
