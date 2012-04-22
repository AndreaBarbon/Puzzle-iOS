//
//  PieceView.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceView;


@protocol PieceViewProtocol

-(void)pieceMoved:(PieceView*)piece;

@end


@interface PieceView : UIView {
        
}

@property (nonatomic, assign) id<PieceViewProtocol> delegate;


@property(nonatomic, retain) NSArray *edges;
@property(nonatomic, retain) NSArray *neighbors;
@property(nonatomic, retain) UIImage *image;

@property(nonatomic) BOOL isPositioned;
@property(nonatomic) BOOL isLifted;
@property(nonatomic) BOOL isFree;

@property(nonatomic) int number;
@property(nonatomic) int position;

@property(nonatomic) float angle;
@property(nonatomic) float size;
@property(nonatomic) float padding;
@property(nonatomic) float tempAngle;
@property(nonatomic) float boxHeight;



- (void)move:(UIPanGestureRecognizer*)gesture;
- (void)rotate:(UIRotationGestureRecognizer*)gesture;
- (id)initWithFrame:(CGRect)frame padding:(float)p;
- (int)edgeNumber:(int)i;
- (void)setNeighborNumber:(int)i forEdge:(int)edge;



@end
