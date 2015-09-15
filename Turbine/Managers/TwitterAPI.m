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
        
        [self getBearerToken];
    }
    return self;
}

- (void) getBearerToken{
    NSDictionary *parameters = @{@"grant_type": @"client_credentials"};
    
    [afManager.requestSerializer setValue:[@"Basic " stringByAppendingString:ENCODED_TWITTER_SECRET] forHTTPHeaderField:@"Authorization"];
    [afManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [afManager POST:@"https://api.twitter.com/oauth2/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
