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

#import <UIKit/UIKit.h>
#import "FacebookItem.h"

@interface FacebookItemViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate> {
	FacebookItem *facebookItem;
	IBOutlet UITableView	*tableView;
	IBOutlet UIImageView	*userPictureView;
	IBOutlet UIImageView	*userPictureView2;
	IBOutlet UIImageView	*articleImageView;
	IBOutlet UITextView		*articleTextView;
	IBOutlet UILabel		*articleTitleView;
	IBOutlet UIView			*commentView;
	IBOutlet UIView			*tableBottomView;
	IBOutlet UITextView		*commentTextView;
	IBOutlet UITextField	*commentTextField;
	BOOL commentViewOpen;
}

-(IBAction)backPressed;
-(IBAction)refreshPressed;
-(IBAction)commentPushed;
-(IBAction)closeCommentView;

@property (nonatomic, retain) FacebookItem *facebookItem;

- (id)init;
-(void)updateView;
- (NSArray *)keyPaths;
- (void)startObservingObject:(id)thisObject;
- (void)stopObservingObject:(id)thisObject;
-(void)sendUpdate;
-(void)commentPushedVoid;





@end
