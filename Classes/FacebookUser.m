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

#import "FacebookUser.h"
#import "ASIHTTPRequest.h"
#import "FacebookBBrosemer.h"
#import "UIImage+NSCoder.h"

@implementation FacebookUser
@synthesize facebookUserId;
@synthesize facebookUserName;
@synthesize facebookUserImage;
@synthesize facebookUserImageURL;
@synthesize queue;
@synthesize delegate;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        facebookUserId = [[[NSString alloc]initWithString:@""] retain];
        facebookUserName = [[[NSString alloc]initWithString:@""] retain];
        facebookUserImage = [[UIImage imageNamed:@""] retain];
        facebookUserImageURL = [[[NSString alloc]initWithString:@""] retain];
    }
    return self;
}


-(void)getBackgroundImage{	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.facebookUserImageURL];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}
	if(debugMode)
		NSLog(@"URL %@",url_string);
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[[self queue] addOperation:request]; //queue is an NSOperationQueue
}


-(void)getBackgroundItemImage{	
	NSLog(@"???");
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.facebookUserImageURL];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}
	//if(debugMode)
		NSLog(@"URL %@",url_string);
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestDoneItem:)];
	[request setDidFailSelector:@selector(requestWentWrongItem:)];
	[[self queue] addOperation:request]; //queue is an NSOperationQueue
}


- (void)requestDone:(ASIHTTPRequest *)request{
	NSData *response = [request responseData];
	self.facebookUserImage = [[UIImage alloc] initWithData:response];
	[response release];
	[delegate userUpadated];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request{
	[delegate userUpadated];
}

- (void)requestDoneItem:(ASIHTTPRequest *)request{
	NSLog(@"WORKED !>!O");
	self.facebookUserImage = [[UIImage alloc] initWithData:[request responseData]];
	[delegate userItemUpadated];
}

- (void)requestWentWrongItem:(ASIHTTPRequest *)request{
	NSLog(@"Failed !>!O");
	[delegate userItemUpadated];
}

//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.facebookUserId forKey:@"facebookUserId"];
    [encoder encodeObject:self.facebookUserName forKey:@"facebookUserName"];
    [encoder encodeObject:self.facebookUserImage forKey:@"facebookUserImage"];
    [encoder encodeObject:self.facebookUserImageURL forKey:@"facebookUserImageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.facebookUserId = [decoder decodeObjectForKey:@"facebookUserId"];
        self.facebookUserName = [decoder decodeObjectForKey:@"facebookUserName"];
        self.facebookUserImage = [decoder decodeObjectForKey:@"facebookUserImage"];
        self.facebookUserImageURL = [decoder decodeObjectForKey:@"facebookUserImageURL"];
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
					   @"facebookUserId",
					   @"facebookUserName",
					   @"facebookUserImage",
					   @"facebookUserImageURL",
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
    [facebookUserId release];
    [facebookUserName release];
    [facebookUserImage release];
    [facebookUserImageURL release];
	[queue release];
	[delegate release];
    [super dealloc];
}



@end
