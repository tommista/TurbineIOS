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
        [self createTables];
    }
    return self;
}

- (BOOL) createTables{
    NSString *docsDir;
    BOOL isSuccess = YES;
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"handles.db"]];
    const char *dbpath = [databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        char *errorMessage;
        const char *sql_statement = "create table if not exists twitterHandles (handle)";
        if(sqlite3_exec(database, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK){
            isSuccess = NO;
            NSLog(@"Failed to create table twitterHandles");
        }
        
        sql_statement = "create table if not exists tweets (tweetId, createdAt, text, profileImageURL, tweetURLs, screenName, fullURL, PRIMARY KEY (tweetId))";
        if(sqlite3_exec(database, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK){
            isSuccess = NO;
            NSLog(@"Failed to create table tweets");
        }
        
        sqlite3_close(database);
        return isSuccess;
    }
    return isSuccess;
}

#pragma mark - Handles

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
        NSString *querySQL = @"select * from twitterHandles";
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

#pragma mark - Tweets

- (BOOL) insertTweet:(Tweet *)tweet{
    const char *dbpath = [databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"insert into tweets (tweetId, createdAt, text, profileImageURL, tweetURLs, screenName, fullURL) values (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", tweet.tweetId, [NSString stringWithFormat:@"%f", [tweet.createdAt timeIntervalSince1970]], tweet.text, tweet.profileImageURL.absoluteString, tweet.expandedURL.absoluteString, tweet.screenName.lowercaseString, (tweet.fullURL != nil) ? tweet.fullURL.absoluteString : nil];
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

- (BOOL) updateTweet:(Tweet *)tweet{
    const char *dbpath = [databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *updateSQL = [NSString stringWithFormat:@"update tweets set fullURL='%@' where tweetId='%@'", tweet.fullURL.absoluteString, tweet.tweetId];
        const char *insert_statement = [updateSQL UTF8String];
        sqlite3_prepare_v2(database, insert_statement, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE){
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

- (BOOL) deleteAllTweetsForUser:(NSString *)screenName{
    const char *dbpath = [databasePath UTF8String];
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from tweets where screenName=\"%@\"", screenName.lowercaseString];
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

- (NSArray *) getAllTweets{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *querySQL = @"select * from tweets";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            while(sqlite3_step(statement) == SQLITE_ROW){
                Tweet *tweet = [[Tweet alloc] init];
                tweet.tweetId = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                tweet.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                tweet.profileImageURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                tweet.expandedURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)]];
                tweet.screenName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                
                tweet.createdAt = [NSDate dateWithTimeIntervalSince1970:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)] doubleValue]];
                
                if(sqlite3_column_text(statement, 6) != nil){
                    NSString *fullURLStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                    if(fullURLStr != nil && fullURLStr.length > 0){
                        tweet.fullURL = [NSURL URLWithString:fullURLStr];
                    }
                }else{
                    tweet.fullURL = nil;
                }
                
                [resultArray addObject:tweet];
            }
            sqlite3_reset(statement);
            return resultArray;
        }
    }
    return nil;
}

- (BOOL) dropTweetsTable{
    const char *dbpath = [databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &database) == SQLITE_OK){
        NSString *insertSQL = @"drop table tweets";
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

@end
