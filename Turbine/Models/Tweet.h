//
//  Tweet.h
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, strong, readonly) NSString *createdAt;
@property (nonatomic, strong, readonly) NSString *tweetId;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *user; // User
@property (nonatomic, strong, readonly) NSString *entities;// Entities
@property (nonatomic, strong, readonly) NSString *screenName;

- (id) initWithJsonData:(NSDictionary *)data;

@end
