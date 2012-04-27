//
//  Lattice.m
//  Puzzle
//
//  Created by Andrea Barbon on 22/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "Lattice.h"
#import "PuzzleController.h"

@implementation Lattice

@synthesize delegate, scale, pieces;

- (void)initWithFrame:(CGRect)frame withNumber:(int)n withDelegate:(id)delegate_ {
    
    self.delegate = delegate_;
    
    scale = 1;
    float w = frame.size.width/n;
    
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:n^2];
    
    for (int i=0;i<n;i++){
        for (int j=0;j<n;j++){

            //CGRect rect = CGRectMake(i*w+self.padding, (j)*w+piceSize+2*self.padding+20, w-1, w-1);
            //CGRect rect = CGRectMake(i*w+frame.origin.x, (j)*w+frame.origin.y, w-1, w-1);
            CGRect rect = CGRectMake(i*w, (j)*w, w-1, w-1);
            UIView *v = [[UIView alloc] initWithFrame:rect];
            v.backgroundColor = [UIColor whiteColor];
            v.alpha = .1;
            [a addObject:v];
            [self addSubview:v];
        }
    }
    
    pieces = [NSArray arrayWithArray:a];
    
    //[self addSubview:[[UIImageView alloc] initWithImage:[(PuzzleController*)delegate image]]];
    
}




- (id)objectAtIndex:(int)i {
    
    return [pieces objectAtIndex:i];
}

@end
