/*
 Copyright (c) 2010, Brandyn Brosemer ,bbrosemer.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "FacebookStaticTestViewController.h"
#import "FacebookHashTableNavigationController.h"
#import "RootViewController.h"
#import "ImageHandler.h"
#import "FacebookBBrosemer.h"
#import "FilmImageTableViewController.h"
#import "FacebookItemHandler.h"
@implementation FacebookStaticTestViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


-(IBAction)loginPushed{
	[FacebookBBrosemer login];
}

-(IBAction)helloWord{
	//[FacebookItemHandler createUser:@"me"];   
    //[FacebookItemHandler userPostMessage:@"Testing..." andTitle:@"Hello World" andLink:@"bbrosemer.com" andTo:@"me"];
   // [FacebookItemHandler getFacebookUserMe];
}


-(IBAction)presentHashTableNavController{
	[FacebookBBrosemer presentFacebookTableModal:YES andCurrentViewController:self];
}

-(IBAction)getFriends{
	[FacebookItemHandler getMeFriends];
}

-(IBAction)pushChat{
	//[FacebookBBrosemer presentFacebookChatController:YES andCurrentViewController:self];
    [FacebookBBrosemer presentFacebookUserProfileModal:YES andUserId:@"1437950535" andCurrentViewController:self];
    //[FacebookBBrosemer presentFacebookUserProfileModal:YES andUserId:@"me" andCurrentViewController:self];

}

-(IBAction)displayMessageController{
	//[FacebookBBrosemer presentFacebookMessageControllerModal:YES andCurrentViewController:self];
	[FacebookBBrosemer presentFacebookMessageControllerModal:YES withTitle:@"Check this Out" 
													withLink:@"http://www.nytimes.com/2010/12/19/us/politics/19cong.html?_r=1&hp"
									andCurrentViewController:self];
}

-(IBAction)pushGatherImages{
    filmImage = [[FilmImageTableViewController alloc]init];
    filmImage.tempHandle = [[ImageHandler alloc] init];
    [filmImage.tempHandle loadImagesOfMeFromFacebook];
}

-(IBAction)presentFilmTable{
    //filmImage.tempHandler = imageHandle;
    [self presentModalViewController:filmImage animated:YES];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
