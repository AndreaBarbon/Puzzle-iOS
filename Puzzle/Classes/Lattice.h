//
//  Lattice.h
//  Puzzle
//
//  Created by Andrea Barbon on 22/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LatticeDelegate

@end

@interface Lattice : UIView {
    
    NSArray *pieces;
}

@property (nonatomic, assign) UIViewController *delegate;

- (void)initWithFrame:(CGRect)frame withNumber:(int)n;
- (id)objectAtIndex:(int)i;

@end
