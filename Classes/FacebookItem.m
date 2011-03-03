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
#import "FacebookItemHandler.h"
#import "ISO8601DateFormatter.h"

@implementation FacebookItem
@synthesize itemId;
@synthesize facebookItemLink;
@synthesize facebookItemFromID;
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
@synthesize facebookImageItem;
@synthesize facebookDateItemCreateTime;
@synthesize facebookItemToID;
@synthesize facebookDateItemUpdateTime;
@synthesize facebookItemAttribution;
@synthesize facebookItemSource;

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
        facebookItemFromID = [[[NSString alloc]initWithString:@""] retain];
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

-(void)setFacebookItemType:(FacebookItemType)type{
    itemType = type;
}
-(FacebookItemType)getFacebookItemType{
    return itemType;
}
-(void)setFacebookItemUpdated:(FacebookItemUpdated)type{
    updateType = type; 
}
-(FacebookItemUpdated)getFacebookItemUpdate{
    return updateType;
}


-(id)initWithID:(NSString *)ID{
	self = [super init];
    if (self) {
        itemId = [[NSString alloc]initWithString:ID];
        facebookItemLink = [[[NSString alloc]initWithString:@""] retain];
		facebookItemFromID = [[[NSString alloc]initWithString:@""] retain];
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
    [encoder encodeObject:self.facebookItemFromID forKey:@"facebookItemFromID"];
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
    [encoder encodeObject:self.facebookImageItem forKey:@"facebookImageItem"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.itemId = [decoder decodeObjectForKey:@"itemId"];
        self.facebookItemLink = [decoder decodeObjectForKey:@"facebookItemLink"];
        self.facebookItemFromID = [decoder decodeObjectForKey:@"facebookItemFromID"];
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
        self.facebookImageItem = [decoder decodeObjectForKey:@"facebookImageItem"];
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

-(FacebookUser *)getFacebookUser{
    return [FacebookItemHandler returnFacebookUserFromID:self.facebookItemFromID];
}





-(void)createFacebookItem:(NSOperationQueue *)queue andId:(NSString *)facebookId andGather:(BOOL)gather{
    self.itemId = [NSString stringWithString:facebookId];
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?",self.itemId];
    if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookLoginHandler getAccessToken]];
	}
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(itemCreated:)];
    [request setDidFailSelector:@selector(itemFail:)];
	[queue addOperation:request];
}

-(void)itemCreated:(ASIHTTPRequest *)request{
    NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];	
    NSLog(@"Item Dict %@",facebook_response);
    [parser release];
}

-(void)itemFail:(ASIHTTPRequest *)request{
    NSLog(@"Item fail");
}



- (NSComparisonResult)compare:(FacebookItem *)otherObject{
   // NSLog(@"COMPARE %@, %@ ",self.itemId,otherObject.itemId);
    NSNumberFormatter * form = [[[NSNumberFormatter alloc] init] autorelease];
    [form setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber *tempNumber = [form numberFromString:[self.itemId stringByReplacingOccurrencesOfString:@"_" withString:@""]];
    NSNumber *objectNumber = [form numberFromString:[otherObject.itemId stringByReplacingOccurrencesOfString:@"_" withString:@""]];
    return [tempNumber compare:objectNumber];
    //return NSOrderedSame;
}

- (NSComparisonResult)compareDate:(FacebookItem *)otherObject{
    ISO8601DateFormatter *formatter = [[[ISO8601DateFormatter alloc] init] autorelease];
    NSDate *tempNumber = [formatter dateFromString:self.facebookItemUpdatedTime];
    NSDate *objectNumber = [formatter dateFromString:otherObject.facebookItemUpdatedTime];
    return [objectNumber compare:tempNumber];
    //return NSOrderedSame;
}




//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [itemId release];
    [facebookItemLink release];
    [facebookItemFromID release];
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
    [facebookImageItem release];
    [super dealloc];
}


@end
