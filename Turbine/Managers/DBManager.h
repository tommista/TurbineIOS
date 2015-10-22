//
//  DBManager.h
//  Turbine
//
//  Created by Tommy Brown on 8/24/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

#define HANDLES_HANDLE @"handle"
#define HANDLES_IMAGEURL @"imageURL"

@interface DBManager : NSObject

+ (DBManager *) getSharedInstance;

- (BOOL) createTables;

- (BOOL) insertHandle:(NSString *)handle imageURL:(NSURL *)url;
- (BOOL) deleteHandle:(NSString *)handle;
- (NSArray *) getAllHandles;

- (BOOL) dropTweetsTable;
- (BOOL) insertTweet:(Tweet *) tweet;
- (BOOL) updateTweet:(Tweet *) tweet;
- (BOOL) deleteAllTweetsForUser:(NSString *)screenName;
- (NSArray *) getAllTweets;
- (NSArray *) getAllTweetsSorted;
- (NSArray *) getAllFormattedTweetsSorted;

@end
