//
//  PieceView.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PieceView;
@class PuzzleController;


@protocol PieceViewProtocol

-(void)pieceMoved:(PieceView*)piece;
-(void)pieceRotated:(PieceView*)piece;

@end


@interface PieceView : UIView {
        
    float tr;
}

//@property (nonatomic, assign) id<PieceViewProtocol> delegate;
@property (nonatomic, assign) PuzzleController *delegate;


@property(nonatomic, retain) NSArray *edges;
@property(nonatomic, retain) NSArray *neighbors;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) UIView *centerView;

@property(nonatomic) BOOL isPositioned;
@property(nonatomic) BOOL isLifted;
@property(nonatomic) BOOL isFree;
@property(nonatomic) BOOL isRotating;
@property(nonatomic) BOOL hasNeighbors;
@property(nonatomic) CGPoint oldPosition;

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
- (NSArray*)allTheNeighborsBut:(NSMutableArray*)excluded;
- (CGPoint)realCenter;

@end
