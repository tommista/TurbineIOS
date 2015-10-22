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
        
        NSString *createdAtStr = [data objectForKey:@"created_at"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //Format = Wed Aug 29 17:12:58 +0000 2012
        [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss +0000 yyyy"];
        _createdAt = [dateFormatter dateFromString:createdAtStr];
        

        _tweetId = [data objectForKey:@"id_str"];
        _text = [data objectForKey:@"text"];
        _fullURL = nil;
        
        if([data objectForKey:@"user"]){
            NSString *urlString = [[data objectForKey:@"user"] objectForKey:@"profile_image_url"];
            _profileImageURL = [NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]];
            _screenName = [[data objectForKey:@"user"] objectForKey:@"screen_name"];
        }
        
        if([data objectForKey:@"entities"]){
            NSArray *urls = [[data objectForKey:@"entities"] objectForKey:@"urls"];
            if(urls != nil && urls.count > 0){
                _expandedURL = [NSURL URLWithString:[[urls firstObject] objectForKey:@"expanded_url"]];
            }
        }
    }
    return self;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"TweetId: %@ by %@", self.tweetId, self.screenName];
}

@end
