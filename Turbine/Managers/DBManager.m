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
        [self createHandleDatabase];
    }
    return self;
}

- (BOOL) createHandleDatabase{
    NSString *docsDir;
    BOOL isSuccess = YES;
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"handles.db"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:databasePath] == NO){
        const char *dbpath = [databasePath UTF8String];
        if(sqlite3_open(dbpath, &database) == SQLITE_OK){
            char *errorMessage;
            const char *sql_statement = "create table if not exists twitterHandles (handle)";
            if(sqlite3_exec(database, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK){
                isSuccess = NO;
                NSLog(@"Failed to create table twitterHandles");
            }else{
                NSLog(@"@@@@ yay");
            }
            sqlite3_close(database);
            return isSuccess;
        }
    }
    return isSuccess;
}

- (BOOL) insertHandle:(NSString *)handle{
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"insert into twitterHandles (handle) values (\"%@\")", handle];
        const char *insert_statement = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_statement, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

- (BOOL) deleteHandle:(NSString *)handle{
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from twitterHandles where handle=\"%@\"", handle];
        const char *delete_statement = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_statement, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

- (NSArray *) getAllHandles{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"select * from twitterHandles"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                NSString *handle = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:handle];
            }
            sqlite3_reset(statement);
            return resultArray;
        }
    }
    return nil;
}

@end
