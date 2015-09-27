//
//  SettingsViewController.m
//  Turbine
//
//  Created by Tommy Brown on 9/27/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "SettingsViewController.h"

#define FILTER_BY_SECTION 0

#define FILTER_SPOTIFY_ROW 0
#define FILTER_SOUNDCLOUD_ROW 1
#define FILTER_ITUNES_ROW 2
#define FILTER_YOUTUBE_ROW 3

@interface SettingsViewController (){
    NSUserDefaults *userDefaults;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

#pragma mark - Actions

- (void) switchChanged:(UISwitch *)switchState{
    switch(switchState.tag){
        case FILTER_SPOTIFY_ROW:
            [userDefaults setBool:switchState.isOn forKey:FILTER_BY_SPOTIFY_KEY];
            break;
        case FILTER_SOUNDCLOUD_ROW:
            [userDefaults setBool:switchState.isOn forKey:FILTER_BY_SOUNDCLOUD_KEY];
            break;
        case FILTER_ITUNES_ROW:
            [userDefaults setBool:switchState.isOn forKey:FILTER_BY_ITUNES_KEY];
            break;
        case FILTER_YOUTUBE_ROW:
            [userDefaults setBool:switchState.isOn forKey:FILTER_BY_YOUTUBE_KEY];
            break;
    }
    [userDefaults synchronize];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numRows = 0;
    switch(section){
        case FILTER_BY_SECTION:
            numRows = 4;
            break;
    }
    return numRows;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    switch(section){
        case FILTER_BY_SECTION:
            title = @"Filter For";
            break;
    }
    return title;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettingsIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont fontWithName:@"PT Sans" size:18.0];
    }
    
    if(indexPath.section == FILTER_BY_SECTION){
        NSString *title = @"";
        BOOL switchState = 1;
        
        switch(indexPath.row){
            case FILTER_SPOTIFY_ROW:
                title = @"Spotify";
                switchState = [userDefaults boolForKey:FILTER_BY_SPOTIFY_KEY];
                break;
            case FILTER_SOUNDCLOUD_ROW:
                title = @"Soundcloud";
                switchState = [userDefaults boolForKey:FILTER_BY_SOUNDCLOUD_KEY];
                break;
            case FILTER_ITUNES_ROW:
                title = @"iTunes";
                switchState = [userDefaults boolForKey:FILTER_BY_ITUNES_KEY];
                break;
            case FILTER_YOUTUBE_ROW:
                title = @"Youtube";
                switchState = [userDefaults boolForKey:FILTER_BY_YOUTUBE_KEY];
                break;
        }
        
        cell.textLabel.text = title;
        
        UISwitch *cellSwitch = [[UISwitch alloc] init];
        [cellSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        [cellSwitch setOn:switchState];
        cellSwitch.tag = indexPath.row;
        cell.accessoryView = cellSwitch;
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

@end
