//
//  Lattice.m
//  Puzzle
//
//  Created by Andrea Barbon on 22/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "Lattice.h"
#import "PuzzleController.h"
#import <QuartzCore/QuartzCore.h>

@implementation Lattice

@synthesize delegate, scale, pieces;

- (void)initWithFrame:(CGRect)frame withNumber:(int)n_ withDelegate:(id)delegate_ {
    
    n = n_;
    
    self.delegate = delegate_;
    
    scale = 1;
    float w = frame.size.width/n;
    
    
    @autoreleasepool {
        
        NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:n^2];
                
                for (int i=0;i<3*n;i++){
                    for (int j=0;j<3*n;j++){
                        
                        //CGRect rect = CGRectMake(i*w+self.padding, (j)*w+piceSize+2*self.padding+20, w-1, w-1);
                        //CGRect rect = CGRectMake(i*w+frame.origin.x, (j)*w+frame.origin.y, w-1, w-1);
                        
                        float panning = 2.0;
                        
                        CGRect rect = CGRectMake(i*w-panning, j*w-panning, w-2*panning, w-2*panning);
                        UIView *v = [[UIView alloc] initWithFrame:rect];
                        
                        
                        //v.layer.cornerRadius = w/15;
                        //v.layer.masksToBounds = YES;
                        
                        v.backgroundColor = [UIColor whiteColor];

                        if ( i >= n && i < 2*n && j >= n && j < 2*n ) {
                            
                            v.alpha = .2;
                            
                        } else {
                            
                            v.alpha = .05;
                        }
                        
                        [a addObject:v];
                        [self addSubview:v];
                    }
                }

        pieces = [NSArray arrayWithArray:a];
        
    }
        
    //[self addSubview:[[UIImageView alloc] initWithImage:[(PuzzleController*)delegate image]]];
    
}




- (id)objectAtIndex:(int)i {
    
    //DLog(@"Asking for lattice piece #%d, returning %d", i, i+4*n*n);
    
    if ( i < 0 || i > n*n*9-1 ) {
        DLog(@"%d is out of bounds", i);
        return nil;
    }
    
    return [pieces objectAtIndex:i];
}

@end
