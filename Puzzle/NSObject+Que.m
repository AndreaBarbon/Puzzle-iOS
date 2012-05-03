//
//  NSObject+Que.m
//  Puzzle
//
//  Created by Andrea Barbon on 03/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "NSObject+Que.h"


@implementation NSOperationQueue (SharedQueue)
+(NSOperationQueue*)sharedOperationQueue;
{
    static NSOperationQueue* sharedQueue = nil;
    if (sharedQueue == nil) {
        sharedQueue = [[NSOperationQueue alloc] init];
    }
    return sharedQueue;
}
@end

@implementation NSObject (SharedQueue)
-(void)performOperation:(NSOperation*)operation;
{
    [[NSOperationQueue sharedOperationQueue] addOperation:operation];
}
@end