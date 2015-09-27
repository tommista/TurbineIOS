//
//  TwitterAPI.h
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterAPI : NSObject

+ (TwitterAPI *) getSharedInstance;

- (void) getTimelineForUser:(NSString *)screenName;

@end
