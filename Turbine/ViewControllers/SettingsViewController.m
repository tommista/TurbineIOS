//
//  SettingsViewController.m
//  Turbine
//
//  Created by Tommy Brown on 9/27/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import "SettingsViewController.h"
#import "DBManager.h"

#define FILTER_BY_SECTION 0
#define DUMP_SECTION 1

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cross"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    
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

- (IBAction) backButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int numRows = 0;
    switch(section){
        case FILTER_BY_SECTION:
            numRows = 4;
            break;
        case DUMP_SECTION:
            numRows = 1;
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
        case DUMP_SECTION:
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
        
    }else{
        cell.textLabel.text = @"Drop Tweets Database";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    bool shouldHighlight = NO;
    switch(indexPath.section){
        case FILTER_BY_SECTION:
            shouldHighlight = NO;
            break;
        case DUMP_SECTION:
            shouldHighlight = YES;
            break;
    }
    return shouldHighlight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch(indexPath.section){
        case FILTER_BY_SECTION:
            break;
        case DUMP_SECTION:
            [[DBManager getSharedInstance] dropTweetsTable];
            break;
    }
}

@end
