//
//  GroupView.m
//  Puzzle
//
//  Created by Andrea Barbon on 05/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "GroupView.h"
#import "PieceView.h"
#import "PuzzleController.h"

@implementation GroupView

@synthesize boss, pieces, angle, delegate;

- (void)translateWithVector:(CGPoint)traslation {

    self.transform = CGAffineTransformTranslate(self.transform, traslation.x, traslation.y);

}

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b {
    
    return CGPointMake(a.x+b.x, a.y+b.y);
    
}

- (void)rotate:(UIRotationGestureRecognizer*)gesture {
    
    NSLog(@"%s", __func__);
            
        float rotation = [gesture rotation];
        
        if ([gesture state]==UIGestureRecognizerStateEnded || [gesture state]==UIGestureRecognizerStateCancelled || [gesture state]==UIGestureRecognizerStateFailed) {
            
            int t = floor(ABS(tempAngle)/(M_PI/4));
            
            if (t%2==0) {
                t/=2;
            } else {
                t= (t+1)/2;
            }
            
            rotation = tempAngle/ABS(tempAngle) * t*M_PI/2 - tempAngle;
            
            angle += rotation;
            angle = [PuzzleController computeFloat:angle modulo:2*M_PI];
            [self setAngle:angle];
            
            //NSLog(@"Angle = %.2f, Rot = %.2f, added +/- %d", angle, rotation, t);
            
            [UIView animateWithDuration:0.2 animations:^{
                
                self.transform = CGAffineTransformRotate(self.transform, rotation);
                
            }completion:^(BOOL finished) {
                
                [delegate pieceRotated:self.boss];
            }];
            
            //            angle = rotation - floor(rotation/(M_PI*2))*M_PI*2;
            
            tempAngle = 0;
            
            
            
            
        } else if (gesture.state==UIGestureRecognizerStateBegan || gesture.state==UIGestureRecognizerStateChanged){
            
            delegate.drawerView.userInteractionEnabled = NO;
            
            self.transform = CGAffineTransformRotate(self.transform, rotation);
            tempAngle += rotation;
            angle += rotation;
            
        }
        
        //NSLog(@"Angle = %.2f, Temp = %.2f", angle, tempAngle);
        
        
        [gesture setRotation:0];
            
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        pieces = [[NSMutableArray alloc] init];
        //self.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:0.1];
        
        angle = 0;
        
        UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];    
        [self addGestureRecognizer:rot];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
