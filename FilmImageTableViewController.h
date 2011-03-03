//
//  FilmImageTableViewController.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/13/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageHandler.h"

@interface FilmImageTableViewController : UITableViewController {
    ImageHandler *tempHandle;
}
@property(nonatomic,retain)ImageHandler *tempHandle;

@end
