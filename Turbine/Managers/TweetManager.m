//
//  TwitterAPI.m
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "TweetManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Secrets.h"
#import "DBManager.h"
#import "Tweet.h"

#define SAVED_ACCESS_TOKEN_KEY @"saved_access_token_key"

@interface TweetManager(){
    AFHTTPRequestOperationManager *afManager;
    NSString *twitterAccessToken;
    DBManager *dbManager;
    int fetchAllRemaining;
}
@end

static TweetManager *instance = nil;

@implementation TweetManager

+ (TweetManager *) getSharedInstance{
    if(!instance){
        instance = [[self alloc] init];
    }
    
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        afManager = [AFHTTPRequestOperationManager manager];
        dbManager = [DBManager getSharedInstance];
        
        twitterAccessToken = [self savedAccessToken];
        if(twitterAccessToken == nil || twitterAccessToken.length == 0){
            [self getBearerToken];
        }else{
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

- (void) fetchAllTimelines{
    NSArray *handles = [[dbManager getAllHandles] objectForKey:HANDLES_HANDLE];
    fetchAllRemaining = (int) handles.count;
    
    if(fetchAllRemaining == 0){
        NSLog(@"Finished fetching all timelines");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishGettingAllTimelines)]){
            [self.delegate didFinishGettingAllTimelines];
        }
        return;
    }
    
    for(NSString *handle in handles){
        [self getTimelineForUser:handle];
    }
}

- (void) getTimelineForUser:(NSString *)screenName{
    NSDictionary *parameters = @{@"screen_name" : screenName, @"count" : @"200"};
    
    [afManager.requestSerializer setValue:[@"Bearer " stringByAppendingString:twitterAccessToken] forHTTPHeaderField:@"Authorization"];
    
    [afManager GET:@"https://api.twitter.com/1.1/statuses/user_timeline.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *jsonData = responseObject;
        
        for(NSDictionary *json in jsonData){
            Tweet *tweet = [[Tweet alloc] initWithJsonData:json];
            
            if(tweet.expandedURL != nil && tweet.expandedURL.absoluteString.length > 0){
                
                /*if([self stringContainsKeywords:tweet.expandedURL.absoluteString]){
                    [dbManager insertTweet:tweet];
                    NSLog(@"Didn't need to shorten: %@", tweet.expandedURL.absoluteString);
                }else{
                    [self unshortenTweet:tweet];
                }*/
                [dbManager insertTweet:tweet];
            }
        }
        
        NSLog(@"Finished retrieving timeline for %@", screenName);
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishGettingTimeline)]){
            [self.delegate didFinishGettingTimeline];
        }
        
        if(fetchAllRemaining > 0){
            [self decrementFetchAllRemaining];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if(fetchAllRemaining > 0){
            [self decrementFetchAllRemaining];
        }
    }];
}

- (void) decrementFetchAllRemaining{
    fetchAllRemaining--;
    if(fetchAllRemaining == 0){
        NSLog(@"Finished fetching all timelines");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishGettingAllTimelines)]){
            [self.delegate didFinishGettingAllTimelines];
        }
    }
}

- (void) receivedAccessToken{
}

- (void) getDataForUser:(NSString *)user withCompletionBlock:(void (^)(NSString *screenName, NSURL *url))completion{
    NSDictionary *parameters = @{@"screen_name" : user};
    
    [afManager.requestSerializer setValue:[@"Bearer " stringByAppendingString:twitterAccessToken] forHTTPHeaderField:@"Authorization"];
    
    [afManager GET:@"https://api.twitter.com/1.1/users/show.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *jsonData = responseObject;
        NSString *rawString = [jsonData objectForKey:@"profile_image_url"];
        NSString *screenName = [jsonData objectForKey:@"screen_name"];
        completion(screenName, [NSURL URLWithString:rawString]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(nil, nil);
    }];
}

#pragma mark - Unshorten It

- (void) unshortenTweet:(Tweet *)tweet{
    
    NSString *unshortenedURL = tweet.expandedURL.absoluteString;
    
    NSDictionary *parameters = @{@"shortURL" : unshortenedURL, @"apiKey" : UNSHORTEN_IT_API_KEY, @"responseFormat" : @"json"};
    
    [afManager GET:@"http://api.unshorten.it/" parameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        NSString *fullURL = [responseObject objectForKey:@"fullurl"];
        
        if([self stringContainsKeywords:fullURL]){
            NSLog(@"FullURL: %@ original: %@", fullURL, unshortenedURL);
            [dbManager insertTweet:tweet];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - Helper

- (BOOL) stringContainsKeywords:(NSString *)string{
    NSString *modString = string.lowercaseString;
    return ([modString containsString:@"spotify"] || [modString containsString:@"soundcloud"] || [modString containsString:@"itunes"] || [modString containsString:@"youtube"]);
}

@end
