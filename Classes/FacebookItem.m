/*
 Copyright (c) 2010, Brandyn Brosemer ,bbrosemer.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


#import "FacebookItem.h"
#import "ASIHTTPRequest.h"
#import "FacebookBBrosemer.h"
#import "UIImage+NSCoder.h"
#import "SBJSON.h"

@implementation FacebookItem
@synthesize itemId;
@synthesize facebookItemLink;
@synthesize facebookItemFrom;
@synthesize facebookItemMessage;
@synthesize facebookItemImageURL;
@synthesize facebookItemImage;
@synthesize facebookItemName;
@synthesize facebookItemCaption;
@synthesize facebookItemDescription;
@synthesize facebookItemIconURL;
@synthesize facebookItemIcon;
@synthesize facebookItemActions;
@synthesize facebookItemCreateTime;
@synthesize facebookItemUpdatedTime;
@synthesize facebookItemLikes;
@synthesize initHashValue;
@synthesize facebookItemComments;
@synthesize delegate;
@synthesize queue;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        itemId = [[[NSString alloc]initWithString:@""] retain];
		facebookItemLink = [[[NSString alloc]initWithString:@""] retain];
        facebookItemFrom = [[[FacebookUser alloc]init] retain];
        facebookItemMessage = [[[NSString alloc]initWithString:@""] retain];
        facebookItemImageURL = [[[NSString alloc]initWithString:@""] retain];
        facebookItemImage = [[UIImage imageNamed:@""] retain];
        facebookItemName = [[[NSString alloc]initWithString:@""] retain];
        facebookItemCaption = [[[NSString alloc]initWithString:@""] retain];
        facebookItemDescription = [[[NSString alloc]initWithString:@""] retain];
        facebookItemIconURL = [[[NSString alloc]initWithString:@""] retain];
        facebookItemIcon = [[UIImage imageNamed:@""] retain];
        facebookItemActions = [[[FacebookActions alloc]init] retain];
        facebookItemCreateTime = [[[NSString alloc]initWithString:@""] retain];
        facebookItemUpdatedTime = [[[NSString alloc]initWithString:@""] retain];
        facebookItemLikes = 0;
		initHashValue = 0;
        facebookItemComments = [[[NSArray alloc]init] retain];
    }
    return self;
}

-(id)initWithID:(NSString *)ID{
	self = [super init];
    if (self) {
        itemId = [[NSString alloc]initWithString:ID];
        facebookItemLink = [[[NSString alloc]initWithString:@""] retain];
		facebookItemFrom = [[[FacebookUser alloc]init] retain];
        facebookItemMessage = [[[NSString alloc]initWithString:@""] retain];
        facebookItemImageURL = [[[NSString alloc]initWithString:@""] retain];
        facebookItemImage = [[UIImage imageNamed:@""] retain];
        facebookItemName = [[[NSString alloc]initWithString:@""] retain];
        facebookItemCaption = [[[NSString alloc]initWithString:@""] retain];
        facebookItemDescription = [[[NSString alloc]initWithString:@""] retain];
        facebookItemIconURL = [[[NSString alloc]initWithString:@""] retain];
        facebookItemIcon = [[UIImage imageNamed:@""] retain];
        facebookItemActions = [[[FacebookActions alloc]init] retain];
        facebookItemCreateTime = [[[NSString alloc]initWithString:@""] retain];
        facebookItemUpdatedTime = [[[NSString alloc]initWithString:@""] retain];
        facebookItemLikes = 0;
		initHashValue = 0;
        facebookItemComments = [[[NSArray alloc]init] retain];
    }
    return self;
}




//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.itemId forKey:@"itemId"];
    [encoder encodeObject:self.facebookItemLink forKey:@"facebookItemLink"];
    [encoder encodeObject:self.facebookItemFrom forKey:@"facebookItemFrom"];
    [encoder encodeObject:self.facebookItemMessage forKey:@"facebookItemMessage"];
    [encoder encodeObject:self.facebookItemImageURL forKey:@"facebookItemImageURL"];
    [encoder encodeObject:self.facebookItemImage forKey:@"facebookItemImage"];
    [encoder encodeObject:self.facebookItemName forKey:@"facebookItemName"];
    [encoder encodeObject:self.facebookItemCaption forKey:@"facebookItemCaption"];
    [encoder encodeObject:self.facebookItemDescription forKey:@"facebookItemDescription"];
    [encoder encodeObject:self.facebookItemIconURL forKey:@"facebookItemIconURL"];
    [encoder encodeObject:self.facebookItemIcon forKey:@"facebookItemIcon"];
    [encoder encodeObject:self.facebookItemActions forKey:@"facebookItemActions"];
    [encoder encodeObject:self.facebookItemCreateTime forKey:@"facebookItemCreateTime"];
    [encoder encodeObject:self.facebookItemUpdatedTime forKey:@"facebookItemUpdatedTime"];
    [encoder encodeInt:self.facebookItemLikes forKey:@"facebookItemLikes"];
	[encoder encodeInt:self.initHashValue forKey:@"initHashValue"];
    [encoder encodeObject:self.facebookItemComments forKey:@"facebookItemComments"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.itemId = [decoder decodeObjectForKey:@"itemId"];
        self.facebookItemLink = [decoder decodeObjectForKey:@"facebookItemLink"];
        self.facebookItemFrom = [decoder decodeObjectForKey:@"facebookItemFrom"];
        self.facebookItemMessage = [decoder decodeObjectForKey:@"facebookItemMessage"];
        self.facebookItemImageURL = [decoder decodeObjectForKey:@"facebookItemImageURL"];
        self.facebookItemImage = [decoder decodeObjectForKey:@"facebookItemImage"];
        self.facebookItemName = [decoder decodeObjectForKey:@"facebookItemName"];
        self.facebookItemCaption = [decoder decodeObjectForKey:@"facebookItemCaption"];
        self.facebookItemDescription = [decoder decodeObjectForKey:@"facebookItemDescription"];
        self.facebookItemIconURL = [decoder decodeObjectForKey:@"facebookItemIconURL"];
        self.facebookItemIcon = [decoder decodeObjectForKey:@"facebookItemIcon"];
        self.facebookItemActions = [decoder decodeObjectForKey:@"facebookItemActions"];
        self.facebookItemCreateTime = [decoder decodeObjectForKey:@"facebookItemCreateTime"];
        self.facebookItemUpdatedTime = [decoder decodeObjectForKey:@"facebookItemUpdatedTime"];
        self.facebookItemLikes = [decoder decodeIntForKey:@"facebookItemLikes"];
		self.initHashValue = [decoder decodeIntForKey:@"initHashValue"];
        self.facebookItemComments = [decoder decodeObjectForKey:@"facebookItemComments"];
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
					   @"itemId",
					   @"facebookItemLink",
					   @"facebookItemFrom",
					   @"facebookItemMessage",
					   @"facebookItemImageURL",
					   @"facebookItemImage",
					   @"facebookItemName",
					   @"facebookItemCaption",
					   @"facebookItemDescription",
					   @"facebookItemIconURL",
					   @"facebookItemIcon",
					   @"facebookItemActions",
					   @"facebookItemCreateTime",
					   @"facebookItemUpdatedTime",
					   @"facebookItemLikes",
					   @"facebookItemComments",
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

-(void)startFetchingBackgroundImages{
	if(self.facebookItemImage == nil){
		[self fetchUserImage];
	}
}

-(void)otherThing{
	backgroundCount = 0;
	mainItem = 1;
	for(int i = 0;i<[self.facebookItemComments count];i++){
		backgroundCount++;
		//Call Image User Start Update
		[((FacebookItem *)[self.facebookItemComments objectAtIndex:i]).facebookItemFrom getBackgroundImage];
	}
}


-(void)checkForComments{
	if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?", self.itemId];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}else if([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]!=nil){
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, 
					  [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]];
	}
	//if(debugMode)
	//NSLog(@"URL %@",url_string);
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	//NSLog(@"DOING SOMETHING11111");
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestWentWell:)];
	[request setDidFailSelector:@selector(requestWentBad:)];
	[[self queue] addOperation:request];
}

- (void)requestWentWell:(ASIHTTPRequest *)request{
	//NSLog(@"RESPONSE STRING");
	NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	//if(debugMode)
	//NSLog(@"GRAPH RESPONSE %@",responseString);
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];	
	NSLog(@"DICTIONARY %@",facebook_response);
	if([facebook_response valueForKey:@"updated_time"]){
		self.facebookItemUpdatedTime = [NSString stringWithString:[facebook_response valueForKey:@"updated_time"]];
	}
	if([facebook_response objectForKey:@"likes"]){
		self.facebookItemLikes = [[[facebook_response objectForKey:@"likes"] valueForKey:@"count"] integerValue];
		//NSLog(@"LIKESSNFKLDF %i",self.facebookItemLikes);
	}else{
		self.facebookItemLikes = 0;
	}
	if([facebook_response valueForKey:@"comments"]){
		//NSLog(@"DOING SOMETHING");
		NSArray *tempArray = [NSArray arrayWithArray:[[facebook_response objectForKey:@"comments"] objectForKey:@"data"]];
		NSMutableArray *otherTemp = [[NSMutableArray alloc] init];
		for(int i = 0;i<[tempArray count];i++){
			FacebookItem *newItem = [[FacebookItem alloc] initWithID:[[tempArray objectAtIndex:i] objectForKey:@"id"]];
			newItem.facebookItemMessage = [[tempArray objectAtIndex:i] objectForKey:@"message"];
			//NSLog(@"MESSAGE %@",newItem.facebookItemMessage);
			if([[tempArray objectAtIndex:i] objectForKey:@"likes"]){
				newItem.facebookItemLikes = [[[tempArray objectAtIndex:i] valueForKey:@"likes"] integerValue];
				//NSLog(@"LIKES        SSSSSS %i",newItem.facebookItemLikes);
			}else{
				newItem.facebookItemLikes = 0;
			}
			if([[tempArray objectAtIndex:i] objectForKey:@"from"]){
				newItem.facebookItemFrom.facebookUserId=[NSString stringWithString:[[[tempArray objectAtIndex:i] objectForKey:@"from"] valueForKey:@"id"]];
				newItem.facebookItemFrom.facebookUserName=[NSString stringWithString:[[[tempArray objectAtIndex:i] objectForKey:@"from"] valueForKey:@"name"]];
			}
			[otherTemp addObject:newItem]; 
			if(i == 0){
				[self commentUserImage:0];
			}
		}
		self.facebookItemComments = [NSArray arrayWithArray:otherTemp];
		[otherTemp release];
	}
	[parser release];
	[FacebookBBrosemer update];
}

- (void)requestWentBad:(ASIHTTPRequest *)request{
	NSError *error = [request error];
	//NSLog(@"ERROR %@",error);
}


-(void)commentUserImage:(int)imageLocation{
	if(imageLocation >= [self.facebookItemComments count]){
		return;
	}
	if(imageLocation==0){
		globeUserCommentCounter = 0;
	}
	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", 
							((FacebookUser *)((FacebookItem *)[self.facebookItemComments objectAtIndex:globeUserCommentCounter]
											  ).facebookItemFrom).facebookUserId];
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
	NSLog(@"WORKED !>!O");
	if(globeUserCommentCounter < [self.facebookItemComments count]){
		((FacebookUser *)((FacebookItem *)[self.facebookItemComments objectAtIndex:globeUserCommentCounter]
						  ).facebookItemFrom).facebookUserImage = [[UIImage alloc] initWithData:[request responseData]];
		NSLog(@"WOvcvxRKED !>!O");
	}
	[FacebookBBrosemer update];
	NSLog(@"WxcvxcvxcvxcvscdsORKED !>!O");
	
	globeUserCommentCounter++;
	[self commentUserImage:globeUserCommentCounter];
}

-(void)requestWentWrongItem{
	//NSLog(@"Failed !>!O");
	
	globeUserCommentCounter++;
	[self commentUserImage:globeUserCommentCounter];
}

-(void)fetchUserImage{
	if(((FacebookUser *)self.facebookItemFrom).facebookUserImage == nil){
		//NSLog(@"CALLED WEEEEEEE");
		NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?",((FacebookUser *)self.facebookItemFrom).facebookUserId];
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
		url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//NSLog(@"URL STIRNG %@",url_string);
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
		NSError *err;
		NSURLResponse *resp;
		NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
		self.facebookItemFrom.facebookUserImage = [UIImage imageWithData:response];
		if(self.facebookItemImage == nil){
			[self fetchStoryImage];
		}
		
	}
}

-(void)fetchStoryImage{
	NSLog(@"CALLED WEEEEEEE");
	NSString *url_string = [NSString stringWithFormat:[self.facebookItemImageURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	//url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	NSLog(@"URL STIRNG %@",self.facebookItemImageURL);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.facebookItemImageURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSError *err;
	NSURLResponse *resp;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	self.facebookItemImage = [UIImage imageWithData:response];
}


-(void)userItemUpadated{
	NSLog(@"USER UPDATEDdsfsdf?");
}


-(void)userUpadated{
	NSLog(@"USER UPDATED?");
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [itemId release];
    [facebookItemLink release];
    [facebookItemFrom release];
    [facebookItemMessage release];
    [facebookItemImageURL release];
    [facebookItemImage release];
    [facebookItemName release];
    [facebookItemCaption release];
    [facebookItemDescription release];
    [facebookItemIconURL release];
    [facebookItemIcon release];
    [facebookItemActions release];
    [facebookItemCreateTime release];
    [facebookItemUpdatedTime release];
    [facebookItemComments release];
	[delegate release];
    [super dealloc];
}




@end
