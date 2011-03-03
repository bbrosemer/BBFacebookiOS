//
//  FilmImageCell.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/13/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilmRowScrollView.h"


@interface FilmImageCell : UITableViewCell {
    IBOutlet UILabel *rowTopic;
    IBOutlet FilmRowScrollView *rowView;
    IBOutlet UIView *bgView;
}

@property(nonatomic,retain)IBOutlet UILabel *rowTopic;
@property(nonatomic,retain)IBOutlet FilmRowScrollView *rowView;
@property(nonatomic,retain)IBOutlet UIView *bgView;

@end
