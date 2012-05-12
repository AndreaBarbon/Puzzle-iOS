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

#define IMAGE_SIZE_BOUND_IPAD 2*PIECE_SIZE_IPAD
#define IMAGE_SIZE_BOUND_IPHONE 3*PIECE_SIZE_IPHONE

#define JPG_QUALITY 1
#define SHAPE_QUALITY_IPAD 1
#define SHAPE_QUALITY_IPHONE 1.5


@implementation CreatePuzzleOperation

@synthesize insertionContext, persistentStoreCoordinator, delegate, loadingGame;

- (void)main {
    
    float IMAGE_SIZE_BOUND = 0;
    float SHAPE_QUALITY = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
     
        IMAGE_SIZE_BOUND = IMAGE_SIZE_BOUND_IPAD;
        SHAPE_QUALITY = SHAPE_QUALITY_IPAD;
        
    } else {  

        IMAGE_SIZE_BOUND = IMAGE_SIZE_BOUND_IPHONE;
        SHAPE_QUALITY = SHAPE_QUALITY_IPHONE;

    }    
    
    //Create context on background thread
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    insertionContext = [[NSManagedObjectContext alloc] init];
    [insertionContext setUndoManager:nil];
    [insertionContext setPersistentStoreCoordinator: [appDelegate persistentStoreCoordinator]];
    
    
    if (delegate && [delegate respondsToSelector:@selector(puzzleSaved:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(puzzleSaved:) name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
    }

    
    float piceSize = SHAPE_QUALITY*delegate.piceSize;
    float pieceNumber = delegate.pieceNumber;
    float NumberSquare = delegate.NumberSquare;
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    NSMutableArray *array;
    
    if (loadingGame) {
        
        if (delegate.image==nil) {
            return;
        }
        
    } else {
        
        //Compute the optimal part size
        
        float partSize = delegate.image.size.width/(delegate.pieceNumber*0.7);
        
        if (partSize>IMAGE_SIZE_BOUND) {
            
            partSize = IMAGE_SIZE_BOUND;
        }
        
        //and split the big image using computed size
        
        float f = (float)(pieceNumber*partSize*0.7);
        image = [[UIImage alloc] init];
        image = [delegate.image imageByScalingToSize:CGSizeMake(f,f)];
        array = [[NSMutableArray alloc] initWithArray:[self splitImage:image partSize:partSize]];

    }
    
    
    
    BOOL errors = YES;
    
    @try {
        if (loadingGame) {
            
            NSLog(@"Loading in background");     
            
            for (int i=0;i<pieceNumber;i++){
                for (int j=0;j<pieceNumber;j++){
                    
                    CGRect rect = CGRectMake( 0, 0, piceSize, piceSize);
                    
                    Piece *pieceDB = [delegate pieceOfCurrentPuzzleDB:j+pieceNumber*i];
                    
                    if (pieceDB!=nil) {
                        
                        PieceView *piece = [[PieceView alloc] initWithFrame:rect];
                        piece.delegate = delegate;
                        piece.image = [UIImage imageWithData:pieceDB.image.data];
                        piece.number = j+pieceNumber*i;
                        piece.size = piceSize;
                        piece.isFree = (BOOL)pieceDB.isFree;
                        piece.position = [pieceDB.position intValue];
                        piece.angle = [pieceDB.angle floatValue];
                        piece.transform = CGAffineTransformMakeRotation(piece.angle);
                        
                        piece.frame = rect;
                        
                        NSNumber *n = [NSNumber numberWithInt:NumberSquare];
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
                        [delegate.view addSubview:piece];
                        //piece.transform = CGAffineTransformMakeScale(0.5, 0.5);
                        
                        
                    }
                    
                }
            }
            
            
            errors = NO;
            
        } else {
            
            //NSLog(@"Starting creating puzzle in the DB");
            
            Puzzle *puzzleDB = [self newPuzzleInCOntext:insertionContext];
            Image *imageDB = [self newImageInCOntext:insertionContext];
            imageDB.data = UIImageJPEGRepresentation(delegate.image, JPG_QUALITY);
            puzzleDB.lastSaved = [NSDate date];
            puzzleDB.image = imageDB;
            puzzleDB.pieceNumber = [NSNumber numberWithInt:delegate.pieceNumber];
            puzzleDB.name = @"007";
            
            
            NSLog(@"Memory b4 creating:");        
            [delegate print_free_memory];
            
            
            for (int i=0;i<pieceNumber;i++){
                
                for (int j=0;j<pieceNumber;j++){
                    
                    CGRect rect = CGRectMake( 0, 0, piceSize, piceSize);
                    
                    PieceView *piece = [[PieceView alloc] initWithFrame:rect];
                    piece.delegate = delegate;
                    piece.image = [array objectAtIndex:0]; //j+pieceNumber*i];
                    piece.number = j+pieceNumber*i;
                    piece.size = piceSize;
                    piece.position = -1;
                    NSNumber *n = [NSNumber numberWithInt:NumberSquare];
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
                    
                    //Creating the piece in the database
                    Piece *pieceDB = [self newPieceInCOntext:insertionContext];
                    pieceDB.puzzle = puzzleDB;
                    pieceDB.number = [NSNumber numberWithInt:j+pieceNumber*i];
                    pieceDB.position = [NSNumber numberWithInt:-1];
                    Image *imagePieceDB = [self newImageInCOntext:insertionContext];
                    imagePieceDB.data = UIImageJPEGRepresentation([array objectAtIndex:0], JPG_QUALITY);
                    pieceDB.image = imagePieceDB;
                    
                    [array removeObjectAtIndex:0];

                    
                    pieceDB.edge0 = [piece.edges objectAtIndex:0];
                    pieceDB.edge1 = [piece.edges objectAtIndex:1];
                    pieceDB.edge2 = [piece.edges objectAtIndex:2];
                    pieceDB.edge3 = [piece.edges objectAtIndex:3];
                    
                    
                    [arrayPieces addObject:piece];
                    [delegate.view addSubview:piece];

                    //piece.transform = CGAffineTransformMakeScale(0.5, 0.5);
                    
                }
            }
            
            [insertionContext save:nil];

        }
        
        delegate.pieces = [[NSMutableArray alloc] initWithArray:arrayPieces];
        
        errors = NO;

        
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@", [exception description]);
        
    }
    @finally {
        
        if (!errors) {
            
            if (delegate && [delegate respondsToSelector:@selector(puzzleSaved:)]) {
                [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
            }
            if (delegate && [self.delegate respondsToSelector:@selector(addPiecesToView)]) {
                //[delegate addPiecesToView];
            }
            
                        
            NSLog(@"loading \"finally\"");
        
        } else {
            
            NSLog(@"Some errors occured");
            [delegate loadingFailed];
            delegate.loadedPieces = 0;

        }

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

- (NSArray *)splitImage:(UIImage *)im partSize:(float)partSize {
    
    float x = delegate.pieceNumber;
    float y= delegate.pieceNumber;
        
    float padding = partSize*0.15;
    
    NSLog(@"Splitting image w=%.1f, ww=%.1f, imageSize=%.1f", partSize, padding, im.size.width);
    
    delegate.loadedPieces = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:delegate.NumberSquare];
    for (int i=0;i<x;i++){
        for (int j=0;j<y;j++){
            
            CGRect rect = CGRectMake(i * (partSize-2*padding)-padding, 
                                     j * (partSize-2*padding)-padding, 
                                     partSize, partSize);
            
            [arr addObject:[im subimageWithRect:rect]]; 

            delegate.loadedPieces++;
            
            //[arr addObject:[self clipImage:im toRect:rect]];          
        }
    }
    
    return arr;
    
}

- (NSArray *)splitImage:(UIImage *)im{
    
    float x = delegate.pieceNumber;
    float y= delegate.pieceNumber;
    
    float w = QUALITY*delegate.piceSize;
    
    float ww = w*0.15;
    
    NSLog(@"Splitting image w=%.1f, ww=%.1f, imageSize=%.1f", w, ww, im.size.width);
    
    delegate.loadedPieces = 0;
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:delegate.NumberSquare];
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
