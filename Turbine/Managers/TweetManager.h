//
//  TwitterAPI.h
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterAPIDelegate;

@interface TweetManager : NSObject

@property (weak, nonatomic) id<TwitterAPIDelegate> delegate;

+ (TweetManager *) getSharedInstance;

- (void) fetchAllTimelines;
- (void) getTimelineForUser:(NSString *)screenName;

@end

@protocol TwitterAPIDelegate <NSObject>

@optional

- (void) didFinishGettingTimeline;
- (void) didFinishGettingAllTimelines;

@end
