//
//  CreatePuzzleOperation.m
//  Puzzle
//
//  Created by Andrea Barbon on 03/05/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import "CreatePuzzleOperation.h"
#import "PuzzleController.h"
#import "UIImage+CWAdditions.h"

@implementation CreatePuzzleOperation

@synthesize insertionContext, persistentStoreCoordinator, delegate, loadingGame;

- (void)main {
    
    if (delegate && [delegate respondsToSelector:@selector(puzzleDidSave:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(puzzleDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }

    
    float piceSize = delegate.piceSize;
    float padding = delegate.padding;
    float pieceNumber = delegate.pieceNumber;
    float N = delegate.N;
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:N];
    NSMutableArray *array;
    
    if (loadingGame) {
        
        if (delegate.image==nil) {
            return;
        }
        
    } else {
        
        array = [[NSMutableArray alloc] initWithArray:[self splitImage:delegate.image]];

    }

    

    piceSize = delegate.image.size.width/(delegate.pieceNumber*QUALITY*0.7);
    padding = piceSize*0.15;
    
    
    if (loadingGame) {
        
        NSLog(@"Loading in background");       
        
        for (int i=0;i<pieceNumber;i++){
            for (int j=0;j<pieceNumber;j++){
                
                CGRect rect = CGRectMake( 0, 0, piceSize, piceSize);
                
                Piece *pieceDB = [delegate pieceOfCurrentPuzzleDB:j+pieceNumber*i];
                
                if (pieceDB!=nil) {
                    
                    PieceView *piece = [[PieceView alloc] initWithFrame:rect padding:padding];
                    piece.delegate = delegate;
                    piece.image = [UIImage imageWithData:pieceDB.image.data];
                    piece.number = j+pieceNumber*i;
                    piece.size = piceSize;
                    piece.isFree = (BOOL)pieceDB.isFree;
                    piece.position = [pieceDB.position intValue];
                    piece.angle = [pieceDB.angle floatValue];
                    piece.transform = CGAffineTransformMakeRotation(piece.angle);
                    
                    piece.frame = rect;
                    
                    NSNumber *n = [NSNumber numberWithInt:N];
                    piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
                    
                    
                    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
                    [a addObject:pieceDB.edge0];
                    [a addObject:pieceDB.edge1];
                    [a addObject:pieceDB.edge2];
                    [a addObject:pieceDB.edge3];
                    
                    piece.edges = [NSArray arrayWithArray:a];
                    
                    for (int k=0; k<4; k++) {
                        //NSLog(@"Edge of %d, %d is %d", i, j, [[piece.edges objectAtIndex:k] intValue]);
                    }
                    
                    
                    [arrayPieces addObject:piece];
                    [piece setNeedsDisplay];
                    [delegate.view addSubview:piece];
                    
                    
                }
                
            }
        }
        
        
    } else {
        
        
        delegate.puzzleDB = nil;
        NSLog(@"Memory b4 creating:");        
        [delegate print_free_memory];
        
        
        for (int i=0;i<pieceNumber;i++){
            
            for (int j=0;j<pieceNumber;j++){
                
                CGRect rect = CGRectMake( 0, 0, piceSize, piceSize);

                PieceView *piece = [[PieceView alloc] initWithFrame:rect padding:padding];
                piece.delegate = delegate;
                piece.image = [array objectAtIndex:j+pieceNumber*i];
                piece.number = j+pieceNumber*i;
                piece.size = piceSize;
                piece.position = -1;
                NSNumber *n = [NSNumber numberWithInt:N];
                piece.neighbors = [[NSArray alloc] initWithObjects:n, n, n, n, nil];
                
                piece.frame = rect;
                
                
                NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:4];
                
                for (int k=0; k<4; k++) {
                    int e = arc4random_uniform(3)+1;
                    
                    if (arc4random_uniform(2)>0) {
                        e *= -1;
                    }
                    
                    [a addObject:[NSNumber numberWithInt:e]];
                }
                
                if (i>0) {
                    int l = [arrayPieces count]-pieceNumber;
                    int e = [[[[arrayPieces objectAtIndex:l] edges] objectAtIndex:1] intValue];
                    [a replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:-e]];
                    //NSLog(@"e = %d", e);
                }
                
                if (j>0) {
                    int e = [[[[arrayPieces lastObject] edges] objectAtIndex:2] intValue];
                    [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:-e]];
                    //NSLog(@"e = %d", e);
                }
                
                if (i==0) {
                    [a replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:0]];
                }
                if (i==pieceNumber-1) {
                    [a replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
                }
                if (j==0) {
                    [a replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
                }
                if (j==pieceNumber-1) {
                    [a replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
                }
                
                
                piece.edges = [NSArray arrayWithArray:a];
                
                for (int k=0; k<4; k++) {
                    //NSLog(@"Edge of %d, %d is %d", i, j, [[piece.edges objectAtIndex:k] intValue]);
                }
                
                
                [arrayPieces addObject:piece];
                [piece setNeedsDisplay];
                [delegate.view addSubview:piece];
                
            }
        }
                
                
    }
    
    delegate.pieces = [[NSArray alloc] initWithArray:arrayPieces];
        
    //[self createPuzzleInDB];



}


- (void)createPuzzleInDB {
    
    //NSLog(@"Starting creating puzzle in the DB");
    
    delegate.puzzleDB = [self newPuzzleInCOntext:insertionContext];
    Image *imageDB = [self newImageInCOntext:insertionContext];
    imageDB.data = UIImageJPEGRepresentation(delegate.image, 0.5);
    delegate.puzzleDB.image = imageDB;
    delegate.puzzleDB.pieceNumber = [NSNumber numberWithInt:delegate.pieceNumber];
    
    for (PieceView *piece in delegate.pieces) {
        
        //Creating the piece in the database
        Piece *pieceDB = [self newPieceInCOntext:insertionContext];
        pieceDB.puzzle = delegate.puzzleDB;
        pieceDB.number = [NSNumber numberWithInt:piece.number];
        pieceDB.position = [NSNumber numberWithInt:piece.position];
        pieceDB.angle = [NSNumber numberWithFloat:piece.angle];
        Image *imagePieceDB = [self newImageInCOntext:insertionContext];
        imagePieceDB.data = UIImageJPEGRepresentation(piece.image, 0.5);
        pieceDB.image = imagePieceDB;
        
        pieceDB.edge0 = [piece.edges objectAtIndex:0];
        pieceDB.edge1 = [piece.edges objectAtIndex:1];
        pieceDB.edge2 = [piece.edges objectAtIndex:2];
        pieceDB.edge3 = [piece.edges objectAtIndex:3];
        
    }
    
    
}


-(Puzzle*)newPuzzleInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Puzzle" 
            inManagedObjectContext:context];
}

-(Image*)newImageInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Image" 
            inManagedObjectContext:context];
}

-(Piece*)newPieceInCOntext:(NSManagedObjectContext*)context {
    
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"Piece" 
            inManagedObjectContext:context];
}



- (UIImage*)clipImage:(UIImage*)img toRect:(CGRect)rect {
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return newImage;
    
}

- (NSArray *)splitImage:(UIImage *)im{
    
    float x = delegate.pieceNumber;
    float y= delegate.pieceNumber;
    
    float w = im.size.width/(delegate.pieceNumber*QUALITY*0.7);
    
    float ww = w*0.15;
    
    NSLog(@"w=%.1f, ww=%.1f, imageSize=%.1f", w, ww, im.size.width);
    
    delegate.loadedPieces = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:delegate.N];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            
            delegate.loadedPieces++;
            CGRect rect = CGRectMake(i * (w-2*ww)-ww, j * (w-2*ww)-ww, w, w);
            [arr addObject:[im subimageWithRect:rect]];          
            //[arr addObject:[self clipImage:im toRect:rect]];          
        }
    }
    
    return arr;
    
}

@end
