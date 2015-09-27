//
//  TweetListViewController.m
//  Turbine
//
//  Created by Tommy Brown on 7/26/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "TweetListViewController.h"
#import "HandleListViewController.h"
#import "DBManager.h"
#import "TwitterAPI.h"

@interface TweetListViewController (){
    DBManager *dbManager;
    TwitterAPI *twitter;
}
@end

@implementation TweetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dbManager = [DBManager getSharedInstance];
    twitter = [TwitterAPI getSharedInstance];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonPressed:)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fire"]];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshPulled:) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Turbine";
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
    
}

- (IBAction) refreshPulled:(id)sender{
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tweetCellIdentifier = @"TweetCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tweetCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tweetCellIdentifier];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        bool test = [dbManager insertHandle:@"Test"];
        NSLog(@"Inserted Test: %d", test);
    }else if(indexPath.row == 1){
        NSArray *array = [dbManager getAllHandles];
        NSLog(@"Handles: %@", array);
    }else if(indexPath.row == 2){
        bool test = [dbManager deleteHandle:@"Test"];
        NSLog(@"delete handle: %d", test);
    }
}

@end
