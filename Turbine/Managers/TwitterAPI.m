//
//  TwitterAPI.m
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "TwitterAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "Secrets.h"
#import "DBManager.h"
#import "Tweet.h"

#define SAVED_ACCESS_TOKEN_KEY @"saved_access_token_key"

@interface TwitterAPI(){
    AFHTTPRequestOperationManager *afManager;
    NSString *twitterAccessToken;
}
@end

static TwitterAPI *instance = nil;

@implementation TwitterAPI

+ (TwitterAPI *) getSharedInstance{
    if(!instance){
        instance = [[self alloc] init];
    }
    
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        afManager = [AFHTTPRequestOperationManager manager];
        
        twitterAccessToken = [self savedAccessToken];
        if(twitterAccessToken == nil || twitterAccessToken.length == 0){
            [self getBearerToken];
        }else{
            [self getTimelineForUser:@"thomasbrown333"];
        }
    }
    return self;
}

- (NSString *) savedAccessToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SAVED_ACCESS_TOKEN_KEY];
}

- (void) saveAccessToken:(NSString *)token{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:SAVED_ACCESS_TOKEN_KEY];
    [defaults synchronize];
}

- (void) getBearerToken{
    NSDictionary *parameters = @{@"grant_type": @"client_credentials"};
    
    [afManager.requestSerializer setValue:[@"Basic " stringByAppendingString:ENCODED_TWITTER_SECRET] forHTTPHeaderField:@"Authorization"];
    [afManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [afManager POST:@"https://api.twitter.com/oauth2/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        twitterAccessToken = [responseObject objectForKey:@"access_token"];
        [self saveAccessToken:twitterAccessToken];
        [self receivedAccessToken];
        NSLog(@"Token: %@", twitterAccessToken);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) getTimelineForUser:(NSString *)screenName{
    NSDictionary *parameters = @{@"screen_name" : screenName, @"count" : @"200"};
    
    [afManager.requestSerializer setValue:[@"Bearer " stringByAppendingString:twitterAccessToken] forHTTPHeaderField:@"Authorization"];
    
    [afManager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = responseObject;
        NSMutableArray *tweetArray = [[NSMutableArray alloc] init];
        
        for(NSDictionary *json in jsonData){
            [tweetArray addObject:[[Tweet alloc] initWithJsonData:json]];
            [[DBManager getSharedInstance] insertTweet:tweetArray.lastObject];
            Tweet *asdf = (Tweet *)[tweetArray lastObject];
            NSLog(@"Added TweetId: %@ by %@", asdf.tweetId, asdf.screenName);
        }
        
        NSLog(@"%@", [[DBManager getSharedInstance] getAllTweets]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) receivedAccessToken{
    [self getTimelineForUser:@"thomasbrown333"];
}

@end
