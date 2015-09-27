//
//  Tweet.h
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *tweetId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSArray *tweetURLs;
@property (nonatomic, strong) NSString *screenName;

- (id) initWithJsonData:(NSDictionary *)data;

@end
