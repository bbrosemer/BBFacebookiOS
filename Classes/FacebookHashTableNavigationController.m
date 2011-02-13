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

#import "FacebookHashTableNavigationController.h"
#import "FacebookTableViewCell.h"
#import "FacebookBBrosemer.h"
#import "FacebookItem.h"
#import "FacebookUser.h"
#import <QuartzCore/QuartzCore.h>


@implementation FacebookHashTableNavigationController

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
}


- (void)roundEdges{
	tableView.layer.masksToBounds = YES;
	tableView.layer.cornerRadius = 10.0;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

-(void)viewWillAppear:(BOOL)animated{
	[tableView reloadData];
	[self updateAll];
}

-(IBAction)closeViewPushed{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)sendUpdate{
	[tableView reloadData];
	[facebookItemView sendUpdate];
}

-(void)moveViewDown{
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y = 128;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.10];
	self.view.frame = viewFrame;
	[UIView commitAnimations];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[FacebookBBrosemer getNewestFirstArray] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    FacebookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"FacebookTableCell" owner:nil options:nil];
		for(id currentObject in nibObjects){
			if([currentObject isKindOfClass:[FacebookTableViewCell class]]){
				cell = (FacebookTableViewCell *)currentObject;
			}
		}
    }
	
    // Set up the cell...
	cell.cellTitle.text=((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemName;
	cell.cellDescription.text=((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemDescription;
	if((((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemImage)!=nil){
		cell.cellImageView.image = ((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemImage;
	}
	if(((FacebookUser *)((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemFrom).facebookUserImage!=nil){
		cell.cellImageViewUser.image = ((FacebookUser *)((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] 
																		   objectAtIndex:indexPath.row])).facebookItemFrom).facebookUserImage;
	}
	cell.cellLikeCount.text = [NSString stringWithFormat:@"%i",((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] 
																		   objectAtIndex:indexPath.row])).facebookItemLikes];
	cell.cellCommentCount.text = [NSString stringWithFormat:@"%i",[((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] 
																				  objectAtIndex:indexPath.row])).facebookItemComments count]];
    return cell;
}


-(void)updateAll{
	NSLog(@"UPDATING ALL");
	for(int i = 0; i < [((NSMutableArray *)[FacebookBBrosemer getNewestFirstArray]) count] ; i++){
		[((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:i])) checkForComments];
	}
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
	if(facebookItemView == nil){
		facebookItemView = [[FacebookItemViewController alloc] init];
	}
	facebookItemView.facebookItem =((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row]));
	[self.navigationController pushViewController:facebookItemView animated:YES];
	[self moveViewDown];
}
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);





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
