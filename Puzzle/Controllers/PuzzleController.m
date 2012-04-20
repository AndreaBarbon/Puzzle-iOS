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

@synthesize pieces;


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:N];
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    //array = [NSMutableArray arrayWithArray:[[self class] splitImage:[UIImage imageNamed:@"Facebook_icon.png"]]];
    
    
    UIImage *img = [UIImage imageNamed:@"Cover.png"];
    
    float f = PIECE_SIZE*PIECE_NUMBER-2*(PIECE_NUMBER)*PADDING;
        
    img = [UIImage imageWithCGImage:[img CGImage] scale:img.size.width/f orientation:1];
    
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
