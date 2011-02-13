//
//  FacebookFriends.h
//  FacebookStaticTest
//
//  Created by Brandyn on 12/24/10.
//  Copyright 2010 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@protocol FacebookFriendsDelegate <NSObject>
@optional
-(void)facebookFriendsUpdated;
@end


@interface FacebookFriends : NSObject <ASICacheDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate> {
	NSMutableArray *facebookFriendArray;
	NSMutableArray *facebookFriendArrayCopy;
	NSOperationQueue *queue;
	int globeImageCounter;
	id delegate;
}

-(void)refreshFriends;
-(NSArray *)searchFriends:(NSString *)friendName;

@property (nonatomic, retain) NSMutableArray *facebookFriendArray;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, assign) id <FacebookFriendsDelegate> delegate;

- (id)init;
- (NSArray *)keyPaths;
- (void)startObservingObject:(id)thisObject;
- (void)stopObservingObject:(id)thisObject;



@end
