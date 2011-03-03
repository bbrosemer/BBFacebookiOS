//
//  FilmRowScrollView.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/13/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageHandler.h"


@interface FilmRowScrollView : UIScrollView <UIScrollViewDelegate> {
    NSMutableArray *tempHandler;
}
@property(nonatomic,retain)NSMutableArray *tempHandler;
-(void)setImages:(int)forRow;

@end
