//
//  PieceView.m
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "PieceView.h"
#import "PuzzleController.h"

@implementation PieceView

@synthesize image, number, isLifted, isPositioned, isFree, edges, position, angle, size, tempAngle, boxHeight, padding, delegate, neighbors, hasNeighbors, oldPosition, centerView, isRotating;


- (void)setup {
    
            
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [pan setMinimumNumberOfTouches:1];
    [pan setMaximumNumberOfTouches:1];
    pan.delaysTouchesBegan = YES;

    [self addGestureRecognizer:pan];

    
    UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];    
    [self addGestureRecognizer:rot];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateTap:)];
    tap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tap];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    centerView = [[UIView alloc] init];
    centerView.backgroundColor = [UIColor blackColor];
    centerView.alpha = 0.5;
    [self addSubview:centerView];
        
        
}

- (void)pulse {
    
	CATransform3D trasform = CATransform3DScale(self.layer.transform, 1.15, 1.15, 1);
    trasform = CATransform3DRotate(trasform, angle, 0, 0, 0);
    //self.layer.transform = trasform;
    
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:trasform];
	animation.autoreverses = YES;
	animation.duration = 0.3;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	animation.repeatCount = 2;
	[self.layer addAnimation:animation forKey:@"pulseAnimation"];
    
}



#pragma mark
#pragma GESTURE HANDLING

-(BOOL)isNeighborOf:(PieceView*)piece {
    
    for (PieceView *p in [self allTheNeighborsBut:nil]) {
        
        if (p.number==piece.number) {
            
            return YES;
        }
    }
    
    return NO;
}

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b firstWeight:(float)f {
    
    return CGPointMake(f*a.x+(1-f)*b.x, f*a.y+(1-f)*b.y);
    
}

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b {
    
    return CGPointMake(a.x+b.x, a.y+b.y);
    
}

- (void)translateWithVector:(CGPoint)traslation {

    CGPoint newOrigin = [self sum:self.frame.origin plus:traslation];
    CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
    self.frame = newFrame;
}

- (void)movedNeighborhoodExcludingPieces:(NSMutableArray*)excluded {
    
    for (int j=0; j<[neighbors count]; j++) {
        
        int i = [[neighbors objectAtIndex:j] intValue];
        
        if (i<delegate.N) {
            PieceView *piece = [delegate pieceWithNumber:i];
            
            BOOL present = NO;
            for (PieceView *p in excluded) {
                
                if (piece==p) {
                    present = YES;
                }
            }
            
            if (!present) {
                [excluded addObject:piece];
                [piece movedNeighborhoodExcludingPieces:excluded];
                [delegate pieceMoved:piece];
            } else {
            }
            
        }
    }
    
}

- (void)translateNeighborhoodExcluding:(NSMutableArray*)excluded WithVector:(CGPoint)traslation {
 
    for (int j=0; j<[neighbors count]; j++) {
        
        int i = [[neighbors objectAtIndex:j] intValue];
        
        if (i<delegate.N) {
            //NSLog(@"From piece #%d, translating the other, i=%d", self.number ,i);
            PieceView *piece = [delegate pieceWithNumber:i];
            
            BOOL present = NO;
            for (PieceView *p in excluded) {
                
                if (piece==p) {
                    present = YES;
                }
            }
            
            if (!present) {
                [piece translateWithVector:traslation];
                [excluded addObject:piece];
                [piece translateNeighborhoodExcluding:excluded WithVector:traslation];
            }
        }
    }
    
//    for (PieceView *p in [self allTheNeighborsBut:nil]) {
//        p.position = [delegate positionOfPiece:p];
//    }
//    self.position = [delegate positionOfPiece:self]; 
    
}

- (BOOL)areTherePiecesBeingRotated {
    
    BOOL rotating = NO;
    
    for (PieceView *p in delegate.pieces) {
        if (p.isRotating && !p.isFree) {
            return YES;
        }
    }
    
    return rotating;

    
}

- (void)move:(UIPanGestureRecognizer*)gesture {
    
    CGPoint traslation = [gesture translationInView:self.superview];
                
        if (gesture.state == UIGestureRecognizerStateBegan) {
            
            [self.superview bringSubviewToFront:self];
            oldPosition = [self realCenter];
            tr = 0;
            
        }
        
        if (isFree || isLifted) {
            
            NSMutableArray *excluded = [[NSMutableArray alloc] initWithObjects:self, nil];
            
            [self translateWithVector:traslation];
            [self translateNeighborhoodExcluding:excluded WithVector:traslation];
            
            [gesture setTranslation:CGPointZero inView:self.superview];
            
            
            if (gesture.state == UIGestureRecognizerStateEnded) {
                
                NSMutableArray *excluded = [[NSMutableArray alloc] initWithObjects:self, nil];
                [self movedNeighborhoodExcludingPieces:excluded];
                [delegate pieceMoved:self];
                
            }
            
        } else { //Inside the drawer
            
            if (UIInterfaceOrientationIsLandscape(self.delegate.interfaceOrientation)) {
                
                if (ABS(traslation.x)<delegate.piceSize/4 || ABS(tr)>delegate.piceSize/4) {
                    tr += ABS(traslation.y);
                    [delegate panDrawer:gesture];
                } else {
                    [self translateWithVector:CGPointMake(traslation.x, 0)];
                    [gesture setTranslation:CGPointZero inView:self.superview];
                    self.isLifted = YES;
                }
                
            } else {
                
                if (ABS(traslation.y)<delegate.piceSize/4 || ABS(tr)>delegate.piceSize/4 ) {
                    tr += ABS(traslation.x);
                    [delegate panDrawer:gesture];
                } else {
                    [self translateWithVector:CGPointMake(0, traslation.y)];
                    [gesture setTranslation:CGPointZero inView:self.superview];
                    self.isFree = YES;
                }
            }
            
        }
        
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
}

- (void)rotate:(UIRotationGestureRecognizer*)gesture {
    
    if (!self.hasNeighbors) {
        
        float rotation = [gesture rotation];
        
        if ([gesture state]==UIGestureRecognizerStateEnded || [gesture state]==UIGestureRecognizerStateCancelled || [gesture state]==UIGestureRecognizerStateFailed) {
            
            int t = floor(ABS(tempAngle)/(M_PI/4));
            
            if (t%2==0) {
                t/=2;
            } else {
                t= (t+1)/2;
            }
            
            rotation = angle + tempAngle/ABS(tempAngle) * t*M_PI/2;
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.transform = CGAffineTransformMakeRotation(rotation);
                
            }completion:^(BOOL finished) {

                self.isRotating = NO;
                delegate.drawerView.userInteractionEnabled = YES;

            }];
            
            angle = rotation - floor(rotation/(M_PI*2))*M_PI*2;
            angle = [PuzzleController float:angle modulo:2*M_PI];
            if (angle>6.1) {
                angle = 0.0;
            }
            
            //NSLog(@"Angle = %.2f, Rot = %.2f, added +/- %d", angle, rotation, t);
            tempAngle = 0;
            
            [delegate pieceRotated:self];
            
            
        } else if (gesture.state==UIGestureRecognizerStateBegan || gesture.state==UIGestureRecognizerStateChanged){
            
            delegate.drawerView.userInteractionEnabled = NO;
            
            self.isRotating = YES;
            self.transform = CGAffineTransformRotate(self.transform, rotation);
            tempAngle += rotation;
        }
        
        //NSLog(@"Angle = %.2f, Temp = %.2f", angle, tempAngle);
        
        
        [gesture setRotation:0];
        
    }
    
    
}

- (void)rotateTap:(UITapGestureRecognizer*)gesture {
        
    
    angle += M_PI_2;
    angle = [PuzzleController float:angle modulo:2*M_PI];
    
    centerView.frame = CGRectZero;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.transform = CGAffineTransformMakeRotation(angle);
        
    }];
    
    
    //Rotate the neighborhood
    for (PieceView *p in [self allTheNeighborsBut:[NSMutableArray arrayWithObject:self]]) {


        
            UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
        
            CGPoint selfOrigin = [mainWindow convertPoint:[self realCenter] fromWindow:nil];
            CGPoint pOrigin = [mainWindow convertPoint:[p realCenter] fromWindow:nil];
            
            pOrigin = [p convertPoint:pOrigin fromView:mainWindow];
            selfOrigin = [p convertPoint:selfOrigin fromView:mainWindow];
            
            
            
            float x = (selfOrigin.x-pOrigin.x);
            float y = (selfOrigin.y-pOrigin.y);
            
            
            //NSLog(@"Old transform \n\n%.1f, %.1f, \n%.1f, %.1f    traslation (%.1f, %.1f)", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
            
            CGAffineTransform matrix = CGAffineTransformIdentity;
            matrix = CGAffineTransformRotate(matrix,0);
            
            //NSLog(@"Matrix \n\n%.1f, %.1f, \n%.1f, %.1f    traslation (%.1f, %.1f)", matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
            
            float xx = x;
            float yy = y;
            
            x = xx*matrix.a + yy*matrix.b;
            y = xx*matrix.c + yy*matrix.d;
            
            //NSLog(@"(%.1f,%.1f)", x, y );
            //p.centerView.frame = CGRectMake(x, y, 10, 10);
            
            
            
            CGAffineTransform transform = p.transform;
            transform = CGAffineTransformTranslate(transform , -x, -y);
            transform = CGAffineTransformRotate(transform,-M_PI_2);
            transform = CGAffineTransformTranslate(transform, x,y);
        transform = CGAffineTransformRotate(transform,M_PI);
            
            //NSLog(@"New transform \n\n%.1f, %.1f, \n%.1f, %.1f    traslation (%.1f, %.1f)", transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
            
            p.angle = angle;
            
            [UIView animateWithDuration:0.2 animations:^{
                
                p.transform = transform;

                
            } completion:^(BOOL finished){
                
                CGPoint point = p.center;
                point.x += transform.tx;
                point.y += transform.ty;
                p.transform = CGAffineTransformMakeRotation(p.angle);
                p.center = point;
                
                //p.transform = originalTransform;
                
            }];
        
        
            
        
        
        
        
    }

    BOOL areOut = NO;
    for (PieceView *p in [self allTheNeighborsBut:[NSMutableArray arrayWithObject:self]]) {
        if ([delegate pieceIsOut:p]) {
            areOut = YES;
            break;
        }
    }

    
    if (!areOut) {
        
        for (PieceView *p in [self allTheNeighborsBut:[NSMutableArray arrayWithObject:self]]) {
            [delegate pieceRotated:p];
        }
        [delegate pieceRotated:self];

    } else {
    
        
        [UIView animateWithDuration:0.2 animations:^{
            
            for (PieceView *p in [self allTheNeighborsBut:[NSMutableArray arrayWithObject:self]]) {
                CGRect rect = p.frame;
                rect.origin.x = p.oldPosition.x-p.frame.size.width/2;
                rect.origin.y = p.oldPosition.y-p.frame.size.height/2;
                p.frame = rect;                
                p.position = [delegate positionOfPiece:p];
                p.transform = CGAffineTransformMakeRotation(p.angle-M_PI_2);
                p.angle -= M_PI_2;
            }
            
            self.transform = CGAffineTransformMakeRotation(self.angle-M_PI_2);
            self.angle -= M_PI_2;
            
        }];

    }
    
        

    
}




#pragma mark
#pragma DRAWING

#define CO_PADDING 0

- (void)drawEdgeNumber:(int)n ofType:(int)type inContext:(CGContextRef)ctx {
    
    float x = self.frame.size.width;
    float y = self.frame.size.height;
    float l;
    float p = self.padding;
    
    BOOL vertical = NO;
    int sign = 1;
    
    CGPoint a = CGPointZero;
    CGPoint b = CGPointZero;
        
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
            p2 = [self sum:p2 plus:CGPointMake(sign*(p-CO_PADDING), 0)];
        } else {
            p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-CO_PADDING))];
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
                p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-CO_PADDING))];
                p3 = [self sum:p2 plus:CGPointMake(l3, 0)];
                p4 = [self sum:point plus:CGPointMake(l3, 0)];
                break;
            case 2:
                p2 = [self sum:p2 plus:CGPointMake(sign*(p-CO_PADDING), 0)];
                p3 = [self sum:p2 plus:CGPointMake(0, l3)];
                p4 = [self sum:point plus:CGPointMake(0 , l3)];
                break;
            case 3:
                p2 = [self sum:p2 plus:CGPointMake(0, sign*(p-CO_PADDING))];
                p3 = [self sum:p2 plus:CGPointMake(-l3, 0)];
                p4 = [self sum:point plus:CGPointMake(-l3, 0)];
                break;
            case 4:
                p2 = [self sum:p2 plus:CGPointMake(sign*(p-CO_PADDING), 0)];
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


#define LINE_WIDTH 2

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.75);
    CGContextSetLineWidth(ctx, LINE_WIDTH);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
 
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.padding, self.padding);

    for (int i=1; i<5; i++) {
        int e = [[edges objectAtIndex:i-1] intValue];
        [self drawEdgeNumber:i ofType:e inContext:ctx];
    }

    /*
    */
    
    //CGPathRef path = CGContextCopyPath(ctx);

    CGContextClip(ctx);
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];


    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.padding, self.padding);
    
    for (int i=1; i<5; i++) {
        int e = [[edges objectAtIndex:i-1] intValue];
        [self drawEdgeNumber:i ofType:e inContext:ctx];
    }
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathStroke);
}


-(int)edgeNumber:(int)i {
    
    return [[edges objectAtIndex:i] intValue];
}

-(void)setNeighborNumber:(int)i forEdge:(int)edge {
    

    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (int j=0; j<4; j++) {
        
        if (j==edge) {
            [temp addObject:[NSNumber numberWithInt:i]];
        } else {
            [temp addObject:[neighbors objectAtIndex:j]];
        }
        
    }
    
    neighbors = [[NSArray alloc] initWithArray:temp];
    
    //NSLog(@"Setting neighbor #%d (edge %d) for piece #%d", [[neighbors objectAtIndex:edge] intValue], edge, self.number);
    
    hasNeighbors = YES;
    
}


- (NSArray*)allTheNeighborsBut:(NSMutableArray*)excluded {
    
    if (excluded==nil) {
        excluded = [[NSMutableArray alloc] init];
    }
    [excluded addObject:self];
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:delegate.N-1];
            
        for (int j=0; j<[neighbors count]; j++) {
            
            int i = [[neighbors objectAtIndex:j] intValue];
            
            
            if (i<delegate.N) {
                PieceView *otherPiece = [delegate pieceWithNumber:i];
                
                BOOL present = NO;
                for (PieceView *p in excluded) {
                                        
                    if (otherPiece.number==p.number) {
                        present = YES;
                    }
                }
                
                
                if (!present) {
                    [temp addObject:otherPiece];
                }
            }
        }            
    
    NSMutableArray *temp2 = [[NSMutableArray alloc] initWithArray:temp];
    [excluded addObjectsFromArray:temp];

    for (PieceView *p in temp2) {
        [temp addObjectsFromArray:[p allTheNeighborsBut:excluded]];
    }
    
    
    //NSLog(@"Neighbors: %d", [temp count]);
    
    return [NSArray arrayWithArray:temp];
}


#pragma mark
#pragma UNUSEFUL

- (id)initWithFrame:(CGRect)frame padding:(float)p
{
    
    padding = p;
    boxHeight = frame.size.height;

    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
        
    }
    return self;
}

- (void)awakeFromNib {
    
    [self setup];
    
}

- (CGPoint)realCenter {
   
    return  CGPointMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

@end
