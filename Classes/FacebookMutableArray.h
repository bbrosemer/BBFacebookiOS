//
//  FacebookMutableArray.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/19/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookUser.h"
#import "FacebookItem.h"


@interface NSMutableArray (Addition)

-(FacebookItem *)getFacebookItem:(NSString *)facebookID;
-(FacebookUser *)getFacebookUser:(NSString *)facebookID;


-(FacebookItem *)getFacebookItemFromItemObjects:(NSString *)facebookID;
-(FacebookUser *)getFacebookUserFromArray:(NSMutableArray *)array andID:(NSString *)facebookID;

-(NSMutableArray *)addObjectSorted:(id)object;
-(NSMutableArray *)addObjectSortedByDate:(FacebookItem *)item;

@end