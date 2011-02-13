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

#import <Foundation/Foundation.h>
#import "FacebookUser.h"
#import "FacebookActions.h"

@protocol FacebookItemDelegate <NSObject>
@optional
-(void)facebookItemTreeUpdated;
@end


@interface FacebookItem : NSObject <FacebookUserDelegate,ASICacheDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate> {
	int backgroundCount;
	int mainItem;
	NSString *itemId;
	NSString *facebookItemLink;
	FacebookUser *facebookItemFrom;
	NSString *facebookItemMessage;
	NSString *facebookItemImageURL;
	UIImage *facebookItemImage;
	NSString *facebookItemName;
	NSString *facebookItemCaption;
	NSString *facebookItemDescription;
	NSString *facebookItemIconURL;
	UIImage *facebookItemIcon;
	FacebookActions *facebookItemActions;
	NSString *facebookItemCreateTime;
	NSString *facebookItemUpdatedTime;
	int facebookItemLikes;
	int initHashValue;
	int globeUserCommentCounter;
	NSArray *facebookItemComments;
	id delegate;
	NSOperationQueue *queue;
}

@property (nonatomic, assign) id <FacebookItemDelegate> delegate;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *facebookItemLink;
@property (nonatomic, retain) FacebookUser *facebookItemFrom;
@property (nonatomic, retain) NSString *facebookItemMessage;
@property (nonatomic, retain) NSString *facebookItemImageURL;
@property (nonatomic, retain) UIImage *facebookItemImage;
@property (nonatomic, retain) NSString *facebookItemName;
@property (nonatomic, retain) NSString *facebookItemCaption;
@property (nonatomic, retain) NSString *facebookItemDescription;
@property (nonatomic, retain) NSString *facebookItemIconURL;
@property (nonatomic, retain) UIImage *facebookItemIcon;
@property (nonatomic, retain) FacebookActions *facebookItemActions;
@property (nonatomic, retain) NSString *facebookItemCreateTime;
@property (nonatomic, retain) NSString *facebookItemUpdatedTime;
@property (nonatomic, assign) int facebookItemLikes;
@property (nonatomic, assign) int initHashValue;
@property (nonatomic, retain) NSArray *facebookItemComments;
@property (nonatomic, retain) NSOperationQueue *queue;
- (id)init;
- (id)initWithID:(NSString *)ID;
- (void)startFetchingBackgroundImages;
- (NSArray *)keyPaths;
- (void)startObservingObject:(id)thisObject;
- (void)stopObservingObject:(id)thisObject;
- (void)checkForComments;





@end
