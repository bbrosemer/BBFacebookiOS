//
//  FacebookWallPostController.h
//  FacebookStaticTest
//
//  Created by Brandyn on 12/24/10.
//  Copyright 2010 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FacebookWallPostController : UIViewController <UISearchBarDelegate,UITableViewDelegate> {
	IBOutlet UITableView *tableViewFriends;
	IBOutlet UISearchBar *searchBarFriends;
	IBOutlet UIButton *buttonFriendSelector;
	IBOutlet UIButton *closeButton;
	IBOutlet UITextView *textViewMessage;
	IBOutlet UIButton *sendButton;
	IBOutlet UIView *uiViewBackTable;
	IBOutlet UIImageView *imageViewUserMe;
	IBOutlet UILabel *labelTo;
	IBOutlet UIImageView *imageViewUserTo;
	NSString *stringToID;
	int friendRow;
	
	NSString *storyTitle;
	NSString *imageURL;
	NSString *storyURL;
	
	
	NSMutableArray *copyListOfItems;
	BOOL searching;
	BOOL letUserSelectRow;
	
}

-(IBAction)closeButtonPushed;
-(IBAction)sendPushed;
-(IBAction)chooseFriend;
-(void)sendUpdate;

- (void) searchTableView;
- (void) doneSearching_Clicked:(id)sender;



@property(nonatomic,retain)NSString *storyURL, *imageURL, *storyTitle;

@end
