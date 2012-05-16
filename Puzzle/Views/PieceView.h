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
@class GroupView;


@protocol PieceViewProtocol

-(void)pieceMoved:(PieceView*)piece;
-(void)pieceRotated:(PieceView*)piece;

@end


@interface PieceView : UIView <UIGestureRecognizerDelegate> {
        
    float tr;
    UILabel *label;
    
    
}

//@property (nonatomic, assign) id<PieceViewProtocol> delegate;
@property (nonatomic, assign) PuzzleController *delegate;


@property(nonatomic, retain) NSArray *edges;
@property(nonatomic, retain) NSArray *neighbors;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) UIView *centerView;
@property(nonatomic, retain) UIPanGestureRecognizer *pan;

@property(nonatomic, retain) GroupView *group;

@property(nonatomic) BOOL isPositioned;
@property(nonatomic) BOOL isLifted;
@property(nonatomic) BOOL isFree;
@property(nonatomic) BOOL isRotating;
@property(nonatomic) BOOL isBoss;
@property(nonatomic) BOOL hasNeighbors;

@property(nonatomic) CGPoint oldPosition;

@property(nonatomic) int number;
@property(nonatomic) int position;
@property(nonatomic) int positionInDrawer;
@property(nonatomic) int moves;
@property(nonatomic) int rotations;

@property(nonatomic) float angle;
@property(nonatomic) float size;
@property(nonatomic) float padding;
@property(nonatomic) float tempAngle;



- (void)move:(UIPanGestureRecognizer*)gesture;
- (void)rotate:(UIRotationGestureRecognizer*)gesture;
- (void)rotateTap:(UITapGestureRecognizer*)gesture;

- (id)initWithFrame:(CGRect)frame;
- (int)edgeNumber:(int)i;
- (void)setNeighborNumber:(int)i forEdge:(int)edge;
- (NSArray*)allTheNeighborsBut:(NSMutableArray*)excluded;
- (CGPoint)realCenter;
- (void)pulse;
- (BOOL)isCompleted;

@end
