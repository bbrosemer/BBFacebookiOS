//
//  AllChats.h
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookChat.h"


@interface MutableChatDictionary : NSObject {
	NSMutableDictionary *chatDictionary;
}
@property(nonatomic,retain)NSMutableDictionary *chatDictionary;
-(FacebookChat *)addMessageForUser:(NSString *)facebookUser andMessage:(NSString *)message;
-(void)createChatForUser:(NSString *)facebookUser;

@end
