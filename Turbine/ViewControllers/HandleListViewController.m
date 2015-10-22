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

@interface HandleListViewController (){
    DBManager *dbManager;
    TweetManager *tweetManager;
    NSMutableArray *handles;
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
    if(![addHandleText hasPrefix:@"@"]){
        addHandleText = [@"@" stringByAppendingString:addHandleText];
    }
    
    [tweetManager getImageURLForUser:addHandleText withCompletionBlock:nil];
    
    bool addSuccess = [dbManager insertHandle:addHandleText];
    
    if(addSuccess){
        NSLog(@"Success adding %@", addHandleText);
        handles = [[dbManager getAllHandles] mutableCopy];
        [tweetManager getTimelineForUser:[addHandleText substringFromIndex:1]];
        [self.tableView reloadData];
    }else{
        NSLog(@"Error adding %@", addHandleText);
    }
}

- (void) deleteButtonPressedAtIndexPath:(NSIndexPath *)indexPath{
    bool deleteSuccessful = [dbManager deleteHandle:[handles objectAtIndex:indexPath.row]];
    bool tweetsDeleteSuccessful = [dbManager deleteAllTweetsForUser:[[handles objectAtIndex:indexPath.row] substringFromIndex:1]];
    
    NSLog(@"Handle delete: %d, Tweets delete: %d", deleteSuccessful, tweetsDeleteSuccessful);
    
    if(deleteSuccessful){
        [handles removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        NSLog(@"Error deleting handle: %@", [handles objectAtIndex:indexPath.row]);
    }
}

- (void) alertCancelButtonPressed{
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return handles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *handleCellIdentifier = @"HandleCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:handleCellIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:handleCellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
    }
    
    cell.textLabel.text = [handles objectAtIndex:indexPath.row];
    
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
