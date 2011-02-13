//
//  FacebookWallPostController.m
//  FacebookStaticTest
//
//  Created by Brandyn on 12/24/10.
//  Copyright 2010 bbrosemer.com. All rights reserved.
//

#import "FacebookWallPostController.h"
#import "FacebookBBrosemer.h"
#import "FacebookFriends.h"
#import "FacebookUser.h"
#import <QuartzCore/QuartzCore.h>


@implementation FacebookWallPostController
@synthesize storyURL,imageURL,storyTitle;

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


 
 
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self roundEdges];
	copyListOfItems = [[NSMutableArray alloc] init];
	searchBarFriends.autocorrectionType = UITextAutocorrectionTypeNo;
}


- (void)roundEdges{
	tableViewFriends.layer.masksToBounds = YES;
	textViewMessage.layer.masksToBounds = YES;
	tableViewFriends.layer.cornerRadius = 10.0;
	textViewMessage.layer.cornerRadius = 10.0;
	imageViewUserMe.layer.masksToBounds = YES;
	imageViewUserMe.layer.cornerRadius = 10.0;
	imageViewUserTo.layer.masksToBounds = YES;
	imageViewUserTo.layer.cornerRadius = 10.0;
	
}

-(void)sendUpdate{
	[tableViewFriends reloadData];
	if(([FacebookBBrosemer getMeUser] != nil) &&(imageViewUserMe.image == nil)){
		imageViewUserTo.image = imageViewUserMe.image = [FacebookBBrosemer getUserImage];
	}
}

-(void)viewWillAppear:(BOOL)animated{
	[self roundEdges];
	searching = NO;
	//letUserSelectRow = YES;
	stringToID = [NSString stringWithFormat:@"me"];
	labelTo.text = stringToID;
	buttonFriendSelector.enabled = YES;
	[textViewMessage becomeFirstResponder];
	[tableViewFriends reloadData];
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if(([((NSArray *)[FacebookBBrosemer getUserFriends]) count] == nil) || ([((NSArray *)[FacebookBBrosemer getUserFriends]) count] == 0)){
		return 1;
	}
	return[((NSArray *)[FacebookBBrosemer getUserFriends]) count] +1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(([((NSArray *)[FacebookBBrosemer getUserFriends]) count] == nil) || ([((NSArray *)[FacebookBBrosemer getUserFriends]) count] == 0)){
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		
		 return cell;
	}
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if(indexPath.row == 0){
		cell.textLabel.text = @"Me";
		cell.imageView.image =  [FacebookBBrosemer getUserImage];
	}else{
	cell.textLabel.text = ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserName;
    cell.imageView.image =  ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserImage;
	}
		return cell;
}


// Section header & footer information. Views are preferred over title should you decide to provide both

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;   // custom view for footer. will be adjusted to default or specified footer height

// Accessories (disclosures). 

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_3_0);
//-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.row == 0){
		friendRow = 0;
		stringToID = @"me";
		labelTo.text = @"Me";
		imageViewUserTo.image = [FacebookBBrosemer getUserImage]; 
	}else{
		labelTo.text = ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserName;
		NSLog(@"TEST WORK> %@",((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserId);
		if(((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserImage != nil){
			imageViewUserTo.image = ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:indexPath.row-1]).facebookUserImage; 
		}
		friendRow = indexPath.row;
	}
	uiViewBackTable.frame = CGRectMake(0,0, 320, 460);
	[textViewMessage becomeFirstResponder];
	[self.view addSubview:uiViewBackTable];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDidStopSelector:@selector(friendTableGone)];
	uiViewBackTable.frame = CGRectMake(0,460, 320, 460);
	[UIView commitAnimations];
	[tableViewFriends deselectRowAtIndexPath:indexPath animated:NO];
	
}



-(IBAction)sendPushed{
	if(friendRow == 0){
		//NSLog(@"TEST STRING %@",stringToID);
		if(imageURL == nil){
			[FacebookBBrosemer userPostMessage:textViewMessage.text andTitle:storyTitle andLink:storyURL andTo:@"me"];
		}else{
			[FacebookBBrosemer userPostMessage:textViewMessage.text andTitle:storyTitle andLink:storyURL andPictureURL:imageURL andTo:@"me"];
		}
	}else{
		if(imageURL == nil){
			[FacebookBBrosemer userPostMessage:textViewMessage.text andTitle:storyTitle andLink:storyURL andTo:
			 ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:friendRow-1]).facebookUserId];
		}else{
			[FacebookBBrosemer userPostMessage:textViewMessage.text andTitle:storyTitle andLink:storyURL andPictureURL:imageURL andTo:
			 ((FacebookUser *)[((NSArray *)[FacebookBBrosemer getUserFriends]) objectAtIndex:friendRow-1]).facebookUserId];
		}
	}
	[self dismissModalViewControllerAnimated:YES];
}

-(void)friendTableGone{
	[uiViewBackTable removeFromSuperview];
}

-(IBAction)closeButtonPushed{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)chooseFriend{
		uiViewBackTable.frame = CGRectMake(0,460, 320, 460);
		[searchBarFriends becomeFirstResponder];
		[self.view addSubview:uiViewBackTable];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
		uiViewBackTable.frame = CGRectMake(0,0, 320, 460);
		[UIView commitAnimations];
		[textViewMessage resignFirstResponder];
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
