//
//  HandleListViewController.m
//  Turbine
//
//  Created by Tommy Brown on 7/26/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "HandleListViewController.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "TweetManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HandleListViewController (){
    DBManager *dbManager;
    TweetManager *tweetManager;
    NSMutableDictionary *handles;
    NSString *addHandleText;
}
@end

@implementation HandleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Handles";
    
    dbManager = [DBManager getSharedInstance];
    tweetManager = [TweetManager getSharedInstance];
    handles = [[dbManager getAllHandles] mutableCopy];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed:)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Actions

- (IBAction) addButtonPressed:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Handle" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self alertCancelButtonPressed];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self alertAddButtonPressed];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter handle:";
        [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction) backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) alertAddButtonPressed{
    if([addHandleText hasPrefix:@"@"]){
        addHandleText = [addHandleText substringFromIndex:1];
    }
    
    [tweetManager getDataForUser:addHandleText withCompletionBlock:^(NSString *screenName, NSURL *url) {
        [self gotUser:screenName withImageURL:url];
    }];
}

- (void) deleteButtonPressedAtIndexPath:(NSIndexPath *)indexPath{
    bool deleteSuccessful = [dbManager deleteHandle:[[handles objectForKey:HANDLES_HANDLE] objectAtIndex:indexPath.row]];
    bool tweetsDeleteSuccessful = [dbManager deleteAllTweetsForUser:[[handles objectForKey:HANDLES_HANDLE] objectAtIndex:indexPath.row]];
    
    NSLog(@"Handle delete: %d, Tweets delete: %d", deleteSuccessful, tweetsDeleteSuccessful);
    
    if(deleteSuccessful){
        [[handles objectForKey:HANDLES_HANDLE] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        NSLog(@"Error deleting handle: %@", [[handles objectForKey:HANDLES_HANDLE] objectAtIndex:indexPath.row]);
    }
}

- (void) alertCancelButtonPressed{
}

- (void) gotUser:(NSString *)user withImageURL:(NSURL *)url{
    bool addSuccess = [dbManager insertHandle:user imageURL:url];
    
    if(addSuccess){
        NSLog(@"Success adding %@", addHandleText);
        handles = [[dbManager getAllHandles] mutableCopy];
        [tweetManager getTimelineForUser:addHandleText];
        [self.tableView reloadData];
    }else{
        NSLog(@"Error adding %@", addHandleText);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[handles objectForKey:HANDLES_HANDLE] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *handleCellIdentifier = @"HandleCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:handleCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:handleCellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
    }
    
    cell.textLabel.text = [[handles objectForKey:HANDLES_HANDLE] objectAtIndex:indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[[handles objectForKey:HANDLES_IMAGEURL] objectAtIndex:indexPath.row] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.imageView.transform = CGAffineTransformMakeScale(0.65, 0.65);
    
    return cell;
}

- (NSArray *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        [self deleteButtonPressedAtIndexPath:indexPath];
    }];
    
    button.backgroundColor = UIColorFromRGB(0x960018);
    
    return @[button];
}

#pragma mark - UITableViewDelegate

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if (editingStyle == UITableViewCellEditingStyleDelete) {
        bool deleteSuccessful = [dbManager deleteHandle:[handles objectAtIndex:indexPath.row]];
        if(deleteSuccessful){
            [handles removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"Error deleting handle: %@", [handles objectAtIndex:indexPath.row]);
        }
        
    }*/
}

#pragma mark - UITextFieldDelegate

- (void)alertTextFieldDidChange:(UITextField *)sender{
    UIAlertController *alertController = (UIAlertController *) self.presentedViewController;
    if (alertController){
        addHandleText = sender.text;
    }
}

@end
