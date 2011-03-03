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

#import "FacebookItemTableViewCell.h"
#import "FacebookItemViewController.h"
#import "FacebookBBrosemer.h"
#import <QuartzCore/QuartzCore.h>

@implementation FacebookItemViewController
@synthesize facebookItem;
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

- (void)roundEdges{
	tableView.layer.masksToBounds = YES;
	articleTextView.layer.masksToBounds = YES;
	tableView.layer.cornerRadius = 10.0;
	articleTextView.layer.cornerRadius = 10.0;
	userPictureView.layer.masksToBounds = YES;
	userPictureView2.layer.masksToBounds = YES;
	articleImageView.layer.masksToBounds = YES;
	articleImageView.layer.cornerRadius = 10.0;
	userPictureView.layer.cornerRadius = 10.0;
	userPictureView2.layer.cornerRadius = 10.0;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self roundEdges];
	tableBottomView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	tableBottomView.autoresizesSubviews = YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)||(interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	}else{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

-(void)moveViewUp{
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y = -128;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.10];
	self.view.frame = viewFrame;
	[UIView commitAnimations];
}

-(void)moveCommentViewOff{
	CGRect viewFrame = commentView.frame;
	viewFrame.origin.y = 460;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.10];
	self.view.frame = viewFrame;
	[UIView commitAnimations];
}

-(void)moveCommentViewOn{
	CGRect viewFrame = commentView.frame;
	CGRect tableFrame = tableBottomView.frame;
	viewFrame.origin.y = 460-commentView.frame.size.height;
	tableFrame.origin.y = 140 - commentView.frame.size.height;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	commentView.frame = viewFrame;
	tableBottomView.frame = tableFrame;
	[UIView commitAnimations];
}

-(void)moveKeyboardOn{
	CGRect viewFrame = commentView.frame;
	CGRect tableFrame = tableBottomView.frame;
	viewFrame.origin.y = 460-commentView.frame.size.height-210;
	tableFrame.size.height = tableFrame.size.height - 140;
	tableFrame.origin.y = 0;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	commentView.frame = viewFrame;
	tableBottomView.frame = tableFrame;
	[UIView commitAnimations];
}

-(void)moveKeyboardOff{
	CGRect viewFrame = commentView.frame;
	CGRect tableFrame = tableBottomView.frame;
	viewFrame.origin.y = 460;
	tableFrame.size.height = 360;
	tableFrame.origin.y = 140;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	commentView.frame = viewFrame;
	tableBottomView.frame = tableFrame;
	[UIView commitAnimations];
	commentViewOpen = NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
		[self moveKeyboardOff];
		[textView resignFirstResponder];
		[FacebookBBrosemer userPostComment:[NSString stringWithString:commentTextView.text] 
						   andFacebookItem:self.facebookItem];
		[self.facebookItem checkForComments];
		commentTextView.text = [NSString stringWithFormat:@"What do you have to say?"];
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

-(BOOL)textViewDidBeginEditing:(UITextView *)textView{
	[self moveKeyboardOn];
	return YES;
}


-(void)sendUpdate{
	NSLog(@"TREE UPDATE");
	[tableView reloadData];
}
	 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [self.facebookItem.facebookItemComments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"CellUID";
	
    FacebookItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"FacebookItemTableViewCell" owner:nil options:nil];
		for(id currentObject in nibObjects){
			if([currentObject isKindOfClass:[FacebookItemTableViewCell class]]){
				cell = (FacebookItemTableViewCell *)currentObject;
			}
		}
    }
    // Set up the cell...
    /*
	cell.textViewCommentUserComment.text=((FacebookItem *)[self.facebookItem.facebookItemComments objectAtIndex:indexPath.row]).facebookItemMessage;
	cell.imageViewFacebookItem.image=((FacebookUser *)((FacebookItem *)[self.facebookItem.facebookItemComments 
																			objectAtIndex:indexPath.row]).facebookItemFrom).facebookUserImage;
	*/
    return cell;
}

-(IBAction)backPressed{
	[self.navigationController popViewControllerAnimated:YES];
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
	}else{
		[self moveViewUp];
	}
}

-(IBAction)refreshPressed{
	[self.facebookItem checkForComments];
}

-(IBAction)closeCommentView{
	commentTextView.text = [NSString stringWithFormat:@"What do you have to say?"];
	commentTextField.placeholder = [NSString stringWithFormat:@"What do you have to say?"];
 	[commentTextView resignFirstResponder];
	[self moveKeyboardOff];
}

-(void)viewWillAppear:(BOOL)animated{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[commentTextField becomeFirstResponder];
		commentTextField.placeholder = [NSString stringWithFormat:@"What do you have to say"];
		[self roundEdges];
	}
	CGRect commentFrame = commentView.frame;
	commentFrame.origin.y = 460;
	commentView.frame = commentFrame;
	CGRect tableFrame = tableBottomView.frame;
	tableFrame.origin.y = 140;
	tableBottomView.frame = tableFrame;
	
	
	commentTextView.text = [NSString stringWithFormat:@"What do you have to say?"];
	commentViewOpen = NO;
	//userPictureView2.image = userPictureView.image = self.facebookItem.facebookItemFrom.facebookUserImage;
	articleImageView.image = self.facebookItem.facebookItemImage;
	articleTitleView.text = self.facebookItem.facebookItemName;
	articleTextView.text = self.facebookItem.facebookItemDescription;
	[self.facebookItem checkForComments];

	[tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

-(IBAction)commentPushed{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[FacebookBBrosemer userPostComment:[NSString stringWithString:commentTextField.text] 
						   andFacebookItem:self.facebookItem];
		[self.facebookItem checkForComments];
		commentTextField.text = [NSString stringWithFormat:@"What do you have to say?"];
		return;
	}
	
	if (commentViewOpen==NO){
		NSLog(@"??");
		[self moveCommentViewOn];
		commentViewOpen = YES;
			//MOVE COMMENT VIEW ONSCREEN
	}else{

	}
	
}

-(void)updateView{
	[self viewWillAppear:YES];
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
