//
//  ImageHandler.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/12/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookItem.h"

@interface ImageHandler : NSObject {
	NSMutableArray *imagesByID;
    NSMutableArray *imagesByDateWithIDS;
}
@property(nonatomic,retain)NSMutableArray *imagesByID;
@property(nonatomic,retain)NSMutableArray *imagesByDateWithIDS;

-(void)forceNormalImageItemURLFetch:(NSString *)normalImageItem;
-(void)forceThumbImageItemURLFetch:(NSString *)thumbImageItem;
-(void)forceLargeImageItemURLFetch:(NSString *)largeImageItem;
-(void)loadThumbnailsFromURLFACEBOOK:(NSString *)feedURL;
-(void)loadImagesOfMeFromFacebook;
-(int)returnCountForRowOne;




@end
