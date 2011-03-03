
//
//  FacebookMutableArray.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/19/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "FacebookMutableArray.h"
#import "NSArray+CWSortedInsert.h"
#import "FacebookItemHandler.h"

@implementation NSMutableArray (Addition)

-(FacebookItem *)getFacebookItem:(NSString *)facebookID{
    FacebookItem *newItem = [[FacebookItem alloc] init];
    newItem.itemId = [NSString stringWithString:facebookID];
    int i = 0;
    if((i = [self indexOfObject:newItem inArraySortedBy:@selector(compare:)])==NSNotFound){
        return nil;
    }else{
        return [self objectAtIndex:i];
    }
    
}

-(FacebookUser *)getFacebookUser:(NSString *)facebookID{
    FacebookUser *newItem = [[FacebookUser alloc] init];
    newItem.itemId = [NSString stringWithString:facebookID];
    int i = 0;
    if((i = [self indexOfObject:newItem inArraySortedBy:@selector(compare:)])==NSNotFound){
        return nil;
    }else{
        return [self objectAtIndex:i];
    }
}


-(FacebookItem *)getFacebookItemFromItemObjects:(NSString *)facebookID{
    return [[FacebookItemHandler sharedInstance].facebookItemObjects getFacebookItem:facebookID];
}

-(FacebookUser *)getFacebookUserFromArray:(NSMutableArray *)array andID:(NSString *)facebookID{
    return [array getFacebookUser:facebookID];
}

-(NSMutableArray *)addObjectSorted:(id)object{
    [self addObject:object intoArraySortedBy:@selector(compare:)];
    return self;
}

-(NSMutableArray *)addObjectSortedByDate:(FacebookItem *)item{
    [self addByDate:item intoArraySortedBy:@selector(compareDate:)];
    return self;
}

@end



