//
//  HandleListViewController.m
//  Turbine
//
//  Created by Tommy Brown on 7/26/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "HandleListViewController.h"
#import "DBManager.h"

@interface HandleListViewController (){
    DBManager *dbManager;
    NSMutableArray *handles;
}
@end

@implementation HandleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dbManager = [DBManager getSharedInstance];
    handles = [[dbManager getAllHandles] mutableCopy];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Actions

- (IBAction) addButtonPressed:(id)sender{
    
}

- (IBAction) backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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
    }
    
    cell.textLabel.text = [handles objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        bool deleteSuccessful = [dbManager deleteHandle:[handles objectAtIndex:indexPath.row]];
        if(deleteSuccessful){
            [handles removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"Error deleting handle: %@", [handles objectAtIndex:indexPath.row]);
        }
        
    }
}

@end
