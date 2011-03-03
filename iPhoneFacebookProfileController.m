//
//  iPhoneFacebookProfileController.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/22/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "iPhoneFacebookProfileController.h"
#import <QuartzCore/QuartzCore.h>


@implementation iPhoneFacebookProfileController
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize rowView;
@synthesize tableView;
@synthesize userNameLabel;
@synthesize userProfileImage;
@synthesize closeButton;
@synthesize userId;
@synthesize thisUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
}

- (void)roundEdges{
	//closeButton.layer.masksToBounds = YES;
	tableView.layer.masksToBounds = YES;
	//closeButton.layer.cornerRadius = 20.0;
    rowView.layer.cornerRadius = 10.0;
    rowView.layer.masksToBounds =YES;
    rowView.backgroundColor = [UIColor whiteColor];
	tableView.layer.cornerRadius = 10.0;
	userProfileImage.layer.masksToBounds = YES;
	userProfileImage.layer.cornerRadius = 10.0;	
}

-(IBAction)closeUser{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)largeProfilePic{
    UIImageView *tempView = [[UIImageView alloc] initWithImage:thisUser.facebookUserImageLarge];
    tempView.frame = CGRectMake(0, 0, 768, 1004);
    tempView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:tempView];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self release];
    self = nil;
}

#pragma mark - View lifecycle

-(void)updateTableView{
    [self.tableView beginUpdates];
    //[self.tableView insertRowsAtIndexPaths:<#(NSArray *)#> withRowAnimation:<#(UITableViewRowAnimation)#>
    [self.tableView endUpdates];
}


-(void)updateView{
    [self.tableView reloadData];
    self.label1.text = thisUser.facebookUserBirthday;
    self.label2.text = thisUser.facebookUserRelationshipStatus;
    self.label3.text = thisUser.facebookUserEmail;
    self.userNameLabel.adjustsFontSizeToFitWidth = YES;
    self.userNameLabel.text = thisUser.facebookUserName;
    self.userProfileImage.image = thisUser.facebookUserImageLarge;
    
     if(self.thisUser.facebookUserPhotosTaggedIn){
     self.rowView.contentSize = CGSizeMake(((79*([self.thisUser.facebookUserPhotosTaggedIn count]+1))/2)+4, 158);
     self.rowView.tempHandler = self.thisUser.facebookUserPhotosTaggedIn;
     [self.rowView setImages:0];
     self.rowView.opaque = YES;
     self.rowView.layer.shouldRasterize = YES;
     }   
}

-(void)facebookItemHandlerUpdated{
    [self updateView];
}

-(void)userWallLoaded{
    // Do some UIView animations to expand the table view to the appropriate height if the facebook wall photos are not loaded...
    // This also causes the UIViewImage Of the Profile to shrink ...
    
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [[FacebookItemHandler sharedInstance] setDelegate:self];
    [self.tableView reloadData];
    self.label1.text = thisUser.facebookUserBirthday;
    self.label2.text = thisUser.facebookUserRelationshipStatus;
    self.label3.text = thisUser.facebookUserEmail;
    self.userNameLabel.adjustsFontSizeToFitWidth = YES;
    self.userNameLabel.text = thisUser.facebookUserName;
    self.userProfileImage.image = thisUser.facebookUserImageLarge;
    
    if(self.thisUser.facebookUserPhotosTaggedIn){
      //  [selfc.rowView removeFromSuperview];
       // self.rowView = nil;
       // self.rowView = [[FilmRowScrollView alloc] init];
       // self.rowView.frame = CGRectMake(0, 105, 320, 158);
       // [self.view addSubview:self.rowView];
       // self.rowView.contentSize = CGSizeMake(((79*([self.thisUser.facebookUserPhotosTaggedIn count]+1))/2)+4, 158);
       // self.rowView.tempHandler = self.thisUser.facebookUserPhotosTaggedIn;
       // [self.rowView setImages:0];
       // self.rowView.opaque = YES;
       // self.rowView.layer.shouldRasterize = YES;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self roundEdges];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
  //  NSLog(@"COUNT %i",[thisUser.facebookUserWall count]);
    return [thisUser.facebookUserWall count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
		                               reuseIdentifier:nil] autorelease];
	}
    // Set up the cell...
    // if(cell.rowView == nil){
    cell.textLabel.text = ((FacebookItem *)[thisUser.facebookUserWall getFacebookItemFromItemObjects:
                                            [thisUser.facebookUserWall objectAtIndex:indexPath.row]]).facebookItemMessage;
   
	//}
    return cell;
}


@end