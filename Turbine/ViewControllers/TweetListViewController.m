//
//  TweetListViewController.m
//  Turbine
//
//  Created by Tommy Brown on 7/26/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "TweetListViewController.h"
#import "HandleListViewController.h"
#import "AppDelegate.h"
#import "DBManager.h"
#import "TweetManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SettingsViewController.h"

@interface TweetListViewController (){
    DBManager *dbManager;
    TweetManager *tweetManager;
    NSArray *tweetsArray;
}
@end

@implementation TweetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dbManager = [DBManager getSharedInstance];
    tweetManager = [TweetManager getSharedInstance];
    tweetManager.delegate = self;
    
    tweetsArray = [[NSArray alloc] init];
    tweetsArray = [dbManager getAllTweets];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed:)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = UIColorFromRGB(0x960018);
    [self.refreshControl addTarget:self action:@selector(refreshPulled:) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Turbine";
    tweetsArray = [dbManager getAllTweets];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated{
    self.navigationItem.title = @" ";
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction) listButtonPressed:(id)sender{
    HandleListViewController *handleListVC = [[HandleListViewController alloc] initWithNibName:@"HandleListViewController" bundle:nil];
    [self.navigationController pushViewController:handleListVC animated:YES];
}

- (IBAction) settingsButtonPressed:(id)sender{
    //NSLog(@"%@", [dbManager getAllTweets]);
    //[dbManager dropTweetsTable];
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (IBAction) refreshPulled:(id)sender{
    [tweetManager fetchAllTimelines];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweetsArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Tweet *tweet = [tweetsArray objectAtIndex:indexPath.row];
    int estimatedHeight = 0;
    if(tweet.text.length > 120){
        estimatedHeight = 120;
    }else if(tweet.text.length > 50){
        estimatedHeight = 100;
    }else{
        estimatedHeight = 75;
    }
    
    NSLog(@"Size: %d, Estimated: %d", tweet.text.length, estimatedHeight);
    return estimatedHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
    Tweet *tweet = [tweetsArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tweet.screenName];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tweet.screenName];
        cell.textLabel.font = [UIFont fontWithName:@"PTSans-Bold" size:18.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"PT Sans" size:14.0];
        cell.detailTextLabel.numberOfLines = 0;
        [cell.imageView sd_setImageWithURL:tweet.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    cell.textLabel.text = tweet.screenName;
    cell.detailTextLabel.text = tweet.text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tweet *tweet = [tweetsArray objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:tweet.expandedURL];
}

#pragma mark - TwitterAPIDelegate

- (void) didFinishGettingTimeline{
    if(![self.refreshControl isRefreshing]){
        tweetsArray = [dbManager getAllTweets];
        [self.tableView reloadData];
    }
}

- (void) didFinishGettingAllTimelines{
    [self.refreshControl endRefreshing];
    tweetsArray = [dbManager getAllTweets];
    [self.tableView reloadData];
}

@end
