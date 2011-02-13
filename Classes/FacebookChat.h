//
//  FacebookChat.h
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookUser.h"


@interface FacebookChat : NSObject {
	NSString *myself;
	NSString *fromUser;
	int status;
	NSMutableArray *facebookChatArray;
	NSMutableArray *toFromArray;
}

@property(nonatomic,retain)NSString *myself;
@property(readwrite)int status;
@property(nonatomic,retain)NSString *fromUser;
@property(nonatomic,retain)NSMutableArray *facebookChatArray;
@property(nonatomic,retain)NSMutableArray *toFromArray;

-(void)addMessageFrom:(NSString *)from andMessage:(NSString *)message;
-(void)addSentMessage:(NSString *)message;
-(void)clearConversation;




@end
