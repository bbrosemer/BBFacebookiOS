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
#import "ImageItem.h"
#import "FacebookUser.h"


typedef enum {
    FacebookPhoto = 1,
    FacebookVideo = 2,
    FacebookStatus = 0,
    FacebookLink = 3,
    FacebookTypeAny = 4
} FacebookItemType;

typedef enum{
    FacebookItemSameData = 0,
    FacebookItemNewData = 1
} FacebookItemUpdated;


@protocol FacebookItemDelegate <NSObject>
@optional
-(void)facebookItemTreeUpdated;
@end


@interface FacebookItem : NSObject <ASICacheDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate> {
	int backgroundCount;
	int mainItem;
    FacebookItemUpdated updateType;
    FacebookItemType itemType;
	NSString *itemId;
	NSString *facebookItemLink;
    NSString *facebookItemFromID;
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
    
    
    
    ///NEW VALUES 
    NSDate *facebookDateItemCreateTime;
    NSDate *facebookDateItemUpdateTime;
    NSString *facebookItemToID;
    NSString *facebookItemSource;
    NSString *facebookItemAttribution;
    
    // NEED TO FIX //
   // NSString *facebookItemFromID;
    
    /////////////////////////////////
	int facebookItemLikes;
    int initHashValue;
	int globeUserCommentCounter;
	NSArray *facebookItemComments;
	id delegate;
	NSOperationQueue *queue;
    
    ImageItem *facebookImageItem;
    
}

@property (nonatomic, assign) id <FacebookItemDelegate> delegate;
@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *facebookItemLink;
@property (nonatomic, retain) NSString *facebookItemFromID;
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
@property (nonatomic, retain) ImageItem *facebookImageItem;


///NEW VALUES 
@property (nonatomic, retain)NSDate *facebookDateItemCreateTime;
@property (nonatomic, retain)NSDate *facebookDateItemUpdateTime;
@property (nonatomic, retain)NSString *facebookItemToID;
@property (nonatomic, retain)NSString *facebookItemSource;
@property (nonatomic, retain)NSString *facebookItemAttribution;



- (id)init;
- (id)initWithID:(NSString *)ID;
- (void)startFetchingBackgroundImages;
- (NSArray *)keyPaths;
- (void)startObservingObject:(id)thisObject;
- (void)stopObservingObject:(id)thisObject;
- (void)checkForComments;
-(void)setFacebookItemType:(FacebookItemType)type;
-(FacebookItemType)getFacebookItemType;
-(void)setFacebookItemUpdated:(FacebookItemUpdated)type;
-(FacebookItemUpdated)getFacebookItemUpdate;


-(void)getThisFacebookItem:(NSOperationQueue *)queue;
-(void)createFacebookItem:(NSOperationQueue *)queue andId:(NSString *)facebookId andGather:(BOOL)gather;

- (NSComparisonResult)compare:(FacebookItem *)otherObject;



@end
