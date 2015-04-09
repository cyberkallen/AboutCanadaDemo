//
//  RootViewController.h
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController

// the main data model for our UITableView
@property (nonatomic, retain) NSString *navTitleStr;
@property (nonatomic, retain) NSArray *entries;

@end
