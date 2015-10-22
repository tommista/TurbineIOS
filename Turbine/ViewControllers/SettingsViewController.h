//
//  SettingsViewController.h
//  Turbine
//
//  Created by Tommy Brown on 9/27/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FILTER_BY_SPOTIFY_KEY @"filter_by_spotify"
#define FILTER_BY_SOUNDCLOUD_KEY @"filter_by_soundcloud"
#define FILTER_BY_ITUNES_KEY @"filter_by_itunes"
#define FILTER_BY_YOUTUBE_KEY @"filter_by_youtube"
#define FILTER_BY_OTHER_KEY @"filter_by_other"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
