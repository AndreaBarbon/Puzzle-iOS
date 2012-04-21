//
//  PieceView.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PieceView : UIView {
    
}

@property(nonatomic, retain) NSArray *edges;
@property(nonatomic, retain) UIImage *image;

@property(nonatomic) BOOL isPositioned;
@property(nonatomic) BOOL isLifted;
@property(nonatomic) BOOL isFree;

@property(nonatomic) int number;
@property(nonatomic) int position;

@property(nonatomic) float angle;
@property(nonatomic) float tempAngle;
@property(nonatomic) float boxHeight;


- (void)move:(UIPanGestureRecognizer*)gesture;
- (void)rotate:(UIRotationGestureRecognizer*)gesture;


@end
