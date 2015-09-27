//
//  SettingsViewController.h
//  Turbine
//
//  Created by Tommy Brown on 9/27/15.
//  Copyright (c) 2015 tommista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
