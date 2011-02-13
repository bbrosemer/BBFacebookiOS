//
//  FacebookChat.m
//  iPhoneXMPP
//
//  Created by Brandyn on 1/31/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "FacebookChat.h"
#import "FacebookUser.h"

@implementation FacebookChat
@synthesize myself,fromUser,facebookChatArray,status,toFromArray;


//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        myself = [[[NSString alloc] init] retain];
		fromUser = [[[NSString alloc] init] retain];
		facebookChatArray = [[[NSMutableArray alloc] init] retain];
		toFromArray = [[[NSMutableArray alloc] init] retain];
		status = 0;
    }
    return self;
}


//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.myself forKey:@"myself"];
    [encoder encodeObject:self.fromUser forKey:@"fromUser"];
    [encoder encodeObject:self.facebookChatArray forKey:@"facebookChatArray"];
	[encoder encodeObject:self.toFromArray forKey:@"toFromArray"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.myself = [decoder decodeObjectForKey:@"myself"];
        self.fromUser = [decoder decodeObjectForKey:@"fromUser"];
        self.facebookChatArray = [decoder decodeObjectForKey:@"facebookChatArray"];
		self.toFromArray = [decoder decodeObjectForKey:@"toFromArray"];
    }
    return self;
}

-(void)addMessageFrom:(NSString *)from andMessage:(NSString *)message{
	self.fromUser = from;
	self.myself = @"me";
	[facebookChatArray addObject:message];
	[toFromArray addObject:fromUser];
}
-(void)addSentMessage:(NSString *)message{
	[facebookChatArray addObject:message];
	[toFromArray addObject:@"me"];
}
										
-(void)clearConversation{
	[facebookChatArray removeAllObjects];
	[toFromArray removeAllObjects];
}

@end
