//
//  ChatController.m
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//
#import "DDXML.h"

#import "ChatController.h"
#import "FacebookChat.h"
#import "FacebookBBrosemer.h"
#import "XMPP.h"
#import "UIColor-Expanded.h"

#define FONT_SIZE 15.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 30.0f



@implementation ChatController
@synthesize tbl, field, toolbar;

@synthesize facebookChat,jid;


- (XMPPStream *)xmppStream
{
	return [FacebookBBrosemer xmppStream];
}

- (XMPPRoster *)xmppRoster
{
	return [FacebookBBrosemer xmppRoster];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void)setUpTable{
	self.navigationItem.title = facebookChat.fromUser;
	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	//messageText.keyboardAppearance = UIKeyboardAppearanceAlert;
	[tbl reloadData];
}

-(void)messageAdded{
	[tbl reloadData];
	NSUInteger index = [facebookChat.facebookChatArray count] - 1;
	[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}


-(void)sendUpdate{
	NSLog(@"Updating the chat");
	[tbl reloadData];
	NSUInteger index = [facebookChat.facebookChatArray count] - 1;
	[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}






/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)add{
	NSString *messageStr = field.text;
	
	if([messageStr length] > 0)
	{
		DDXMLElement *body = [DDXMLElement elementWithName:@"body"];
		[body setStringValue:messageStr];
		
		DDXMLElement *message = [DDXMLElement elementWithName:@"message"];
		[message addAttribute:[DDXMLNode attributeWithName:@"type" stringValue:@"chat"]];
		[message addAttribute:[DDXMLNode attributeWithName:@"to" stringValue:jid]];
		[message addChild:body];
		[facebookChat addSentMessage:messageStr];
		[[FacebookBBrosemer xmppStream] sendElement:message];
		[tbl reloadData];

		NSUInteger index = [facebookChat.facebookChatArray count] - 1;
		[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		field.text = @"";
	}
}
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = facebookChat.fromUser;
	
	/*
	 The conversation
	 */
    
	
	/*
	 Set the background color
	 */
	tbl.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
	toolbar.tintColor = [UIColor colorWithHexString:@"3B5998"];
	//tbl.backgroundColor = [UIColor colorWithHexString:@"3B5998"];
	/*
	 Create header with two buttons
	 */
	self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHexString:@"3B5998"];
	CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 55)];
	
	UIButton *callButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[callButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];		
	callButton.frame = CGRectMake(10, 10, (screenSize.width / 2) - 10, 35);
	[callButton setTitle:@"Call" forState:UIControlStateNormal];
	
	UIButton *contactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[contactButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];		
	contactButton.frame = CGRectMake((screenSize.width / 2) + 10, 10, (screenSize.width / 2) - 20, 35);
	[contactButton setTitle:@"Contact Info" forState:UIControlStateNormal];
	
	[headerView addSubview:callButton];
	[headerView addSubview:contactButton];
	
	tbl.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification object:self.view.window]; 
}

- (void)viewWillDisappear:(BOOL)animated {
	self.facebookChat = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	toolbar.frame = CGRectMake(0, 372, 320, 44);
	tbl.frame = CGRectMake(0, 0, 320, 372);	
	[UIView commitAnimations];
	
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notif {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];	
	toolbar.frame = CGRectMake(0, 156, 320, 44);
	tbl.frame = CGRectMake(0, 0, 320, 156);	
	[UIView commitAnimations];
	[tbl reloadData];
	if([facebookChat.facebookChatArray count] > 0)
	{
		NSUInteger index = [facebookChat.facebookChatArray count] - 1;
		[tbl scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [facebookChat.facebookChatArray count];
}

#pragma mark -
#pragma mark Table view methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	UIImageView *balloonView;
	UILabel *label;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;		
		
		balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
		balloonView.tag = 1;
		
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.tag = 2;
		label.numberOfLines = 0;
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.font = [UIFont systemFontOfSize:14.0];
		
		UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		message.tag = 0;
		[message addSubview:balloonView];
		[message addSubview:label];
		[cell.contentView addSubview:message];
		
		[balloonView release];
		[label release];
		[message release];
	}
	else
	{
		balloonView = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		label = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
	}
	
	NSString *text = [facebookChat.facebookChatArray objectAtIndex:indexPath.row];
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];
	
	UIImage *balloon;
	
	if(![[facebookChat.toFromArray objectAtIndex:indexPath.row] isEqualToString:@"me"])
	{
		balloonView.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
		balloon = [[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
	}
	else
	{
		balloonView.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);
		balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
		label.frame = CGRectMake(16, 8, size.width + 5, size.height);
	}
	
	balloonView.image = balloon;
	label.text = text;
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *body = [facebookChat.facebookChatArray objectAtIndex:indexPath.row];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
	return size.height + 15;
}

#pragma mark -



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
