//
//  NSObject+Que.h
//  Puzzle
//
//  Created by Andrea Barbon on 03/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SharedQueue)
-(void)performOperation:(NSOperation*)operation;
@end


@interface NSOperationQueue (SharedQueue)
+(NSOperationQueue*)sharedOperationQueue;
@end
