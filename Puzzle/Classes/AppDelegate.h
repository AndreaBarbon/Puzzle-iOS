//
//  AppDelegate.h
//  Puzzle
//
//  Created by Andrea Barbon on 19/04/12.
//  Copyright (c) 2012 Università degli studi di Padova. All rights reserved.
//

#import <UIKit/UIKit.h>


#define FRACTAL_DEBUG

#ifdef FRACTAL_DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...);
#endif



#define APP_STORE_APP_ID 525717757
#define TIMES_B4_ASKING_TO_REIEW 5

#define YELLOW [UIColor colorWithRed:1.0 green:200.0/255.0 blue:0.0 alpha:1.0]
#define WOOD [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood.jpg"]]


#define IS_DEVICE_PLAUYING_MUSIC [[MPMusicPlayerController iPodMusicPlayer] playbackState] != MPMusicPlaybackStatePlaying


@class PuzzleController, CreatePuzzleOperation;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    BOOL wasOpened;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) PuzzleController *puzzle;
@property (nonatomic,retain) CreatePuzzleOperation *puzzleOperation;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
