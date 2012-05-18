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
#define SHAPE_QUALITY_IPHONE 3


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

    
    float pieceNumber = delegate.pieceNumber;
    float NumberSquare = delegate.NumberSquare;
    
    
    
    
    
    
        
    NSMutableArray *arrayPieces = [[NSMutableArray alloc] initWithCapacity:NumberSquare];
    
    if (delegate.image==nil) {
        return;
    }
    
    
    
    BOOL errors = YES;
    
    @try {
        
        if (!delegate.loadingGame) {
            
            DLog(@"Starting creating puzzle in the DB");
            
            Puzzle *puzzleDB = [self newPuzzleInCOntext:insertionContext];
            Image *imageDB = [self newImageInCOntext:insertionContext];
            imageDB.data = UIImageJPEGRepresentation(delegate.image, JPG_QUALITY);
            puzzleDB.lastSaved = [NSDate date];
            puzzleDB.image = imageDB;
            puzzleDB.pieceNumber = [NSNumber numberWithInt:delegate.pieceNumber];
            puzzleDB.name = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
            
            
            DLog(@"Memory b4 creating:");        
            [delegate print_free_memory];
            
            
            for (int i=0;i<pieceNumber;i++){
                
                for (int j=0;j<pieceNumber;j++){
                    
                    //Creating the piece in the database
                    Piece *pieceDB = [self newPieceInCOntext:insertionContext];
                    pieceDB.puzzle = puzzleDB;
                    pieceDB.number = [NSNumber numberWithInt:j+pieceNumber*i];
                    pieceDB.position = [NSNumber numberWithInt:-1];
                    Image *imagePieceDB = [self newImageInCOntext:insertionContext];
                    imagePieceDB.data = UIImageJPEGRepresentation([[delegate pieceWithNumber:j+pieceNumber*i] image], JPG_QUALITY);
                    pieceDB.image = imagePieceDB;
                                        
                    
                    pieceDB.edge0 = [[[delegate pieceWithNumber:j+pieceNumber*i] edges] objectAtIndex:0];
                    pieceDB.edge1 = [[[delegate pieceWithNumber:j+pieceNumber*i] edges] objectAtIndex:1];
                    pieceDB.edge2 = [[[delegate pieceWithNumber:j+pieceNumber*i] edges] objectAtIndex:2];
                    pieceDB.edge3 = [[[delegate pieceWithNumber:j+pieceNumber*i] edges] objectAtIndex:3];
                    
                    
                    [arrayPieces addObject:pieceDB];
                }
            }

            [insertionContext save:nil];
        }
        

        errors = NO;
    }
    @catch (NSException *exception) {
        
        DLog(@"Some errors occured while creating the puzzle:");
        DLog(@"%@", [exception description]);
        
        [delegate loadingFailed];
        delegate.loadedPieces = 0;
    }
    @finally {
        
        DLog(@"Puzzle created in the DB");

        if (delegate && [delegate respondsToSelector:@selector(puzzleSaved:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:delegate name:NSManagedObjectContextDidSaveNotification object:self.insertionContext];
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
    
    DLog(@"Splitting image w=%.1f, ww=%.1f, imageSize=%.1f", partSize, padding, im.size.width);
    
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
    
    DLog(@"Splitting image w=%.1f, ww=%.1f, imageSize=%.1f", w, ww, im.size.width);
    
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
