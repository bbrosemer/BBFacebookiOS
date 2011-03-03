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

#import "FacebookItemHandler.h"
#import "SBJSON.h"
//#import "FacebookMutableArray.h"
//#import "ISO8601DateFormatter.h"








@implementation FacebookItemHandler (private)

-(FacebookItem *)getTopFacebookItemFromID:(NSString *)facebookID{
    return [facebookItemObjects getFacebookItem:facebookID];
}

-(FacebookGraphDataResponse *)doGraphGet:(NSString *)action withGetVars:(NSDictionary *)get_vars {
	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?", action];
	
	//tack on any get vars we have...
	if ( (get_vars != nil) && ([get_vars count] > 0) ) {
		
		NSEnumerator *enumerator = [get_vars keyEnumerator];
		NSString *key;
		NSString *value;
		while ((key = (NSString *)[enumerator nextObject])) {
			
			value = (NSString *)[get_vars objectForKey:key];
			url_string = [NSString stringWithFormat:@"%@%@=%@&", url_string, key, value];
			
		}//end while	
	}//end if
	
	if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookLoginHandler getAccessToken]];
	}
	
	//encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [self doGraphGetWithUrlString:url_string];
}


-(NSString *)doGraphGet:(NSString *)action{
	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?", action];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookLoginHandler getAccessToken]];
	}
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	//[request setDownloadProgressDelegate:progressView];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSData *response = [request responseData];
		NSString *responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
		return responseString;
	}
	return [NSString stringWithFormat:@"Error"];
}

-(FacebookGraphDataResponse *)doGraphGetWithUrlString:(NSString *)url_string {
	
	FacebookGraphDataResponse *return_value = [[FacebookGraphDataResponse alloc] init];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
	
	NSError *err;
	NSURLResponse *resp;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	
	if (resp != nil) {
		
		/**
		 * In the case we request a picture (avatar) the Graph API will return to us the actual image
		 * bits versus a url to the image.....
		 **/
		if ([resp.MIMEType isEqualToString:@"image/jpeg"]) {
			
			UIImage *image = [UIImage imageWithData:response];
			return_value.imageResponse = image;
			
		} else if ([resp.MIMEType isEqualToString:@"text/javascript"]) {
			
			return_value.htmlResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		} else {
			
			return_value.htmlResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		}
		
	} else if (err != nil) {
		return_value.error = err;
	}
	
	return return_value;
	
}

-(FacebookGraphDataResponse *)doGraphGetWithJSON:(NSString *)url_string {
	
	FacebookGraphDataResponse *return_value = [[FacebookGraphDataResponse alloc] init];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_string]];
	
	NSError *err;
	NSURLResponse *resp;
	NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	return_value.htmlResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	return return_value;
	
}


- (FacebookGraphDataResponse *)doGraphPost:(NSString *)action withPostVars:(NSDictionary *)post_vars {
	
	FacebookGraphDataResponse *return_value = [[FacebookGraphDataResponse alloc] init];
	
	NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@", action];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSString *boundary = @"----1010101010";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSEnumerator *enumerator = [post_vars keyEnumerator];
	NSString *key;
	NSString *value;
	NSString *content_disposition;
	
	//loop through all our parameters 
	while ((key = (NSString *)[enumerator nextObject])) {
		
		//if it's a picture (file)...we have to append the binary data
		if ([key isEqualToString:@"file"]) {
			
			/*
			 * the FbGraphFile object is smart enough to append it's data to 
			 * the request automagically, regardless of the type of file being
			 * attached
			 */
			FacebookGraphData *upload_file = (FacebookGraphData *)[post_vars objectForKey:key];
			[upload_file appendDataToBody:body];
			
			//key/value nsstring/nsstring
		} else {
			value = (NSString *)[post_vars objectForKey:key];
			
			content_disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
			[body appendData:[content_disposition dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
			
		}//end else
		
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
	}//end while
	
	//add our access token
	[body appendData:[@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[FacebookLoginHandler  getAccessToken] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	//button up the request body
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:body];
	[request addValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField: @"Content-Length"];
	
	//quite a few lines of code to simply do the business of the HTTP connection....
    NSURLResponse *response;
    NSData *data_reply;
	NSError *err;
	
    data_reply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    return_value.htmlResponse = (NSString *)[[NSString alloc] initWithData:data_reply encoding:NSUTF8StringEncoding];
	
	if (err != nil) {
		
	}
	
	
	return return_value;
}

-(void)createFacebookItem:(NSString *)itemId{
    if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
    if([[FacebookItemHandler sharedInstance].facebookItemObjects count] == NULL){
        //NSLog(@"Test hmmm outer");
        FacebookItem *newItem = [[FacebookItem alloc] initWithID:itemId];
        [FacebookItemHandler sharedInstance].facebookItemObjects = [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newItem];
        [newItem createFacebookItem:[self queue] andId:itemId andGather:YES];
    }
    FacebookItem *newItem = [[FacebookItem alloc] init];
    newItem = [[FacebookItemHandler sharedInstance].facebookItemObjects getFacebookItem:itemId];
    if(newItem.facebookDateItemUpdateTime!=nil){
        [newItem createFacebookItem:[self queue] andId:itemId andGather:YES];
    }else{
        FacebookItem *newItem = [[FacebookItem alloc] initWithID:itemId];
        [FacebookItemHandler sharedInstance].facebookItemObjects = [[FacebookItemHandler sharedInstance].facebookItemObjects addObjectSorted:newItem];
        [newItem createFacebookItem:[self queue] andId:itemId andGather:YES];
    }
}

-(int)parseFacebookPost:(FacebookGraphDataResponse *)response{
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:response.htmlResponse error:nil];	
	[parser release];
    [self createFacebookItem:[facebook_response objectForKey:@"id"]];
    return 0;
}




-(void)addFacebookUser:(FacebookUser *)facebookUser{
    [facebookUsers addObjectSorted:facebookUser];
}

+(FacebookItemHandler*)sharedInstance {
	static FacebookItemHandler *facebookItemHandler = nil;
	if (facebookItemHandler == nil)
	{
		@synchronized(self) {
			if (facebookItemHandler == nil)
				facebookItemHandler = [[FacebookItemHandler alloc] init];
		}
	}
	
	return facebookItemHandler;
}
+(void)fbGraphCallback:(id)sender{
    NSLog(@"Logged In");
}





-(FacebookUser *)createFacebookUser:(NSString *)userId andGather:(BOOL)gather{ 
    if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
    if([[FacebookItemHandler sharedInstance].facebookUsers count] == NULL){
        if(![userId isEqualToString:@"me"]){
            FacebookUser *newUser = [[FacebookUser alloc] init];
            newUser.itemId = [NSString stringWithString:userId];
            //newUser.facebookUserId = [NSString stringWithString:userId];
            [[FacebookItemHandler sharedInstance].facebookUsers addObjectSorted:newUser];
            [newUser createFacebookUser:[self queue] andID:userId andGather:gather];
            return newUser;
        }else{
            if([FacebookItemHandler sharedInstance].me.itemId == nil){
                [FacebookItemHandler sharedInstance].me = [[FacebookUser alloc] init];
                [FacebookItemHandler sharedInstance].me.itemId = userId;
                //[FacebookItemHandler sharedInstance].me.facebookUserId = userId;
                [[FacebookItemHandler sharedInstance].me createFacebookUser:[self queue] andID:userId andGather:gather];
            }
            return [FacebookItemHandler sharedInstance].me;
        }
        
        return;
    }
    FacebookUser *newUser = [[FacebookUser alloc] init];
    newUser = [[FacebookItemHandler sharedInstance].facebookUsers getFacebookUser:userId];
    if(newUser.itemId!= nil){
        [newUser createFacebookUser:[self queue] andID:userId andGather:gather];
        return newUser;
    }else{
        if(![userId isEqualToString:@"me"]){
            FacebookUser *newUser = [[FacebookUser alloc] init];
            newUser.itemId = [NSString stringWithString:userId];
            //newUser.facebookUserId = [NSString stringWithString:userId];
            [[FacebookItemHandler sharedInstance].facebookUsers addObjectSorted:newUser];
            [newUser createFacebookUser:[self queue] andID:userId andGather:gather];
            return newUser;
        }else{
            if([FacebookItemHandler sharedInstance].me.itemId == nil){
                [FacebookItemHandler sharedInstance].me = [[FacebookUser alloc] init];
                [FacebookItemHandler sharedInstance].me.itemId = userId;
                //[FacebookItemHandler sharedInstance].me.facebookUserId = userId;
                [[FacebookItemHandler sharedInstance].me createFacebookUser:[self queue] andID:userId andGather:gather];
            }
            return [FacebookItemHandler sharedInstance].me;
        }
        
    }
}





-(void)getFriends{
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?"];
	if ([FacebookLoginHandler getAccessToken] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookLoginHandler getAccessToken]];
	}
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestFriends:)];
	[request startAsynchronous];
}

- (void)requestFriends:(ASIHTTPRequest *)request{
	if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
	NSString *responseString = [[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding] autorelease];
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];
	NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[facebook_response objectForKey:@"data"]];
    if([FacebookItemHandler sharedInstance].facebookUserFriends == NULL){
		[FacebookItemHandler sharedInstance].facebookUserFriends = [[NSMutableArray alloc] init];
	}
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
    [newArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
	for(int i = 0; i < [newArray count]; i++){
        [self createFacebookUser:[[newArray objectAtIndex:i] objectForKey:@"id"] andGather:NO];
	}
   	NSSortDescriptor *descriptor2 = [[NSSortDescriptor alloc] initWithKey:@"id"  ascending:YES];
    [newArray sortUsingDescriptors:[NSArray arrayWithObjects:descriptor2,nil]];
    for(int i = 0; i < [newArray count]; i++){
        [[FacebookItemHandler sharedInstance].facebookUserFriends addObject:[[newArray objectAtIndex:i] objectForKey:@"id"]];
	}
}

-(void)privateDelegate{
   // NSLog(@"got this far");
    [self.delegate facebookItemHandlerUpdated];
}

@end


@implementation FacebookItemHandler
@synthesize facebookItemObjects,facebookUsers,queue,facebookUserFriends,me,delegate;

+(FacebookUser *)returnFacebookUserFromID:(NSString *)userID{
    return [[FacebookItemHandler sharedInstance].facebookUsers getFacebookUser:userID];
}

+(void)getFacebookUserMe{
    [[FacebookItemHandler sharedInstance] createFacebookUser:@"me"];
}

+(void)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andTo:(NSString *)userName{
	if([FacebookLoginHandler loginUser]){
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		[variables setObject:link forKey:@"link"];
		[variables setObject:title forKey:@"name"];
		FacebookGraphDataResponse *fb_graph_response = [[FacebookItemHandler sharedInstance] doGraphPost:[NSString stringWithFormat:@"%@/feed",userName] withPostVars:variables];
		[[FacebookItemHandler sharedInstance] parseFacebookPost:fb_graph_response];
	}
}

+(FacebookUser *)createUser:(NSString *)userName andGather:(BOOL)gather{
   return [[FacebookItemHandler sharedInstance] createFacebookUser:userName andGather:gather];
}

+(NSMutableArray *)getFacebookUsers{
    return [FacebookItemHandler sharedInstance].facebookUsers;
}

+(NSMutableArray *)getItems{
    return [FacebookItemHandler sharedInstance].facebookItemObjects;
}

+(void)getMeFriends{
    if([FacebookItemHandler sharedInstance].facebookUsers == NULL){
        [FacebookItemHandler sharedInstance].facebookUsers = [[NSMutableArray alloc] init];
    }
    [[FacebookItemHandler sharedInstance] getFriends];
}

+(void)somethingUpdated{
    //NSLog(@"somehting happened");
    [[FacebookItemHandler sharedInstance] privateDelegate];
}

+(void)wallDone{
    [[FacebookItemHandler sharedInstance].delegate userWallLoaded];

}
+(void)thumbsDone{
    
}

@end

