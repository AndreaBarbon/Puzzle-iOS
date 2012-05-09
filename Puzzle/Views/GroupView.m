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

@synthesize boss, pieces, angle;

- (void)translateWithVector:(CGPoint)traslation {

    self.transform = CGAffineTransformTranslate(self.transform, traslation.x, traslation.y);

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        
}

-(CGPoint)sum:(CGPoint)a plus:(CGPoint)b {
    
    return CGPointMake(a.x+b.x, a.y+b.y);
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        pieces = [[NSMutableArray alloc] init];
        //self.backgroundColor = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:0.1];
        
        angle = 0;
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
