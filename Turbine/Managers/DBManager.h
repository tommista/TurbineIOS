//
//  DBManager.h
//  Turbine
//
//  Created by Tommy Brown on 8/24/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface DBManager : NSObject

+ (DBManager *) getSharedInstance;

- (BOOL) createTables;

- (BOOL) insertHandle:(NSString *)handle;
- (BOOL) deleteHandle:(NSString *)handle;
- (NSArray *) getAllHandles;

- (BOOL) insertTweet:(Tweet *) tweet;
- (BOOL) deleteAllTweetsForUser:(NSString *)screenName;
- (NSArray *) getAllTweets;

@end
