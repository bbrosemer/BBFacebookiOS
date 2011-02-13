//
//  AllChats.m
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "MutableChatDictionary.h"
#import "FacebookUser.h"


@implementation MutableChatDictionary
@synthesize chatDictionary;

-(void)print{
	NSLog(@"Dict: %@",chatDictionary);
}

-(FacebookChat *)addMessageForUser:(NSString *)facebookUser andMessage:(NSString *)message{
	if(chatDictionary == nil){
		chatDictionary = [[NSMutableDictionary alloc] init];
	}
	
	if([chatDictionary objectForKey:facebookUser]){
		[((FacebookChat *)[chatDictionary objectForKey:facebookUser]) addMessageFrom:facebookUser andMessage:message];
		[self print];
		return [chatDictionary objectForKey:facebookUser];
	}else{
		FacebookChat *newChat = [[FacebookChat alloc] init];
		newChat.fromUser = facebookUser;
		newChat.myself = @"me";
		[newChat addMessageFrom:facebookUser andMessage:message];
		[chatDictionary setObject:newChat forKey:facebookUser];
		[self print];
		return [chatDictionary objectForKey:facebookUser];
	}
}

-(void)createChatForUser:(NSString *)facebookUser{
	if(chatDictionary == nil){
		chatDictionary = [[NSMutableDictionary alloc] init];
	}
	
	if([chatDictionary objectForKey:facebookUser]){
		//[((FacebookChat *)[chatDictionary objectForKey:facebookUser]) addMessageFrom:facebookUser andMessage:message];
		//[self print];
		//return [chatDictionary objectForKey:facebookUser];
	}else{
		FacebookChat *newChat = [[FacebookChat alloc] init];
		newChat.fromUser = facebookUser;
		newChat.myself = @"me";
		//[newChat addMessageFrom:facebookUser andMessage:message];
		[chatDictionary setObject:newChat forKey:facebookUser];
		//[self print];
		//return [chatDictionary objectForKey:facebookUser];
	}
}

@end
