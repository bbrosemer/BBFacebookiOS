//
//  FacebookFriends.m
//  FacebookStaticTest
//
//  Created by Brandyn on 12/24/10.
//  Copyright 2010 bbrosemer.com. All rights reserved.
//

#import "FacebookFriends.h"
#import "FacebookBBrosemer.h"
#import "SBJSON.h"
#import "FacebookUser.h"

@implementation FacebookFriends
@synthesize facebookFriendArray;
@synthesize queue,delegate;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        facebookFriendArray = [[[NSMutableArray alloc]init] retain];
    }
    return self;
}



-(void)doGraphGet{
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?"];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[request startAsynchronous];
}

- (void)requestDone:(ASIHTTPRequest *)request{
	if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
	
	NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];
	NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[facebook_response objectForKey:@"data"]];
	if(self.facebookFriendArray !=nil){
		[self.facebookFriendArray release];
	}
	self.facebookFriendArray = [[NSMutableArray alloc] init];
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
    [newArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
	for(int i = 0; i < [newArray count]; i++){
		FacebookUser *newUser = [[FacebookUser alloc ]init];
		newUser.facebookUserName = [[newArray objectAtIndex:i] objectForKey:@"name"];
		newUser.facebookUserId = [[newArray objectAtIndex:i] objectForKey:@"id"];
		[self.facebookFriendArray addObject:newUser];
	}
	[self commentUserImage:0];
}


-(void)commentUserImage:(int)imageLocation{
	if(imageLocation==0){
		globeImageCounter = 0;
	}
	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", 
							((FacebookUser *)[self.facebookFriendArray objectAtIndex:imageLocation]).facebookUserId];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}
	
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//NSLog(@"URL STIRNG %@",url_string);
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDoneItem:)];
	[request setDidFailSelector:@selector(requestWentWrongItem:)];
	[[self queue] addOperation:request];
}

-(void)requestDoneItem:(ASIHTTPRequest *)request{
	((FacebookUser *)[self.facebookFriendArray objectAtIndex:globeImageCounter]).facebookUserImage = [[UIImage alloc] initWithData:[request responseData]];
	[FacebookBBrosemer friendsUpdated];
	globeImageCounter++;
	if(globeImageCounter == [self.facebookFriendArray count]){
		return;
	}
	[self commentUserImage:globeImageCounter];
}

-(void)requestWentWrongItem{
	globeImageCounter++;
	if(globeImageCounter == [self.facebookFriendArray count]){
		return;
	}
	[self commentUserImage:globeImageCounter];
}


- (void)requestWentWrong:(ASIHTTPRequest *)request{
	NSError *error = [request error];
	NSLog(@"Error: %@",error);
}

-(void)refreshFriends{
	[self doGraphGet];
}


//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.facebookFriendArray forKey:@"facebookFriendArray"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.facebookFriendArray = [decoder decodeObjectForKey:@"facebookFriendArray"];
    }
    return self;
}


//=========================================================== 
// - (NSArray *)keyPaths
//
//=========================================================== 
- (NSArray *)keyPaths
{
    NSArray *result = [NSArray arrayWithObjects:
					   @"facebookFriendArray",
					   nil];
	
    return result;
}


//=========================================================== 
// - (void)startObservingObject:
//
//=========================================================== 
- (void)startObservingObject:(id)thisObject
{
    if ([thisObject respondsToSelector:@selector(keyPaths)]) {
        NSEnumerator *e = [[thisObject keyPaths] objectEnumerator];
        NSString *thisKey;
		
        while (thisKey = [e nextObject]) {
            [thisObject addObserver:self
						 forKeyPath:thisKey
							options:NSKeyValueObservingOptionOld
							context:NULL];
        }
    }
}
- (void)stopObservingObject:(id)thisObject
{
    if ([thisObject respondsToSelector:@selector(keyPaths)]) {
        NSEnumerator *e = [[thisObject keyPaths] objectEnumerator];
        NSString *thisKey;
		
        while (thisKey = [e nextObject]) {
            [thisObject removeObserver:self forKeyPath:thisKey];
        }
    }
}

//=========================================================== 
// - (NSString *)descriptionForKeyPaths
//
//=========================================================== 
- (NSString *)descriptionForKeyPaths 
{
    NSMutableString *desc = [NSMutableString string];
    NSEnumerator *e = [[self keyPaths] objectEnumerator];
    NSString *thisKey;
    [desc appendString:@"\n\n"];
	
    while (thisKey = [e nextObject]) {
        [desc appendFormat: @"%@: %@\n", thisKey, [self valueForKey:thisKey]];
    }
	
    return [NSString stringWithString:desc];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [facebookFriendArray release];
	
    [super dealloc];
}



@end
