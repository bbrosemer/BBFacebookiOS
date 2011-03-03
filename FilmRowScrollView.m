//
//  FilmRowScrollView.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/13/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "FilmRowScrollView.h"
#import "FacebookItem.h"
#import "ImageItem.h"
#import "FacebookMutableArray.h"
#import "FacebookItemHandler.h"
#define scale 2

@implementation FilmRowScrollView
@synthesize tempHandler;

-(void)setImages:(int)forRow{
    int i = 0;
    int j = 0;
    for(i = 0;i<[self.tempHandler count];i++){
        FacebookItem *tempItem = [[FacebookItem alloc] init];
        tempItem =  [self.tempHandler getFacebookItemFromItemObjects:[self.tempHandler objectAtIndex:i]];
       // UIImageView *userImageTemp = [[UIImageView alloc] initWithImage:tempItem.facebookImageItem.imageItemThumb];
        
        tempItem.facebookImageItem.imageViewThumb.frame = CGRectMake(((j+1)*4)+(75*j),4,75, 75);
        tempItem.facebookImageItem.imageViewThumb.contentMode = UIViewContentModeScaleAspectFill;
        tempItem.facebookImageItem.imageViewThumb.clipsToBounds = YES;
        tempItem.facebookImageItem.imageViewThumb.opaque = YES;
        [self addSubview:tempItem.facebookImageItem.imageViewThumb];
        //[userImageTemp release];
        if(i+1<[self.tempHandler count]){
            i++;
            FacebookItem *tempItem = [[FacebookItem alloc] init];
            tempItem =  [self.tempHandler getFacebookItemFromItemObjects:[self.tempHandler objectAtIndex:i]];
            //UIImageView *userImageTemp = [[UIImageView alloc] initWithImage:tempItem.facebookImageItem.imageItemThumb];
            tempItem.facebookImageItem.imageViewThumb.frame = CGRectMake(((j+1)*4)+(75*j),83,75, 75);
            tempItem.facebookImageItem.imageViewThumb.contentMode = UIViewContentModeScaleAspectFill;
            tempItem.facebookImageItem.imageViewThumb.clipsToBounds = YES;
            tempItem.facebookImageItem.imageViewThumb.opaque = YES;
            [self addSubview:tempItem.facebookImageItem.imageViewThumb];
            //[userImageTemp release]; 
        }
        j++;
    }
}

@end
