//
//  iPadFacebookProfileController.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/19/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "iPadFacebookProfileController.h"
#import <QuartzCore/QuartzCore.h>


@implementation iPadFacebookProfileController
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

- (void)dealloc
{
    [super dealloc];
}

- (void)roundEdges{
	//closeButton.layer.masksToBounds = YES;
	tableView.layer.masksToBounds = YES;
	//closeButton.layer.cornerRadius = 20.0;
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

#pragma mark - View lifecycle

-(void)facebookItemHandlerUpdated{
    //NSLog(@"HMM");
    [self viewWillAppear:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [[FacebookItemHandler sharedInstance] setDelegate:self];
    self.label1.text = thisUser.facebookUserBirthday;
    self.label2.text = thisUser.facebookUserRelationshipStatus;
    self.label3.text = thisUser.facebookUserEmail;
    self.userNameLabel.adjustsFontSizeToFitWidth = YES;
    self.userNameLabel.text = thisUser.facebookUserName;
    self.userProfileImage.image = thisUser.facebookUserImageLarge;
    if(self.thisUser.facebookUserPhotosTaggedIn){
        [self.rowView removeFromSuperview];
        self.rowView = nil;
        rowView = [[FilmRowScrollView alloc] init];
        rowView.frame = CGRectMake(215, 127, 320, 158);
        [self.view addSubview:self.rowView];
        self.rowView.contentSize = CGSizeMake(((79*[self.thisUser.facebookUserPhotosTaggedIn count])/2)+4, 158);
        self.rowView.tempHandler = self.thisUser.facebookUserPhotosTaggedIn;
        [self.rowView setImages:0];
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

@end
