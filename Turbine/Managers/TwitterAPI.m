//
//  TwitterAPI.m
//  Turbine
//
//  Created by Tommy Brown on 9/15/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "TwitterAPI.h"

@interface TwitterAPI(){

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

@end
