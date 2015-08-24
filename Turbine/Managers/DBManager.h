//
//  DBManager.h
//  Turbine
//
//  Created by Tommy Brown on 8/24/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+ (DBManager *) getSharedInstance;
- (BOOL) createHandleDatabase;
- (BOOL) insertHandle:(NSString *)handle;
- (BOOL) deleteHandle:(NSString *)handle;
- (NSArray *) getAllHandles;

@end
