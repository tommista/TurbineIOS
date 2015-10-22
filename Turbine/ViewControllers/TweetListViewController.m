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

#define TWEET_TEXT_SIZE 14.0

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
    tweetsArray = [dbManager getAllFormattedTweetsSorted];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed:)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = UIColorFromRGB(0x960018);
    [self.refreshControl addTarget:self action:@selector(refreshPulled:) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Turbine";
    tweetsArray = [dbManager getAllFormattedTweetsSorted];
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
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self presentViewController:settingsNav animated:YES completion:nil];
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
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n" options:NSRegularExpressionCaseInsensitive error:&error];
    int tweetSize = (int) tweet.text.length;
    int numberOfMatches = (int) [regex numberOfMatchesInString:tweet.text options:0 range:NSMakeRange(0, tweetSize)];
    estimatedHeight += TWEET_TEXT_SIZE * numberOfMatches;
    
    return estimatedHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
    Tweet *tweet = [tweetsArray objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tweet.screenName];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tweet.screenName];
        cell.textLabel.font = [UIFont fontWithName:@"PTSans-Bold" size:18.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"PT Sans" size:TWEET_TEXT_SIZE];
        cell.detailTextLabel.numberOfLines = 0;
        [cell.imageView sd_setImageWithURL:tweet.profileImageURL placeholderImage:[UIImage imageNamed:@"placeholderBig"]];
        cell.imageView.transform = CGAffineTransformMakeScale(0.65, 0.65);
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
        tweetsArray = [dbManager getAllFormattedTweetsSorted];
        [self.tableView reloadData];
    }
}

- (void) didFinishGettingAllTimelines{
    [self.refreshControl endRefreshing];
    tweetsArray = [dbManager getAllFormattedTweetsSorted];
    [self.tableView reloadData];
}

@end
