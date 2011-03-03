//
//  FilmImageCell.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/13/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "FilmImageCell.h"


@implementation FilmImageCell
@synthesize rowTopic,rowView,bgView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}




- (void)dealloc {
    [super dealloc];
}

@end
