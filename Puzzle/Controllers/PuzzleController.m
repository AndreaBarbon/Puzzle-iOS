//
//  PuzzleController.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PuzzleController.h"
#import "PieceView.h"

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

#define N 9
#define kXSlices 3
#define kYSlices 3

#define PIECE_SIZE 300


+ (NSArray *)splitImageInTo9:(UIImage *)im{
    
    CGSize size = [im size];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:9];
    for (int i=0;i<3;i++){
        for (int j=0;j<3;j++){
            CGRect portion = CGRectMake(i * size.width/3.0, j * size.height/3.0, size.width/3.0, size.height/3.0);
            UIGraphicsBeginImageContext(portion.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextTranslateCTM(context, 0, -portion.size.height);
            CGContextTranslateCTM(context, -portion.origin.x, -portion.origin.y);
            CGContextDrawImage(context,CGRectMake(0.0, 0.0,size.width,  size.height), im.CGImage);
            [arr addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
    }
    return arr;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:N];
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    
    array = [NSMutableArray arrayWithArray:[[self class] splitImageInTo9:[UIImage imageNamed:@"Trefoil_knot_arb.png"]]];
    NSLog(@"Pieces:%d", [array count]);
    

    
    for (int i=0; i<N; i++) {
        CGRect rect = CGRectMake(20*(N-i), 20*i, PIECE_SIZE, PIECE_SIZE);
        PieceView *piece = [[PieceView alloc] initWithFrame:rect];
        piece.image = [array objectAtIndex:i];
        [piece setNeedsDisplay];
        [arrayPieces addObject:piece];
        [self.view addSubview:piece];
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
