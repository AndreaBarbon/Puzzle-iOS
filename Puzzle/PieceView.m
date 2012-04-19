//
//  PieceView.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PieceView.h"

@implementation PieceView

@synthesize image, number, isLifted, isPositioned, edges, position, angle, tempAngle;

- (void)setup {
            
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];

    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:rot];
    
}

- (void)move:(UIPanGestureRecognizer*)gesture {
        
    CGPoint traslation = [gesture translationInView:self.superview];
    CGPoint newOrigin = CGPointMake(self.frame.origin.x+traslation.x, self.frame.origin.y+traslation.y);
    CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
    
    self.frame = newFrame;

    [gesture setTranslation:CGPointZero inView:self.superview];
    
}

- (void)rotate:(UIRotationGestureRecognizer*)gesture {
        
    float rotation = [gesture rotation];
            
    if ([gesture state]==UIGestureRecognizerStateEnded) {

        int t = floor(ABS(tempAngle)/(M_PI/4));
        
        NSLog(@"t=%d", t);
        
        if (t%2==0) {
            t/=2;
        } else {
            t= (t+1)/2;
        }
        
        rotation = angle + tempAngle/ABS(tempAngle) * t*M_PI/2;
        
        [UIView animateWithDuration:0.2 animations:^{

            self.transform = CGAffineTransformMakeRotation(rotation);

        }];
        
        angle = rotation - floor(rotation/(M_PI*2))*M_PI*2;
        NSLog(@"Angle = %.2f, Rot = %.2f, added +/- %d", angle, rotation, t);
        tempAngle = 0;

    } else {
        self.transform = CGAffineTransformRotate(self.transform, rotation);
        tempAngle += rotation;
    }
    
    //NSLog(@"Angle = %.2f, Temp = %.2f", angle, tempAngle);
    
    [gesture setRotation:0];
}


#pragma mark
#pragma DRAWING

- (void)drawEdgeFromPoint:(CGPoint)a toPoint:(CGPoint)b ofType:(int)type inContext:(CGContextRef)ctx {
    
    UIGraphicsPushContext(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, a.x, a.y);
    CGContextAddLineToPoint(ctx, b.x, b.y);
    CGContextStrokePath(ctx);
    
    UIGraphicsPopContext();
    
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    float p = 10;
    float x = self.frame.size.width;
    float y = self.frame.size.height;

    [self drawEdgeFromPoint:CGPointMake(p, p)       toPoint:CGPointMake(x-p, p)     ofType:0 inContext:ctx];
    [self drawEdgeFromPoint:CGPointMake(x-p, p)     toPoint:CGPointMake(x-p, y-p)   ofType:0 inContext:ctx];
    [self drawEdgeFromPoint:CGPointMake(x-p, y-p)   toPoint:CGPointMake(p, y-p)     ofType:0 inContext:ctx];
    //[self drawEdgeFromPoint:CGPointMake(p, y-p)     toPoint:CGPointMake(p, p)       ofType:0 inContext:ctx];
    

}




#pragma mark
#pragma UNUSEFUL

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
        
    }
    return self;
}

- (void)awakeFromNib {
    
    [self setup];
    
}

@end
