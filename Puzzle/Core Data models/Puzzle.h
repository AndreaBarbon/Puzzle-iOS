//
//  Puzzle.h
//  Puzzle
//
//  Created by Andrea Barbon on 13/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image, Piece;

@interface Puzzle : NSManagedObject

@property (nonatomic, retain) NSNumber * elapsedTime;
@property (nonatomic, retain) NSDate * lastSaved;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * percentage;
@property (nonatomic, retain) NSNumber * pieceNumber;
@property (nonatomic, retain) NSNumber * moves;
@property (nonatomic, retain) NSNumber * rotations;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) Image *image;
@property (nonatomic, retain) NSSet *pieces;
@end

@interface Puzzle (CoreDataGeneratedAccessors)

- (void)addPiecesObject:(Piece *)value;
- (void)removePiecesObject:(Piece *)value;
- (void)addPieces:(NSSet *)values;
- (void)removePieces:(NSSet *)values;
@end
