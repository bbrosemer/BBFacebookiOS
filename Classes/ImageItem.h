//
//  ImageItem.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/12/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@protocol FacebookItemDelegate <NSObject>
@optional
-(void)imageItemClicked;
@end


//#import "FacebookItemHandler.h"


@interface ImageItem : NSObject <ASICacheDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate,NSCoding>{
	//Gather In the background
	UIImage *imageItemThumb;
	UIImage *imageItemNormal;
	UIImage *imageItemLarge;
	/////////////////////////////////
    
    UIImageView *imageViewThumb;
    UIButton  *imageItemButton;
	
	NSString *imageItemCreator;
	NSString *imageItemCreationDate;
	NSString *imageItemTitle;
	NSString *imageItemThumbURL;
	NSString *imageItemNormalURL;
	NSString *imageItemLargeURL;
	NSString *imageItemPostID;
	NSArray *imageItemTags;
    NSOperationQueue *queue;
    id delegate;
}
@property(nonatomic,retain)UIImageView *imageViewThumb;
@property(nonatomic,retain)UIImage *imageItemThumb;
@property(nonatomic,retain)UIImage *imageItemNormal;
@property(nonatomic,retain)UIImage *imageItemLarge;
@property(nonatomic,retain)NSString *imageItemCreator;
@property(nonatomic,retain)NSString *imageItemCreationDate;
@property(nonatomic,retain)NSString *imageItemTitle;
@property(nonatomic,retain)NSString *imageItemThumbURL;
@property(nonatomic,retain)NSString *imageItemNormalURL;
@property(nonatomic,retain)NSString *imageItemLargeURL;
@property(nonatomic,retain)NSString *imageItemPostID;
@property(nonatomic,retain)NSArray *imageItemTags;
@property (nonatomic, retain) NSOperationQueue *queue;
//@property(nonatomic,retain)id <ImageItem> delegate;

-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(id)initWithThumb:(NSString *)imageItemThumbURL;
-(id)initWithNormal:(NSURL *)imageItemNormalURL;
-(id)initWithLarge:(NSURL *)imageItemLargeURL;
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL;
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL andLarge:(NSURL *)imageItemLargeURL;
-(void)mainAttributes:(NSString *)creator andCreationDate:(NSString *)imageItemCreationDate andTitle:(NSString *)title;
-(void)setImageTags:(NSArray *)tags;
-(void)fetchThumbImage;
-(void)fetchNormalImage;
-(void)fetchLargeImage;
-(void)fetchAllImages;
-(void)stopRequest;

-(BOOL)isLoadingThumb;
-(BOOL)isLoadingNormal;
-(BOOL)isLoadingLarge;

@end
