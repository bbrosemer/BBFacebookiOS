//
//  iPadTableViewController.h
//  FacebookStaticTest
//
//  Created by Brandyn on 1/20/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookBBrosemer.h"
#import "FacebookItemViewController.h"

@class FacebookItemViewController;

@interface iPadTableViewController : UIViewController <FacebookDelegate,UISplitViewControllerDelegate,UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView *tableView;
	IBOutlet FacebookItemViewController *facebookItemView;
	
}
@property(nonatomic,retain)	IBOutlet FacebookItemViewController *facebookItemView;
-(IBAction)closeViewPushed;
-(void)updateAll;
-(void)sendUpdate;


@end
