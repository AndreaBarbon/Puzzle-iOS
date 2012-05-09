//
//  GroupView.h
//  Puzzle
//
//  Created by Andrea Barbon on 05/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceView;

@interface GroupView : UIView 


@property (nonatomic, retain) PieceView *boss;
@property (nonatomic) float angle;
@property (nonatomic, retain) NSMutableArray *pieces;


- (void)translateWithVector:(CGPoint)traslation;

@end

