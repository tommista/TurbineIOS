//
//  AppDelegate.m
//  Turbine
//
//  Created by Tommy Brown on 7/26/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "AppDelegate.h"
#import "TweetListViewController.h"
#import "SettingsViewController.h"

#define RUN_BEFORE_KEY @"run_before_key"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UINavigationBar appearance].barTintColor = UIColorFromRGB(0x960018);
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"Nightmare Hero" size:32]};
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setupNSUserDefaults];
    
    TweetListViewController *tweetListVC = [[TweetListViewController alloc] initWithNibName:@"TweetListViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tweetListVC];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - First time actions

- (void) setupNSUserDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool runBefore = [defaults boolForKey:RUN_BEFORE_KEY];
    
    if(runBefore){
        NSLog(@"App has run before");
    }else{
        NSLog(@"App has not run before");
        [defaults setBool:YES forKey:RUN_BEFORE_KEY];
        [defaults setBool:YES forKey:FILTER_BY_ITUNES_KEY];
        [defaults setBool:YES forKey:FILTER_BY_OTHER_KEY];
        [defaults setBool:YES forKey:FILTER_BY_SOUNDCLOUD_KEY];
        [defaults setBool:YES forKey:FILTER_BY_SPOTIFY_KEY];
        [defaults setBool:YES forKey:FILTER_BY_YOUTUBE_KEY];
        [defaults synchronize];
    }
    
}

@end
