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
    
    self.backgroundColor = [UIColor clearColor];
    

    [self addGestureRecognizer:pan];
    [self addGestureRecognizer:rot];
    
}



#pragma mark
#pragma GESTURE HANDLING

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b firstWeight:(float)f {
    
    return CGPointMake(f*a.x+(1-f)*b.x, f*a.y+(1-f)*b.y);
    
}

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b {
    
    return CGPointMake(a.x+b.x, a.y+b.y);
    
}

- (void)move:(UIPanGestureRecognizer*)gesture {
        
    CGPoint traslation = [gesture translationInView:self.superview];
    CGPoint newOrigin = [self sum:self.frame.origin plus:traslation];
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

#define PADDING 60

- (void)drawEdgeNumber:(int)n ofType:(int)type inContext:(CGContextRef)ctx {
    
    float x = self.frame.size.width;
    float y = self.frame.size.height;
    float l;
    float p = PADDING;
    
    BOOL vertical = NO;
    int sign;
    
    CGPoint a;
    CGPoint b;
        
    switch (n) {
        case 1:
            a = CGPointMake(p, p);
            b = CGPointMake(x-p, p);
            vertical = YES;
            sign = -1;
            break;
        case 2:
            a = CGPointMake(x-p, p);
            b = CGPointMake(x-p, y-p);
            sign = 1;
            break;
        case 3:
            a = CGPointMake(x-p, y-p);
            b = CGPointMake(p, y-p);
            vertical = YES;
            sign = 1;
            break;
        case 4:
            a = CGPointMake(p, y-p);
            b = CGPointMake(p, p);
            sign = -1;
            break;
            
        default:
            break;
    }
    
    if (type<0) {
        sign *= -1;
    }
    
    if (vertical) {
        l = y;
    } else {
        l = x;
    }
    
    float l3 = (l-2*p)/3;

    
    //UIGraphicsPushContext(ctx);
    
    
    
        
        
        CGPoint point = [self sum:a plus:b firstWeight:2.0/3.0];
        CGContextAddLineToPoint(ctx, point.x, point.y);
        //NSLog(@"p = ( %.1f, %.1f )", p.x, p.y);

        
    if (abs(type)==1) { //Triangolino

        CGPoint p2 = [self sum:a plus:b firstWeight:1.0/2.0];

        if (!vertical) {
            p2 = [self sum:p2 plus:CGPointMake(sign*(p-20), 0)];
        } else {
            p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-20))];
        }
        
        CGContextAddLineToPoint(ctx, p2.x, p2.y);
        
        
        CGPoint p3 = [self sum:a plus:b firstWeight:1.0/3.0];
        CGContextAddLineToPoint(ctx, p3.x, p3.y);        

    } else if (abs(type)==2) { //Cerchietto
        
        CGPoint p2 = [self sum:a plus:b firstWeight:1.0/2.0];
        
        switch (n) {
            case 1:
                CGContextAddArc(ctx, p2.x, p2.y, (l-2*p)/6, M_PI, 0, sign+1);
                break;
            case 2:
                CGContextAddArc(ctx, p2.x, p2.y, (l-2*p)/6, M_PI*3/2, M_PI/2, sign-1);
                break;
            case 3:
                CGContextAddArc(ctx, p2.x, p2.y, (l-2*p)/6, 0, M_PI, sign-1);
                break;
            case 4:
                CGContextAddArc(ctx, p2.x, p2.y, (l-2*p)/6, M_PI/2, M_PI*3/2, sign+1);
                break;
            default:
                break;
        }

    } else if (abs(type)==3) { //Quadratino
        
        CGPoint p2 = point;
        CGPoint p3 = point;
        CGPoint p4 = point;
        
        switch (n) {
            case 1:
                p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-20))];
                p3 = [self sum:p2 plus:CGPointMake(l3, 0)];
                p4 = [self sum:point plus:CGPointMake(l3, 0)];
                break;
            case 2:
                p2 = [self sum:p2 plus:CGPointMake(sign*(p-20), 0)];
                p3 = [self sum:p2 plus:CGPointMake(0, l3)];
                p4 = [self sum:point plus:CGPointMake(0 , l3)];
                break;
            case 3:
                p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-20))];
                p3 = [self sum:p2 plus:CGPointMake(-l3, 0)];
                p4 = [self sum:point plus:CGPointMake(-l3, 0)];
                break;
            case 4:
                p2 = [self sum:p2 plus:CGPointMake(sign*(p-20), 0)];
                p3 = [self sum:p2 plus:CGPointMake(0, -l3)];
                p4 = [self sum:point plus:CGPointMake(0 , -l3)];
                break;
            default:
                break;
        }
        
        CGContextAddLineToPoint(ctx, p2.x, p2.y);
        CGContextAddLineToPoint(ctx, p3.x, p3.y);
        CGContextAddLineToPoint(ctx, p4.x, p4.y);

    
        
    } else {
        
        point = [self sum:a plus:b firstWeight:1.0/3.0];
        CGContextAddLineToPoint(ctx, point.x, point.y);
    
    }
    
    CGContextAddLineToPoint(ctx, b.x, b.y);
    
    
    
    //UIGraphicsPopContext();
    
}


#define LINE_WIDTH 1

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.75);
    CGContextSetLineWidth(ctx, LINE_WIDTH);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
 
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, PADDING, PADDING);

    [self drawEdgeNumber:1 ofType:-3 inContext:ctx];
    [self drawEdgeNumber:2 ofType:2 inContext:ctx];
    [self drawEdgeNumber:3 ofType:3 inContext:ctx];
    [self drawEdgeNumber:4 ofType:-2 inContext:ctx];

    /*
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    */
    
    //CGPathRef path = CGContextCopyPath(ctx);

    CGContextClip(ctx);
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

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
