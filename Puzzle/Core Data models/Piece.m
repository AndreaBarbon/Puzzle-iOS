//
//  Piece.m
//  Puzzle
//
//  Created by Andrea Barbon on 03/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "Piece.h"
#import "Image.h"
#import "Puzzle.h"


@implementation Piece

@dynamic angle;
@dynamic edge0;
@dynamic edge1;
@dynamic edge2;
@dynamic edge3;
@dynamic isFree;
@dynamic number;
@dynamic position;
@dynamic image;
@dynamic puzzle;
@dynamic moves;
@dynamic rotations;


- (BOOL) isFreeScalar {
    return self.isFree.boolValue;
}

- (void) setisFreeScalar:(BOOL)isFree_ {
    self.isFree = [NSNumber numberWithBool:isFree_];
}

@end
