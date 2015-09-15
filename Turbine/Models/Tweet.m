//
//  Tweet.m
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id) initWithJsonData:(NSDictionary *)data{
    self = [super init];
    if(self){
        _createdAt = [data objectForKey:@"created_at"];
        _tweetId = [data objectForKey:@"id_str"];
        _text = [data objectForKey:@"text"];
        _screenName = [data objectForKey:@"screen_name"];
        
        if([data objectForKey:@"user"]){
            _profileImageURL = [NSURL URLWithString:[[data objectForKey:@"user"] objectForKey:@"profile_image_url"]];
        }
        
        if([data objectForKey:@"entities"]){
            _tweetURLs = [[data objectForKey:@"entities"] objectForKey:@"urls"];
        }
    }
    return self;
}

@end
