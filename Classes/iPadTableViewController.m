//
//  iPadTableViewController.m
//  FacebookStaticTest
//
//  Created by Brandyn on 1/20/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "iPadTableViewController.h"
#import "FacebookTableViewCell.h"
#import "FacebookBBrosemer.h"
#import "FacebookItem.h"
#import "FacebookUser.h"
#import <QuartzCore/QuartzCore.h>


@implementation iPadTableViewController
@synthesize facebookItemView;

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	facebookItemView.facebookItem =((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row]));
	[facebookItemView updateView];
}


-(IBAction)closeViewPushed{
	[self dismissModalViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
	[tableView reloadData];
	[self updateAll];
}

-(void)viewDidAppear:(BOOL)animated{
	if([[FacebookBBrosemer getNewestFirstArray] count] > 0){
	NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
	[tableView selectRowAtIndexPath:ip animated:NO scrollPosition:UITableViewScrollPositionBottom];
	facebookItemView.facebookItem =((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:ip.row]));
	}
		[facebookItemView updateView];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

-(void)sendUpdate{
	[tableView reloadData];
	[facebookItemView sendUpdate];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [[FacebookBBrosemer getNewestFirstArray] count];
}



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
//	if(((FacebookUser *)((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] objectAtIndex:indexPath.row])).facebookItemFrom).facebookUserImage!=nil){
//		cell.cellImageViewUser.image = ((FacebookUser *)((FacebookItem *)([(NSMutableArray *)[FacebookBBrosemer getNewestFirstArray] 
//																		   objectAtIndex:indexPath.row])).facebookItemFrom).facebookUserImage;
//	}
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

