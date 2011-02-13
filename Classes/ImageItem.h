//
//  ImageItem.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/12/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ImageItem : NSObject {
	//Gather In the background
	UIImage *imageItemThumb;
	UIImage *imageItemNormal;
	UIImage *imageItemLarge;
	/////////////////////////////////
	
	
	NSString *imageItemCreator;
	NSString *imageItemCreationDate;
	NSString *imageItemTitle;
	NSURL *imageItemThumbURL;
	NSURL *imageItemNormalURL;
	NSURL *imageItemLargeURL;
	NSString *imageItemPostID;
	NSArray *imageItemTags;
}
@property(nonatomic,retain)UIImage *imageItemThumb;
@property(nonatomic,retain)UIImage *imageItemNormal;
@property(nonatomic,retain)UIImage *imageItemLarge;
@property(nonatomic,retain)NSString *imageItemCreator;
@property(nonatomic,retain)NSString *imageItemCreationDate;
@property(nonatomic,retain)NSString *imageItemTitle;
@property(nonatomic,retain)NSURL *imageItemThumbURL;
@property(nonatomic,retain)NSURL *imageItemNormalURL;
@property(nonatomic,retain)NSURL *imageItemLargeURL;
@property(nonatomic,retain)NSString *imageItemPostID;
@property(nonatomic,retain)NSArray *imageItemTags;

-(id)initWithThumb:(NSURL *)imageItemThumbURL;
-(id)initWithNormal:(NSURL *)imageItemNormalURL;
-(id)initWithLarge:(NSURL *)imageItemLargeURL;
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL;
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL andLarge:(NSURL *)imageItemLargeURL;
-(void)mainAttributes:(NSString *)creator andCreationDate:(NSString *)imageItemCreationDate andTitle:(NSString *)title;

-(void)fetchThumbImage:
-(void)fetchNormalImage;
-(void)fetchLargeImage;
-(void)


@end
