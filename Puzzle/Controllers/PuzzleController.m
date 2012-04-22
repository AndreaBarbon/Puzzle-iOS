//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PuzzleController.h"
#import "UIImage+CWAdditions.h"

@interface PuzzleController ()

@end


@implementation PuzzleController

@synthesize pieces, popover, sv, piceSize, lattice;

- (PieceView*)pieceAtPosition:(int)j {
    
    for (PieceView *p in pieces) {
        if (p.position == j) {
            return p;
        }
    }
    
    return nil;
}


- (void)checkNeighborsOfPieceNumber:(PieceView*)piece {
    
    PieceView *otherPiece;
    int j = piece.position;
    
    int rotation = floor(piece.angle/(M_PI/2));
    rotation = rotation%4;    

    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
    NSArray *a = [NSArray arrayWithObjects:
                  [NSNumber numberWithInt:-1],
                  [NSNumber numberWithInt:+PIECE_NUMBER],
                  [NSNumber numberWithInt:1], 
                  [NSNumber numberWithInt:-PIECE_NUMBER],
                  nil];
    
    for (int s=0; s<4; s++) {

        int k=0;
        int r = abs(s-rotation)%4;
        int i = [[a objectAtIndex:s] intValue];
        int l = [[a objectAtIndex:r] intValue];
        //NSLog(@"s=%d, (s+rotation)mod4=%d", s, r);
     
        if (j+i>=0 && j+i<N) {
            
            otherPiece = [self pieceAtPosition:j+i];
            //NSLog(@"Checking position %d, number+l = %d ", j+i, piece.number+l);
            if (otherPiece != nil && piece.number+l==otherPiece.number) {
                k = otherPiece.number;
                [otherPiece setNeighborNumber:piece.number forEdge:(r+2)%4];
                //NSLog(@"Found neighbor #%d", k);
            }
            
        }
        
        [array addObject:[NSNumber numberWithInt:k]];
    }
    
    piece.neighbors = array;
    
}

- (void)movePiece:(PieceView*)piece toLatticePoint:(int)i {
    
    piece.isPositioned = NO;

    UIView *v = [lattice objectAtIndex:i];

    [UIView animateWithDuration:0.4 animations:^{
        piece.frame = CGRectMake(
                                 v.frame.origin.x-self.padding,
                                 v.frame.origin.y-self.padding, 
                                 piece.frame.size.width, 
                                 piece.frame.size.height);
    }];
    
    int rotation = floor(piece.angle/(M_PI/2));
    rotation = rotation%4;
    
    piece.position = i;
    if (piece.number == i && rotation==0) {
        piece.isPositioned = YES;
        NSLog(@"Piece positioned!");
    }
    
    [self checkNeighborsOfPieceNumber:piece];
}

- (void)pieceMoved:(PieceView *)piece {
    
    CGPoint point = piece.frame.origin;        
    piece.isFree = (point.y>piceSize);

    
    if (piece.isFree) {
        
        for (int i=N-1; i>-1; i--) {
            
            UIView *v = [lattice objectAtIndex:i];
            //NSLog(@"v origin = %.1f, %.1f - piece.center = %.1f, %.1f", v.frame.origin.x, v.frame.origin.y, piece.center.x, piece.center.y);
            
            if (v.frame.origin.x<piece.center.x && v.frame.origin.y<piece.center.y) {
                
                [self movePiece:piece toLatticePoint:i];
                
                break;
            }
        }
    }
    
    [self organizeDrawer];

    
}

- (void)setup {
        
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    self.padding = rect.size.width/PIECE_NUMBER*0.2;
    piceSize = PUZZLE_SIZE*rect.size.width/(PIECE_NUMBER)+2*self.padding;
    
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
    
    float x = PIECE_NUMBER;
    float y= PIECE_NUMBER;
    
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

- (void)createPuzzleFromImage:(UIImage*)image {
    
    
    for (PieceView *p in pieces) {
        [p removeFromSuperview];
    }
    
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:N];
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    float f = piceSize*PIECE_NUMBER-2*(PIECE_NUMBER)*self.padding;
    
    UIImage *img = [[UIImage imageWithCGImage:[image CGImage] scale:image.size.width/f orientation:1] imageRotatedByDegrees:0];
    
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    
    array = [NSMutableArray arrayWithArray:[self splitImage:img]];
    NSLog(@"Pieces:%d", [array count]);
    
    
    
    for (int i=0;i<PIECE_NUMBER;i++){
        for (int j=0;j<PIECE_NUMBER;j++){
            
            CGRect portion = CGRectMake(i * (piceSize-2*self.padding)-self.padding+50, j * (piceSize-2*self.padding)-self.padding+50, piceSize, piceSize);
            
            PieceView *piece = [[PieceView alloc] initWithFrame:portion padding:self.padding];
            piece.delegate = self;
            piece.image = [array objectAtIndex:j+PIECE_NUMBER*i];
            piece.number = j+PIECE_NUMBER*i;
            piece.size = piceSize;
            
            NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
            
            for (int k=0; k<4; k++) {
                int e = arc4random_uniform(3)+1;
                [a addObject:[NSNumber numberWithInt:e]];
            }
            
            if (i>0) {
                int l = [arrayPieces count]-PIECE_NUMBER;
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
            if (i==PIECE_NUMBER-1) {
                [a replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
            }
            if (j==0) {
                [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
            }
            if (j==PIECE_NUMBER-1) {
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
    
    [self shuffle];
    [self organizeDrawer];
}

- (void)createLattice {
    
    
    float w = (piceSize-2*self.padding)*PIECE_NUMBER;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
        
    rect = CGRectMake((rect.size.width-w)/2, piceSize + 2*self.padding + 20, w, w);
    
    lattice = [[Lattice alloc] init];
    [lattice initWithFrame:rect withNumber:PIECE_NUMBER];
    lattice.frame = self.view.frame;
    [self.view addSubview:lattice];
    
}

- (void)pinch:(UIPinchGestureRecognizer*)gesture {
    
    NSLog(@"Pinched!");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createLattice];
        
    UIImage *img = [UIImage imageNamed:@"Cover.png"];

    [self createPuzzleFromImage:img];

    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeL];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinch];
    
}

- (void)organizeDrawer {
    
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
                rect.origin.x = rect2.origin.x+rect2.size.width+10;
                rect.origin.y = 30;
            } else {
                rect.origin = drawerFirstPoint;
            }
            p.frame = rect;
        }
    }];

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
            [self organizeDrawer];
            //NSLog(@"first point = %.1f", drawerFirstPoint.x);
            

        }completion:^(BOOL finished){

            swiping = NO;
            
        }];
        
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

    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];

    [self createPuzzleFromImage:img];



}

- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
            
        
        for (int i=0; i<N; i++) {          
            PieceView *p = [pieces objectAtIndex:i];            
            CGRect rect = p.frame;
            rect.origin.x = piceSize*i+10;
            rect.origin.y = 30;
            p.frame = rect;
            
            int r = arc4random_uniform(4);
            p.transform = CGAffineTransformMakeRotation(r*M_PI_2);
            p.angle = r*M_PI_2;
            
        }
        
        
        
//        int e = arc4random_uniform(N-1);
//        
//        for (int i=e; i<N; i++) {
//            
//            
//            PieceView *p = [pieces objectAtIndex:i];
//            CGRect rect = p.frame;
//            rect.origin.x = piceSize*j;
//            rect.origin.y = 30;
//            p.frame = rect;
//
//            int r = arc4random_uniform(4);
//            p.transform = CGAffineTransformMakeRotation(r*M_PI_2);
//            p.angle = r*M_PI_2;
//
//            j++;
//            if (i==N-1) i=-1;
//            if (i==e-1) break;
//            
//        }

    
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            NSLog(@"Shuffle!");
            [self shuffle];
            
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
