//
//  TwitterAPI.h
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterAPIDelegate;

@interface TwitterAPI : NSObject

@property (weak, nonatomic) id<TwitterAPIDelegate> delegate;

+ (TwitterAPI *) getSharedInstance;

- (void) getTimelineForUser:(NSString *)screenName;

@end

@protocol TwitterAPIDelegate <NSObject>

@optional

- (void) didFinishGettingTimeline;

@end
