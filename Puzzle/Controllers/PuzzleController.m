//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PuzzleController.h"
#import "PieceView.h"
#import "UIImage+CWAdditions.h"

@interface PuzzleController ()

@end


@implementation PuzzleController

@synthesize pieces, popover, sv, infoButton;


- (void)setup {
    
    self.view.frame = [[UIScreen mainScreen] bounds];
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
    
    [self setup];
}



- (NSArray *)splitImage:(UIImage *)im{
    
    float x = PIECE_NUMBER;
    float y= PIECE_NUMBER;
    
    //CGSize size = [im size];
    
    float ww = PADDING;
    float hh = PADDING;
    
    
    //NSLog(@"Size = %.1f, %.1f", size.width, size.height);

    
    float w = PIECE_SIZE;
    float h = PIECE_SIZE;
    
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
    
    float f = PIECE_SIZE*PIECE_NUMBER-2*(PIECE_NUMBER)*PADDING;
    
    UIImage *img = [[UIImage imageWithCGImage:[image CGImage] scale:image.size.width/f orientation:1] imageRotatedByDegrees:0];
    
    //[self.view addSubview:[[UIImageView alloc] initWithImage:img]];
    
    array = [NSMutableArray arrayWithArray:[self splitImage:img]];
    NSLog(@"Pieces:%d", [array count]);
    
    
    
    for (int i=0;i<PIECE_NUMBER;i++){
        for (int j=0;j<PIECE_NUMBER;j++){
            
            CGRect portion = CGRectMake(i * (PIECE_SIZE-2*PADDING)-PADDING+50, j * (PIECE_SIZE-2*PADDING)-PADDING+50, PIECE_SIZE, PIECE_SIZE);
            
            PieceView *piece = [[PieceView alloc] initWithFrame:portion];
            piece.image = [array objectAtIndex:j+PIECE_NUMBER*i];
            
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
}

- (void) setUpGestureHandlersOnScrollView:(UIScrollView *)scrollView {
    
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {     
        if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]])
        {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
            panGR.minimumNumberOfTouches = 2;               
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImage *img = [UIImage imageNamed:@"Cover.png"];
    
    //sv.contentSize = CGSizeMake(floorf(PIECE_SIZE*N/sv.frame.size.width)*sv.frame.size.width, PIECE_SIZE+2*PADDING);
    //[sv setFrame:CGRectMake(0, 0, sv.frame.size.width, PIECE_SIZE+2*PADDING)];
    
    [self createPuzzleFromImage:img];
    
    [self shuffle];

    
    UISwipeGestureRecognizer *swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeR:)];
    [swipeR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeR];
    
    UISwipeGestureRecognizer *swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeL:)];
    [swipeL setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeL];
    

}

- (void)swipeInDirection:(UISwipeGestureRecognizerDirection)direction {
    
    int sgn = 1;
    if (direction==UISwipeGestureRecognizerDirectionLeft) {
        sgn *= -1;
    }
    
    if (!swiping) {
        
        [UIView animateWithDuration:1 animations:^{
            
            swiping = YES;
            for (PieceView *p in pieces) {
                if (!p.isFree)
                    p.center = CGPointMake(p.center.x+sgn*self.view.frame.size.width, p.center.y);
            }
            
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
    
    NSLog(@"DC");
    
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.allowsEditing = YES;
    c.delegate = self;
    
    popover = [[UIPopoverController alloc] initWithContentViewController:c];

    popover.delegate = self;
    
    [popover presentPopoverFromRect:infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES   ];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [popover dismissPopoverAnimated:YES];

    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];

    [self createPuzzleFromImage:img];
    [self shuffle];


}

- (void)shuffle {
    
    pieces = [self shuffleArray:pieces];
    
    [UIView animateWithDuration:1 animations:^{
        
        
        for (int i=0; i<N; i++) {          
            PieceView *p = [pieces objectAtIndex:i];            
            CGRect rect = p.frame;
            rect.origin.x = PIECE_SIZE*i;
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
//            rect.origin.x = PIECE_SIZE*j;
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
    }];

    
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shuffle!");
        [self shuffle];
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
