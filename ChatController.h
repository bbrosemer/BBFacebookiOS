//
//  ChatController.h
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookChat.h"
#import "FacebookBBrosemer.h"


@interface ChatController : UIViewController <UITextViewDelegate,UITableViewDelegate> {
	IBOutlet UITableView *tbl;
	IBOutlet UITextField *field;
	IBOutlet UIToolbar *toolbar;
	FacebookChat *facebookChat;
	NSString *jid;
}
@property(nonatomic,retain)FacebookChat *facebookChat;
@property(nonatomic,retain)NSString *jid;
@property (nonatomic, retain) UITableView *tbl;
@property (nonatomic, retain) UITextField *field;
@property (nonatomic, retain) UIToolbar *toolbar;

-(void)setUpTable;
-(void)messageAdded;
-(IBAction)add;


@end
