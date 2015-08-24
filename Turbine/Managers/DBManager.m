//
//  DBManager.m
//  Turbine
//
//  Created by Tommy Brown on 8/24/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager(){
    NSString *databasePath;
}
@end

static DBManager *instance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+ (DBManager *) getSharedInstance{
    if(!instance){
        instance = [[self alloc] init];
    }
    
    return instance;
}

- (id) init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (BOOL) createHandleDatabase{
    return NO;
}

- (BOOL) insertHandle:(NSString *)handle{
    return NO;
}

- (BOOL) deleteHandle:(NSString *)handle{
    return NO;
}

- (NSArray *) getAllHandles{
    return nil;
}

@end
