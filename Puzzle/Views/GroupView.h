//
//  GroupView.h
//  Puzzle
//
//  Created by Andrea Barbon on 05/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceView, PuzzleController;

@interface GroupView : UIView <UIGestureRecognizerDelegate>{
    
    float tempAngle;
}


@property (nonatomic, retain) PieceView *boss;
@property (nonatomic) float angle;
@property (nonatomic) BOOL isPositioned;
@property (nonatomic, retain) NSMutableArray *pieces;
@property (nonatomic, assign) PuzzleController *delegate;


- (void)rotate:(UIRotationGestureRecognizer*)gesture;
- (void)translateWithVector:(CGPoint)traslation;
- (void)pulse;

@end

