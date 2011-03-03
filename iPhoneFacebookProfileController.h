//
//  iPhoneFacebookProfileController.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/22/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookUser.h"
#import "FilmRowScrollView.h"
#import "FacebookItemHandler.h"
#import "FacebookUser.h"


@interface iPhoneFacebookProfileController : UIViewController <FacebookItemHandlerDelegate,UITableViewDataSource,UITableViewDelegate> {
    NSString *userId;
    FacebookUser *thisUser;
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    IBOutlet UILabel *label3;
    IBOutlet UILabel *userNameLabel;
    IBOutlet FilmRowScrollView *rowView;
    IBOutlet UIImageView *userProfileImage;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *closeButton;
}
-(IBAction)closeUser;
@property(nonatomic,retain)IBOutlet UIButton *closeButton;
@property(nonatomic,retain)IBOutlet UILabel *label1;
@property(nonatomic,retain)IBOutlet UILabel *label2;
@property(nonatomic,retain)IBOutlet UILabel *label3;
@property(nonatomic,retain)IBOutlet UILabel *userNameLabel;
@property(nonatomic,retain)IBOutlet FilmRowScrollView *rowView;
@property(nonatomic,retain)IBOutlet UIImageView *userProfileImage;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)FacebookUser *thisUser;
-(IBAction)largeProfilePic;

@end
