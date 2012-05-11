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
        
        for (int k=0; k<3; k++) {
            for (int l=0; l<3; l++) {
                
                for (int i=0;i<n;i++){
                    for (int j=0;j<n;j++){
                        
                        //CGRect rect = CGRectMake(i*w+self.padding, (j)*w+piceSize+2*self.padding+20, w-1, w-1);
                        //CGRect rect = CGRectMake(i*w+frame.origin.x, (j)*w+frame.origin.y, w-1, w-1);
                        
                        float panning = 2.0;
                        
                        CGRect rect = CGRectMake(k*w*n + i*w-panning, l*w*n + (j)*w-panning, w-2*panning, w-2*panning);
                        UIView *v = [[UIView alloc] initWithFrame:rect];
                        
                        
                        //v.layer.cornerRadius = w/15;
                        //v.layer.masksToBounds = YES;
                        
                        v.backgroundColor = [UIColor whiteColor];

                        if ( l == 1 && k == 1 ) {
                            
                            v.alpha = .2;
                            
                        } else {
                            
                            v.alpha = .05;
                        }
                        
                        [a addObject:v];
                        [self addSubview:v];
                    }
                }
            }
        }
        
        pieces = [NSArray arrayWithArray:a];
        
    }
        
    //[self addSubview:[[UIImageView alloc] initWithImage:[(PuzzleController*)delegate image]]];
    
}




- (id)objectAtIndex:(int)i {
    
    //NSLog(@"Asking for lattice piece #%d, returning %d", i, i+4*n*n);
    
    if ( i < 0 || i > n*n*9-1 ) {
        NSLog(@"%d is out of bounds", i);
        return nil;
    }
    
    return [pieces objectAtIndex:i];
}

@end
