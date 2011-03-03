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
#import "UIImage+NSCoder.h"
#import "FacebookItemHandler.h"
#import "FacebookMutableArray.h"
#import "SBJSON.h"
@implementation FacebookUser
@synthesize facebookUserId,itemId;
@synthesize facebookUserName;
@synthesize facebookUserImageSmall;
@synthesize facebookUserImageNormal;
@synthesize facebookUserImageLarge;
@synthesize facebookUserImageURL;
@synthesize delegate;
@synthesize facebookUserUpdatedTime;
@synthesize facebookUserUpdatedDateTime;
@synthesize facebookUserLink;
@synthesize facebookUserWork;
@synthesize facebookUserEmail;
@synthesize facebookUserGender;
@synthesize facebookUserQuotes;
@synthesize facebookUserBirthday;
@synthesize facebookUserHometown;
@synthesize facebookUserLastName;
@synthesize facebookUserEducation;
@synthesize facebookUserFirstName;
@synthesize facebookUserLanguages;
@synthesize facebookUserPolitical;
@synthesize facebookUserInterestedIn;
@synthesize facebookUserRelationshipStatus;
@synthesize facebookUserPhotosTaggedIn;
@synthesize facebookUserWall;

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
        facebookUserImageSmall = [[UIImage imageNamed:@""] retain];
        facebookUserImageLarge = [[UIImage imageNamed:@""] retain];
        facebookUserImageNormal = [[UIImage imageNamed:@""] retain];
        facebookUserImageURL = [[[NSString alloc]initWithString:@""] retain];
        //facebookUserBirthday = [[[NSString alloc]initWithString:@""] retain];
    }
    return self;
}


-(void)createFacebookUser:(NSOperationQueue *)queue andID:(NSString *)userId andGather:(BOOL)gather{
    self.itemId = [NSString stringWithString:userId];
    self.facebookUserId = [NSString stringWithString:userId];
    if(gather){
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?",userId];
    if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookLoginHandler getAccessToken]];
	}
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(createdUser:)];
	[queue addOperation:request];
    if(self.facebookUserImageLarge == nil){
        [self getBackgroundItemImageLarge:queue];
    }
    if(self.facebookUserImageNormal == nil){
        [self getBackgroundItemImageMedium:queue];
    }if(self.facebookUserImageSmall == nil){
        [self getBackgroundItemImageSmall:queue];
    }
        [self gatherUserWall:queue];
        [self loadImagesOfUserFromFacebook:queue];
    }
}


-(void)createdUser:(ASIHTTPRequest *)request{
    //NSLog(@"Created user");
    NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];	
    self.facebookUserBirthday = [facebook_response objectForKey:@"birthday"];
    self.facebookUserEmail = [facebook_response objectForKey:@"email"];
    self.facebookUserFirstName = [facebook_response objectForKey:@"first_name"];
    self.facebookUserGender = [facebook_response objectForKey:@"gender"];
    self.facebookUserHometown = [[facebook_response objectForKey:@"hometown"] objectForKey:@"name"];
    self.facebookUserLastName = [facebook_response objectForKey:@"last_name"];
    self.facebookUserLink = [facebook_response objectForKey:@"link"];
    self.facebookUserName = [facebook_response objectForKey:@"name"];
    self.facebookUserPolitical = [facebook_response objectForKey:@"political"];
    self.facebookUserQuotes = [facebook_response objectForKey:@"quotes"];
    self.facebookUserRelationshipStatus = [facebook_response objectForKey:@"relationship_status"];
    self.facebookUserUpdatedTime = [facebook_response objectForKey:@"updated_time"];
    [FacebookItemHandler somethingUpdated]; 
    [parser release];
}


-(void)getBackgroundItemImageSmall:(NSOperationQueue *)queue{
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.itemId];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		url_string = [NSString stringWithFormat:@"%@access_token=%@&%@", url_string, [FacebookLoginHandler getAccessToken],@"type=small"];
	}
    //NSLog(@"URL %@",url_string);
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestSmallDone:)];
	[queue addOperation:request];
}
-(void)getBackgroundItemImageMedium:(NSOperationQueue *)queue{
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.itemId];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		url_string = [NSString stringWithFormat:@"%@access_token=%@&%@", url_string, [FacebookLoginHandler getAccessToken],@"type=normal"];
	}
    //NSLog(@"URL %@",url_string);
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestNormalDone:)];
	[queue addOperation:request];
}
-(void)getBackgroundItemImageLarge:(NSOperationQueue *)queue{
    NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?", self.itemId];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		url_string = [NSString stringWithFormat:@"%@access_token=%@&%@", url_string, [FacebookLoginHandler getAccessToken],@"type=large"];
	}
    //NSLog(@"URL %@",url_string);
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestLargeDone:)];
	[queue addOperation:request];
}



- (void)requestSmallDone:(ASIHTTPRequest *)request{
	self.facebookUserImageSmall = [[UIImage alloc] initWithData:[request responseData]];
    [FacebookItemHandler somethingUpdated];
}

- (void)requestNormalDone:(ASIHTTPRequest *)request{
	self.facebookUserImageNormal = [[UIImage alloc] initWithData:[request responseData]];
	[FacebookItemHandler somethingUpdated];
}

- (void)requestLargeDone:(ASIHTTPRequest *)request{
	self.facebookUserImageLarge = [[UIImage alloc] initWithData:[request responseData]];
	[FacebookItemHandler somethingUpdated];
}


-(void)gatherUserWall:(NSOperationQueue *)queue{
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@/feed?",self.itemId];
    if ([FacebookLoginHandler getAccessToken] != nil) {
		url_string = [NSString stringWithFormat:@"%@access_token=%@&limit=50", url_string, [FacebookLoginHandler getAccessToken]];
	}
    //NSLog(@"URL FOR USERWALL %@",url_string);
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(wallGathered:)];
    [request setDidFailSelector:@selector(wallFail:)];
	[queue addOperation:request];
}

-(void)wallGathered:(ASIHTTPRequest *)request{
    NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
    [NSThread detachNewThreadSelector:@selector(backgroundWall:) toTarget:self withObject:responseString];
   // [self backgroundWall:responseString];
}

-(void)backgroundWall:(NSString *)responseString{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary  *tempDict = [parser objectWithString:responseString error:nil];
    NSArray *facebookResponse = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"data"]];
    for(int i = [facebookResponse count]-1; i >=0 ; i--){
        NSDictionary *dataDict = [[NSDictionary alloc] initWithDictionary:[facebookResponse objectAtIndex:i]];
        NSDictionary *creatorDictionary = [[NSDictionary alloc]initWithDictionary:[dataDict objectForKey:@"from"]];
        //NSLog(@"DATA DICT %@",dataDict);
        if(([facebookUserWall getFacebookItemFromItemObjects:[dataDict objectForKey:@"id"]]== nil)||(![[facebookUserWall getFacebookItemFromItemObjects:[dataDict objectForKey:@"id"]].facebookItemUpdatedTime isEqualToString:[dataDict objectForKey:@"updated_time"]])){
            FacebookItem *newFacebookItem = [[FacebookItem alloc] init];
            /*
            if([[facebookUserWall getFacebookItemFromItemObjects:[dataDict objectForKey:@"id"]].facebookItemUpdatedTime isEqualToString:[dataDict objectForKey:@"updated_time"]]){
                newFacebookItem = [[FacebookItemHandler sharedInstance].facebookItemObjects getFacebookItem:[dataDict objectForKey:@"id"]];
            }else{
                newFacebookItem.itemId = [NSString stringWithString:[dataDict objectForKey:@"id"]];
            }
            */
            newFacebookItem.itemId = [NSString stringWithString:[dataDict objectForKey:@"id"]];
           // newFacebookItem.facebookItemLikes = [[dataDict objectForKey:@"likes"] intValue];
            newFacebookItem.facebookItemMessage = [dataDict objectForKey:@"message"];
            
           //  NSLog(@"TEST PRINT %@ for id %@",newFacebookItem.facebookItemMessage,newFacebookItem.itemId);
            newFacebookItem.facebookItemFromID = [creatorDictionary objectForKey:@"id"];
            newFacebookItem.facebookItemToID = [[dataDict objectForKey:@"to"] objectForKey:@"id"];

            //*Create The NSThread For Adding A To //
           // [NSThread detachNewThreadSelector:@selector(backgroundUserFROM:) toTarget:self withObject:newFacebookItem]; 
           // [NSThread detachNewThreadSelector:@selector(backgroundUserTo:) toTarget:self withObject:newFacebookItem]; 
            
            /*
            //////////////////////////////////////////
            
            newFacebookItem.facebookImageItem = [[ImageItem alloc] initWithThumb:[((NSDictionary *)[imageArray objectAtIndex:(1)]) objectForKey:@"source"]];
            newFacebookItem.facebookImageItem.imageItemLargeURL = [imageArray objectAtIndex:0];
            newFacebookItem.facebookImageItem.imageItemNormalURL = [dataDict objectForKey:@"picture"];
            newFacebookItem.facebookImageItem.imageItemCreator = [creatorDictionary objectForKey:@"name"];
            newFacebookItem.facebookImageItem.imageItemCreationDate = [dataDict objectForKey:@"created_time"];
            newFacebookItem.facebookImageItem.imageItemPostID = [dataDict objectForKey:@"id"];
            newFacebookItem.facebookImageItem.imageItemTitle = [dataDict objectForKey:@"name"];
            newFacebookItem.initHashValue = [((NSString *)[dataDict objectForKey:@"id"]) longLongValue];
            //TAGS NEED TO BE DONE AS TAGS WILL BE THE FILTER ON THE IMAGES NOT ALBUMS >>>>
            */
            newFacebookItem.facebookItemCreateTime = [dataDict objectForKey:@"created_time"];
            newFacebookItem.facebookItemUpdatedTime = [dataDict objectForKey:@"updated_time"];
            newFacebookItem.facebookItemIconURL = [dataDict objectForKey:@"picture"];
            newFacebookItem.facebookItemLink = [dataDict objectForKey:@"link"];
            [newFacebookItem.facebookImageItem fetchThumbImage];
            if(self.facebookUserWall == nil){
                self.facebookUserWall = [[NSMutableArray alloc] init];
                [self.facebookUserWall addObjectSortedByDate:newFacebookItem];
                [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newFacebookItem];
                [newFacebookItem release];
            }else{
                [self.facebookUserWall addObjectSortedByDate:newFacebookItem];
                [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newFacebookItem];
                [newFacebookItem release];
            }
        }
    }
    [FacebookItemHandler wallDone];
    [parser release];
   [pool release];
}

-(void)backgroundUserFROM:(FacebookItem *)newFacebookItem{
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    FacebookUser *newUser = [[FacebookUser alloc] init];
    newUser = [[FacebookItemHandler sharedInstance].facebookUsers getFacebookUser:newFacebookItem.facebookItemFromID];
    if(newUser.itemId!=nil){
        
    }else{
        FacebookUser *newUser = [[FacebookUser alloc] init];
        newUser.itemId = [NSString stringWithString:newFacebookItem.facebookItemFromID];
        [[FacebookItemHandler sharedInstance].facebookUsers addObjectSorted:newUser];
        [newUser createFacebookUser:nil andID:newUser.itemId andGather:NO];
    }
    [pool release];
}

-(void)backgroundUserTO:(FacebookItem *)newFacebookItem{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    FacebookUser *newUser = [[FacebookUser alloc] init];
    newUser = [[FacebookItemHandler sharedInstance].facebookUsers getFacebookUser:newFacebookItem.facebookItemToID];
    if(newUser.itemId!=nil){
        
    }else{
        FacebookUser *newUser = [[FacebookUser alloc] init];
        newUser.itemId = [NSString stringWithString:newFacebookItem.facebookItemToID];
        [[FacebookItemHandler sharedInstance].facebookUsers addObjectSorted:newUser];
        [newUser createFacebookUser:nil andID:newUser.itemId andGather:NO];
    }
    [pool release];
}

- (void)wallFail:(ASIHTTPRequest *)request{
	NSLog(@"Failed !>!O");
}

- (NSComparisonResult)compare:(FacebookUser *)otherObject{
    //NSLog(@"cust compare");
    if([self.itemId isEqualToString:@"me"]){
        return nil;
    }
    NSNumberFormatter * form = [[NSNumberFormatter alloc] init];
    [form setNumberStyle:NSNumberFormatterNoStyle];
    NSNumber *tempNumber = [form numberFromString:self.itemId];
    NSNumber *objectNumber = [form numberFromString:otherObject.itemId];
    return [tempNumber compare:objectNumber];
}




-(void)loadImagesOfUserFromFacebook:(NSOperationQueue *)queue{
    NSString *feedURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos?",self.itemId];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		feedURL = [NSString stringWithFormat:@"%@access_token=%@&limit=25", feedURL, [FacebookLoginHandler getAccessToken]];
	}
    feedURL = [feedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   // NSLog(@" URL %@",feedURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:feedURL]];
    [request setDelegate:self];
	[request setDidFinishSelector:@selector(taggedInGathered:)];
	[queue addOperation:request];
}

-(void)taggedInGathered:(ASIHTTPRequest *)request{
     NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
   [NSThread detachNewThreadSelector:@selector(backgroundTaggedIn:) toTarget:self withObject:responseString]; 
   // [self backgroundTaggedIn:responseString];
}

-(void)backgroundTaggedIn:(NSString *)responseString{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    SBJSON *parser = [[SBJSON alloc] init];
    NSDictionary  *tempDict = [parser objectWithString:responseString error:nil];
    NSArray *facebookResponse = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"data"]];
    for(int i = [facebookResponse count]-1; i >=0 ; i--){
        NSDictionary *dataDict = [[NSDictionary alloc] initWithDictionary:[facebookResponse objectAtIndex:i]];
        NSLog(@"THE DICT %@",dataDict);
        NSDictionary *creatorDictionary = [[NSDictionary alloc]initWithDictionary:[dataDict objectForKey:@"from"]];
        NSArray *imageArray = [[NSArray alloc] initWithArray:[dataDict objectForKey:@"images"]];
        if(([facebookUserPhotosTaggedIn getFacebookItemFromItemObjects:[dataDict objectForKey:@"id"]]== nil)||(![[facebookUserPhotosTaggedIn getFacebookItemFromItemObjects:[dataDict objectForKey:@"id"]].facebookItemUpdatedTime isEqualToString:[dataDict objectForKey:@"updated_time"]])){
            FacebookItem *newFacebookItem = [[FacebookItem alloc] initWithID:[dataDict objectForKey:@"id"]];
            
            //  NSDictionary *tempDictImage = [[NSDictionary alloc] initWithDictionary:[imageArray objectAtIndex:[[imageArray count] -1]]];
            newFacebookItem.facebookImageItem = [[ImageItem alloc] initWithThumb:[((NSDictionary *)[imageArray objectAtIndex:(1)]) objectForKey:@"source"]];
            newFacebookItem.facebookImageItem.imageItemLargeURL = [imageArray objectAtIndex:0];
            newFacebookItem.facebookImageItem.imageItemNormalURL = [dataDict objectForKey:@"picture"];
            newFacebookItem.facebookImageItem.imageItemCreator = [creatorDictionary objectForKey:@"name"];
            newFacebookItem.facebookImageItem.imageItemCreationDate = [dataDict objectForKey:@"created_time"];
            newFacebookItem.facebookImageItem.imageItemPostID = [dataDict objectForKey:@"id"];
            newFacebookItem.facebookImageItem.imageItemTitle = [dataDict objectForKey:@"name"];
            newFacebookItem.initHashValue = [((NSString *)[dataDict objectForKey:@"id"]) longLongValue];
            //TAGS NEED TO BE DONE AS TAGS WILL BE THE FILTER ON THE IMAGES NOT ALBUMS >>>>
            
            newFacebookItem.facebookItemCreateTime = [dataDict objectForKey:@"created_time"];
            newFacebookItem.facebookItemUpdatedTime = [dataDict objectForKey:@"updated_time"];
            //  newFacebookItem.facebookItemFrom.facebookUserId = [creatorDictionary objectForKey:@"id"];
            // newFacebookItem.facebookItemFrom.facebookUserName = [creatorDictionary objectForKey:@"name"];
            newFacebookItem.facebookItemIconURL = [dataDict objectForKey:@"picture"];
            newFacebookItem.facebookItemLink = [dataDict objectForKey:@"link"];
            [newFacebookItem.facebookImageItem fetchThumbImage];
            if(self.facebookUserPhotosTaggedIn == nil){
                self.facebookUserPhotosTaggedIn = [[NSMutableArray alloc] init];
                [self.facebookUserPhotosTaggedIn addObjectSortedByDate:newFacebookItem];
                [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newFacebookItem];
                [newFacebookItem release];
            }else{
                [self.facebookUserPhotosTaggedIn addObjectSortedByDate:newFacebookItem];
                [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newFacebookItem];
                [newFacebookItem release];
            }
        }
    }
    [FacebookItemHandler somethingUpdated];
    [parser release];
    [pool release];
}



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.facebookUserId forKey:@"facebookUserId"];
    [encoder encodeObject:self.facebookUserName forKey:@"facebookUserName"];
    //[encoder encodeObject:self.facebookUserImage forKey:@"facebookUserImage"];
    [encoder encodeObject:self.facebookUserImageURL forKey:@"facebookUserImageURL"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.facebookUserId = [decoder decodeObjectForKey:@"facebookUserId"];
        self.facebookUserName = [decoder decodeObjectForKey:@"facebookUserName"];
        //self.facebookUserImage = [decoder decodeObjectForKey:@"facebookUserImage"];
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
    //[facebookUserImage release];
    [facebookUserImageURL release];
	//[queue release];
	[delegate release];
    [super dealloc];
}



@end
