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

#import "FacebookBBrosemer.h"
#import "FacebookFriends.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "RootViewController.h"

#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"

#import <CFNetwork/CFNetwork.h>
#import <QuartzCore/QuartzCore.h>
#import "MutableChatDictionary.h"
#import "UIColor-Expanded.h"


//NSString *const kDefaultApplication		= @"184197731594116";
//NSString *const kDefaultPermissions		= @"user_photos,user_videos,publish_stream,offline_access";
@interface NSMutableArray  (MyAdd)

-(NSMutableArray *)addObjectSorted:(FacebookItem *)object;

@end

@implementation NSMutableArray (MyAdd)

//SEXY Sorted List // So Do Binary Search To Find Next Location To Add
-(NSMutableArray *)addObjectSorted:(FacebookItem *)object{
	if([[self lastObject] initHashValue]<[object initHashValue]){
		[self addObject:object];
		return self;
	}
	if([[self objectAtIndex:0] initHashValue]>[object initHashValue]){
		[self insertObject:object atIndex:0];
		return self;
	}
	int max = [self count];
	int min = 0, mid;
	int value = [object initHashValue];
	
	//if we find our value, result = 1
	bool foundValue = false;
	
	NSLog(@"we are checking our array for value %i",value);
	
	while (min<max ) {
		mid = (min+max)/2;
		NSLog(@"min = %i , max = %i, mid = %i",min,max,mid);
		if ([[self objectAtIndex:mid] initHashValue]==value){
			foundValue = true; break;
		}else if (value > [[self objectAtIndex:mid] initHashValue]){
			min = mid+1;
		}else{
			max = mid-1;
		}
	}if(foundValue==0){
		if(value<[[self objectAtIndex:mid] initHashValue]){
			if(debugMode)
				NSLog(@"Add Object At Index %i",mid-1);
			
			[self insertObject:object atIndex:mid-1];
		}else if(value>[[self objectAtIndex:mid] initHashValue]){
			if(debugMode)
				NSLog(@"Add Object At Index %i",mid+1);
			
			[self insertObject:object atIndex:mid+1];
		}
	}
	return self;
}

@end






@interface FacebookBBrosemer (private)
- (void)success:(NSString *)success;
- (int)createFacebookItem:(NSString *)ID;
- (void)setFbClientID:(NSString *)fbcid;
- (BOOL)connectedToNetwork;
- (void)errorWithString:(NSString *)errorString;
+ (FacebookBBrosemer*)sharedInstance;
- (NSString *)doGraphGet:(NSString *)action;
- (void)authenticateUserWithCallbackObject:(id)anObject andSelector:(SEL)selector andExtendedPermissions:(NSString *)extended_permissions;
- (FacebookGraphDataResponse *)doGraphGet:(NSString *)action withGetVars:(NSDictionary *)get_vars;
- (FacebookGraphDataResponse *)doGraphGetWithUrlString:(NSString *)url_string;
- (FacebookGraphDataResponse *)doGraphPost:(NSString *)action withPostVars:(NSDictionary *)post_vars;
-(void)loginInternal;
@end

@implementation FacebookBBrosemer (private)
-(void)setAccessToken:(NSString *)textValue
{
    if (textValue != accessToken)
    {
        [textValue retain];
        [accessToken release];
        accessToken = textValue;
    }
}

-(NSString *)getAccessToken{		
	return accessToken;
}

-(BOOL)is_isGlobalLogin{
    return globalLogin;
}

-(void)setGlobalLogin:(BOOL)theBoolean {
	globalLogin = theBoolean;
}


-(void)errorWithString:(NSString *)errorString{
	if(debugMode){
		NSLog(@"Error: %@",errorString);
	}
}

-(void)success:(NSString *)success{
	if(debugMode){
		NSLog(@"Success: %@",success);
	}
}


- (void)setFbClientID:(NSString *)fbcid{
	loggedIn = NO;
	globalLogin = NO;
	facebookClientID = fbcid;
	redirectUri = @"http://www.facebook.com/connect/login_success.html";	
}

-(void)loadingAlert{
	baseAlert2 = [[[UIAlertView alloc] initWithTitle:@"Signing into Facebook" message:nil 
											delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
	[baseAlert2 show];
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]
									initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.center = CGPointMake(baseAlert2.bounds.size.width /2.0f, baseAlert2.bounds.size.height - 40.0f);
	[aiv startAnimating];
	baseAlert2.tag = 1;
	[baseAlert2 addSubview:aiv];
	[aiv release];
}



-(void)authenticateUserWithCallbackObject:(id)anObject andSelector:(SEL)selector andExtendedPermissions:(NSString *)extended_permissions andSuperView:(UIView *)super_view {
	callbackObject = anObject;
	callbackSelector = selector;
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&redirect_uri=%@&scope=%@&type=user_agent&display=touch", facebookClientID, redirectUri, extended_permissions];
	NSURL *url = [NSURL URLWithString:url_string];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	CGRect webFrame = [super_view frame];
	webFrame.origin.y = 20;
	UIWebView *aWebView = [[UIWebView alloc] initWithFrame:webFrame];
	[aWebView setDelegate:self];	
	webView = aWebView;
	[webView loadRequest:request];	
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationBeginsFromCurrentState:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:super_view cache:YES];
	[super_view addSubview:webView];
    [UIView commitAnimations];
	[self loadingAlert];
	showLoad = YES;
}

-(void)authenticateUserWithCallbackObject:(id)anObject andSelector:(SEL)selector andExtendedPermissions:(NSString *)extended_permissions{
	if([self connectedToNetwork]){
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		if (!window) {
			window = [[UIApplication sharedApplication].windows objectAtIndex:0];
		}
		[self authenticateUserWithCallbackObject:anObject andSelector:selector andExtendedPermissions:extended_permissions andSuperView:window];
	}else{
		[self errorWithString:[NSString stringWithString:@"No Network Connection"]];
	}
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
	
	if (accessToken != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, accessToken];
	}
	
	//encode the string
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if(debugMode)
		NSLog(@"URL String: %@",url_string);
	return [self doGraphGetWithUrlString:url_string];
}


-(NSString *)doGraphGet:(NSString *)action{
	
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/%@?", action];
	if (accessToken != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, accessToken];
	}
	if(debugMode)
		NSLog(@"URL %@",url_string);
	
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDownloadProgressDelegate:progressView];
	[request startSynchronous];
	NSError *error = [request error];
	if(debugMode)
		NSLog(@"Error %@",error);
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
	if(debugMode)
		NSLog(@"WORK %@",return_value.htmlResponse);
	
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
	[body appendData:[[[FacebookBBrosemer sharedInstance] getAccessToken] dataUsingEncoding:NSUTF8StringEncoding]];
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
		//return_value.error = err;
		//if(debugMode)
		//NSLog(@"Err %@",err);
	}
	
	/*
	 * return the json array.  we could parse it, but that would incur overhead 
	 * some users might not want (not to mention dependencies), besides someone 
	 * may want raw strings back, keep it simple.
	 *
	 * See:  http://code.google.com/p/json-framework for an easy json parser
	 */
	
	return return_value;
}


- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	if(showLoad){
		showLoad = NO;
		[baseAlert2 dismissWithClickedButtonIndex:0 animated:NO]; 
	}
	
	/**
	 * Since there's some server side redirecting involved, this method/function will be called several times
	 * we're only interested when we see a url like:  http://www.facebook.com/connect/login_success.html#access_token=..........
	 */
	
	//get the url string
	NSString *url_string = [((_webView.request).URL) absoluteString];
	//NSLog(@"URL STRING TEST %@",url_string);
	//looking for "access_token="
	NSRange access_token_range = [url_string rangeOfString:@"access_token="];
	
	//it exists?  coolio, we have a token, now let's parse it out....
	if (access_token_range.length > 0) {
		//self._isLoggedIn = YES;
		//we want everything after the 'access_token=' thus the position where it starts + it's length
		int from_index = access_token_range.location + access_token_range.length;
		NSString *access_token = [url_string substringFromIndex:from_index];
		
		//finally we have to url decode the access token
		access_token = [access_token stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		//remove everything '&' (inclusive) onward...
		NSRange period_range = [access_token rangeOfString:@"&"];
		
		//move beyond the .
		access_token = [access_token substringToIndex:period_range.location];
		
		//store our request token....
		NSLog(@"token:  %@", access_token);	
		[FacebookBBrosemer sharedInstance].accessToken = [NSString stringWithString:access_token];
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:access_token] forKey:@"accessToken"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		//remove our window
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		if (!window) {
			window = [[UIApplication sharedApplication].windows objectAtIndex:0];
		}
		
		
		[webView removeFromSuperview];
		[webView release];
		
		//[UIView commitAnimations];
		webView = nil;
		loggedIn = YES;
		globalLogin = YES;
		//tell our callback function that we're done logging in :)
		if ( (callbackObject != nil) && (callbackSelector != nil) ) {
			loggedIn = YES;
			globalLogin = YES;
			if(debugMode)
				NSLog(@"LOGGED IN");
			[callbackObject performSelector:callbackSelector];
		}
	}//end if length > 0
	if([url_string hasPrefix:@"http://www.facebook.com/connect/login_success.html?error_reason"]){
		//[UIView beginAnimations:nil context:nil];
		//[UIView setAnimationDuration:1.0];
		//[UIView setAnimationBeginsFromCurrentState:NO];
		//[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:webView cache:YES];
		
		[webView removeFromSuperview];
		[webView release];
		
		//[UIView commitAnimations];
		
		
		
	}
}



-(BOOL)connectedToNetwork {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
	NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:self];
	
    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}

+(FacebookBBrosemer*)sharedInstance {
	static FacebookBBrosemer *facebookBBrosemer = nil;
	if (facebookBBrosemer == nil)
	{
		@synchronized(self) {
			if (facebookBBrosemer == nil)
				facebookBBrosemer = [[FacebookBBrosemer alloc] init];
		}
	}
	
	return facebookBBrosemer;
}

+(void)fbGraphCallback:(id)sender{
	if(debugMode){
		NSLog(@"Logged In");
	}
}

-(int)createFacebookItem:(NSString *)ID{
	NSString *responseString = [[NSString alloc] initWithString:[[FacebookBBrosemer sharedInstance] doGraphGet:ID]];
	[[FacebookBBrosemer sharedInstance].progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	if(debugMode)
		NSLog(@"GRAPH RESPONSE %@",responseString);
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:responseString error:nil];	
	if(debugMode){
		NSLog(@"Response Dict: %@",facebook_response);
	}
	FacebookItem *newItem = [[FacebookItem alloc] initWithID:[facebook_response valueForKey:@"id"]];
	if([facebook_response valueForKey:@"link"]){
		newItem.facebookItemLink = [NSString stringWithString:[facebook_response objectForKey:@"link"]];
	}
	if([facebook_response valueForKey:@"updated_time"]){
		newItem.facebookItemUpdatedTime = [NSString stringWithString:[facebook_response valueForKey:@"updated_time"]];
	}
	if([facebook_response valueForKey:@"created_time"]){
		newItem.facebookItemCreateTime = [NSString stringWithString:[facebook_response valueForKey:@"created_time"]];
	}
	if([facebook_response valueForKey:@"picture"]){
		newItem.facebookItemImageURL = [NSString stringWithString:[facebook_response objectForKey:@"picture"]];
	}
	if([facebook_response valueForKey:@"name"]){
		newItem.facebookItemName = [facebook_response valueForKey:@"name"];
	}
	if([facebook_response valueForKey:@"message"]){
		newItem.facebookItemMessage = [facebook_response valueForKey:@"message"];
	}
	if([facebook_response valueForKey:@"icon"]){
		newItem.facebookItemIconURL = [facebook_response valueForKey:@"icon"];
	}
	if([facebook_response valueForKey:@"description"]){
		newItem.facebookItemDescription = [facebook_response valueForKey:@"description"];
	}
	if([facebook_response valueForKey:@"caption"]){
		newItem.facebookItemCaption  = [facebook_response valueForKey:@"caption"];
	}if([facebook_response valueForKey:@"from"]){
		newItem.facebookItemFrom.facebookUserId=[NSString stringWithString:[[facebook_response valueForKey:@"from"] valueForKey:@"id"]];
		newItem.facebookItemFrom.facebookUserName=[NSString stringWithString:[[facebook_response valueForKey:@"from"] valueForKey:@"name"]];
	}if([facebook_response valueForKey:@"actions"]){
		newItem.facebookItemActions.facebookActionCommentString=
		[NSString stringWithString:[[[facebook_response 
									  valueForKey:@"actions"] 
									 objectAtIndex:0] 
									valueForKey:@"link"]];
		newItem.facebookItemActions.facebookActionLikeString=
		[NSString stringWithString:[[[facebook_response 
									  valueForKey:@"actions"] 
									 objectAtIndex:1] 
									valueForKey:@"link"]];
	}
	[parser release];
	int hashValue = newItem.initHashValue = [newItem hash];
	[[FacebookBBrosemer sharedInstance].newestFirstArray insertObject:newItem atIndex:0];
	[[FacebookBBrosemer sharedInstance].facebookPostsArray addObjectSorted:newItem];
	[newItem startFetchingBackgroundImages];
	[newItem release];
	return hashValue;
}

-(int)parseFacebookPost:(FacebookGraphDataResponse *)response{
	if(debugMode){
		NSLog(@"Graph Response %@",response);
	}
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *facebook_response = [parser objectWithString:response.htmlResponse error:nil];	
	[parser release];
	if(debugMode){
		NSLog(@"Response Dict: %@",facebook_response);
	}
	return [[FacebookBBrosemer sharedInstance] createFacebookItem:(NSString *)[facebook_response objectForKey:@"id"]];
}


-(void)userImageAsyc{
	NSString *url_string = [NSString stringWithFormat:@"https://graph.facebook.com/me/picture?"];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		url_string = [NSString stringWithFormat:@"%@access_token=%@", url_string, [FacebookBBrosemer getAccessTokenClass]];
	}
	url_string = [url_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_string]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(imageDone:)];
	[request setDidFailSelector:@selector(imageWrong:)];
	[request startAsynchronous];
}

-(void)imageDone:(ASIHTTPRequest *)request{
	((FacebookUser *)[FacebookBBrosemer sharedInstance].meUser).facebookUserImage = 
	[[UIImage alloc] initWithData:[request responseData]];
}

-(void)imageWrong:(ASIHTTPRequest *)request{
	NSLog(@"Error %@",[request error]);
	return;
}


-(void)signInChat{
	xmppStream = [[XMPPStream alloc] init];
	chats = [[MutableChatDictionary alloc] init];
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	xmppRoster = [[XMPPRoster alloc] initWithStream:xmppStream rosterStorage:xmppRosterStorage];
	
	[xmppStream addDelegate:self];
	[xmppRoster addDelegate:self];
	
	[xmppRoster setAutoRoster:YES];
	
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	[xmppStream setHostName:@"chat.facebook.com"];
	[xmppStream setHostPort:5222];
	
	// Replace me with the proper JID and password
	[xmppStream setMyJID:[XMPPJID jidWithString:@"YOUR FACEBOOK USER NAME@chat.facebook.com"]];
	password = @"ENTER YOUR PASSWORD";
	
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
	
	// Uncomment me when the proper information has been entered above.
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		NSLog(@"Error connecting: %@", error);
	}
	
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Custom
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
// 
// In addition to this, the NSXMLElementAdditions class provides some very handy methods for working with XMPP.
// 
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
// 
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[presence addAttributeWithName:@"type" stringValue:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	//NSLog(@"---------- xmppStream:willSecureWithSettings: ----------");
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"chat.facebook.com"])
		{
			if ([virtualDomain isEqualToString:@"chat.facebook.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	//NSLog(@"---------- xmppStreamDidSecure: ----------");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	//NSLog(@"---------- xmppStreamDidConnect: ----------");
	
	isOpen = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	//NSLog(@"---------- xmppStreamDidAuthenticate: ----------");
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	//NSLog(@"---------- xmppStream:didNotAuthenticate: ----------");
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	//NSLog(@"---------- xmppStream:didReceiveIQ: ----------");
	
	return NO;
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
	if([[message elementForName:@"body"] stringValue] != NULL){
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];		
		CGRect viewFrame = CGRectMake(0, 0, 320, 44);
		viewFrame.origin.y = -44;
		if(alertView == NULL){
			alertView = [[UIView alloc] initWithFrame:viewFrame];
			alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
			alertLabel.backgroundColor = [UIColor clearColor];
			alertLabel.textColor = [UIColor whiteColor];
			alertLabel.textAlignment = UITextAlignmentCenter;
			
			
			alertLabel.numberOfLines = 0;
			[alertView addSubview:alertLabel];
			[window addSubview:alertView];
			alertView.backgroundColor = [UIColor colorWithHexString:@"3B5998"];
		}
		
		if(alertView.frame.origin.y == -44){
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:1.0];
			[UIView setAnimationDidStopSelector:@selector(done)];
			[chats addMessageForUser:[xmppRosterStorage userForJID:[message from]].displayName andMessage:
			 [[message elementForName:@"body"] stringValue]];
			alertLabel.text = [NSString stringWithFormat:@"%@ : \"%@\"",[xmppRosterStorage userForJID:
																		 [message from]].displayName,[[message elementForName:@"body"] stringValue]];
			alertView.frame = CGRectMake(0, 20,320, 44);
			[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:alertView cache:YES];
			[UIView commitAnimations];
		}else{
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:1.0];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(done)];
			[chats addMessageForUser:[xmppRosterStorage userForJID:[message from]].displayName andMessage:
			 [[message elementForName:@"body"] stringValue]];
			alertLabel.text = [NSString stringWithFormat:@"%@ : \"%@\"",[xmppRosterStorage userForJID:
																		 [message from]].displayName,[[message elementForName:@"body"] stringValue]];
			//alertView.frame = CGRectMake(0, 20,320, 44);
			[UIView setAnimationTransition:UIViewAnimationCurveLinear forView:alertView cache:YES];
			[UIView commitAnimations];
		}
		[FacebookBBrosemer sharedInstance].rootViewController.fromUser = [NSString stringWithFormat:[xmppRosterStorage userForJID:
																									 [message from]].displayName];
		[[FacebookBBrosemer sharedInstance].rootViewController updateChat];
	}
	
	
	
	//NSLog(@"---------- xmppStream:didReceiveMessage: ----------");
}

-(void)done{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:2.0];
 	alertView.frame = CGRectMake(0, -44,320, 44);
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:alertView cache:YES];
	[UIView commitAnimations];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	//NSLog(@"---------- xmppStream:didReceivePresence: ----------");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	//NSLog(@"---------- xmppStream:didReceiveError: ----------");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender
{
	//NSLog(@"---------- xmppStreamDidDisconnect: ----------");
	
	if (!isOpen)
	{
		//NSLog(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

-(MutableChatDictionary *)mutableChatDictionary{
	return chats;
}

-(XMPPStream *)xmppStream{
	return xmppStream;
}

-(XMPPRoster *)xmppRoster{
	return xmppRoster;
}
-(XMPPRosterCoreDataStorage *)xmppRosterStorage{
	return xmppRosterStorage;
}

@end

@implementation FacebookBBrosemer
@synthesize navController,facebookTable,permissions,iPadView;
@synthesize facebookPostsArray,accessToken,newestFirstArray;
@synthesize delegate,progressView,progressAlert,friendList,wallPostController,meUser,rootViewController;
@synthesize window;
@synthesize navigationController;


+(void)presentProgressDelegate{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[FacebookBBrosemer sharedInstance].progressAlert = [[UIAlertView alloc] initWithTitle: @"Facebook"
																				  message: @"Posting..."
																				 delegate: self
																		cancelButtonTitle: nil
																		otherButtonTitles: nil];
	[FacebookBBrosemer sharedInstance].progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)] autorelease];
	[[FacebookBBrosemer sharedInstance].progressAlert addSubview:[FacebookBBrosemer sharedInstance].progressView];
	[[FacebookBBrosemer sharedInstance].progressView setProgressViewStyle: UIProgressViewStyleBar];
	[[FacebookBBrosemer sharedInstance].progressAlert show];
	[pool release];
}

+(void)update{
	[[FacebookBBrosemer sharedInstance].progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	if([FacebookBBrosemer sharedInstance].facebookTable != nil){
		[[FacebookBBrosemer sharedInstance].facebookTable sendUpdate];
	}
}

+(void)friendsUpdated{
	if([FacebookBBrosemer sharedInstance].wallPostController != nil){
		[[FacebookBBrosemer sharedInstance].wallPostController sendUpdate];
	}
}

+(void)login{
	[[FacebookBBrosemer sharedInstance] authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) 
													andExtendedPermissions:[FacebookBBrosemer sharedInstance].permissions]; 
}
+(void)setDebugMode:(BOOL)mode{
	debugMode = mode;
}
+(NSMutableArray *)getArray{
	if(debugMode)
		NSLog(@"ARRAY GET %@",[FacebookBBrosemer sharedInstance].facebookPostsArray);
	return [FacebookBBrosemer sharedInstance].facebookPostsArray;
}

+(NSMutableArray *)getNewestFirstArray{
	return [FacebookBBrosemer sharedInstance].newestFirstArray;
}




+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andTo:(NSString *)userName{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return 0;
	}else{
		[NSThread detachNewThreadSelector:@selector(presentProgressDelegate) 
								 toTarget:self 
							   withObject:nil];	
		[NSThread sleepForTimeInterval:2.0];
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		[variables setObject:link forKey:@"link"];
		[variables setObject:title forKey:@"name"];
		FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:[NSString stringWithFormat:@"%@/feed",userName] withPostVars:variables];
		return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
		
	}
}

+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andPictureURL:(NSString *)pictureURL andTo:(NSString *)userName{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return 0;
	}else{
		[NSThread detachNewThreadSelector:@selector(presentProgressDelegate) 
								 toTarget:self 
							   withObject:nil];	
		[NSThread sleepForTimeInterval:2.0];
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		[variables setObject:link forKey:@"link"];
		[variables setObject:title forKey:@"name"];
		[variables setObject:pictureURL forKey:@"picture"];
		FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:[NSString stringWithFormat:@"%@/feed",userName] withPostVars:variables];
		return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
	}
}



+(void)userPostComment:(NSString *)message andFacebookItem:(FacebookItem *)facebookItem{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return;
	}else{
		[NSThread detachNewThreadSelector:@selector(presentProgressDelegate) 
								 toTarget:self 
							   withObject:nil];	
		[NSThread sleepForTimeInterval:2.0];
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		
		[[FacebookBBrosemer sharedInstance] doGraphPost:[NSString stringWithFormat:@"%@/comments",facebookItem.itemId]
										   withPostVars:variables];
	}
}

+(NSArray *)getUserFriends{
	if([FacebookBBrosemer sharedInstance].friendList == nil){
		[FacebookBBrosemer sharedInstance].friendList = [[FacebookFriends alloc] init];
		[[FacebookBBrosemer sharedInstance].friendList refreshFriends];
	}
	return ((FacebookFriends *)[FacebookBBrosemer sharedInstance].friendList).facebookFriendArray;	
}



+(int)applicationPostLink:(NSString *)appId andMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	return 0;
}
+(int)bothPostLink:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	return 0;
}

+(int)userPostPicture:(UIImage *)image andMessage:(NSString *)message{
	return 0;
}
+(int)applicationPostPicture:(UIImage *)image andMessage:(NSString *)message{
	return 0;
}
//Fast Fetch
+(FacebookItem *)getPostFromPID:(int)pid{
	
}
+(NSString *)deletePostPID:(int)pid{
	
}

//Slow Fetch If Information Lost
+(FacebookItem *)getPostFromStoryTitle:(NSString *)title{
	
}
+(FacebookItem *)getPostFromStoryLink:(NSString *)link{
	
}


//Others Not Stored In facebookPostsArray
+(NSArray *)searchUserPostsWithString:(NSString *)searchString{
	
}
+(NSArray *)searchApplicationPostsWithString:(NSString *)searchString{
	
}
+(void)getUserPic{
	if([FacebookBBrosemer sharedInstance].meUser == nil){
		[FacebookBBrosemer sharedInstance].meUser = [[FacebookUser alloc] init];
		[FacebookBBrosemer sharedInstance].meUser.facebookUserId = [NSString stringWithFormat:@"me"];
		[FacebookBBrosemer sharedInstance].meUser.facebookUserImageURL = [NSString stringWithFormat:@"me"];
		[[FacebookBBrosemer sharedInstance] userImageAsyc];
	}
}
+(UIImage *)getUserImage{
	return ((FacebookUser *)[FacebookBBrosemer sharedInstance].meUser).facebookUserImage;
}

+(FacebookUser *)getMeUser{
	return [FacebookBBrosemer sharedInstance].meUser;
}

//Present Prebuilt Post Controller
+(NSString *)presentModalUserPostControllerFromUPID:(int)upid{
	
}
+(NSString *)presentModalApplicationPostControllerFromAPID:(int)apid{
	
}
//Presents All Posts From User and Application
+(NSString *)presentModalAllPostControllerFromUPID:(int)upid andAPID:(int)apid{
	
}




+(void)appEnteredBackground{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[FacebookBBrosemer sharedInstance].facebookPostsArray] 
											  forKey:@"facebookPostsArray"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[FacebookBBrosemer sharedInstance].newestFirstArray] 
											  forKey:@"newestFirst"];
	if(debugMode)
		NSLog(@"Facebook Array %@",[FacebookBBrosemer sharedInstance].facebookPostsArray);
	[[NSUserDefaults standardUserDefaults] synchronize];
}
+(void)appWillQuit{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[FacebookBBrosemer sharedInstance].facebookPostsArray] 
											  forKey:@"facebookPostsArray"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[FacebookBBrosemer sharedInstance].newestFirstArray] 
											  forKey:@"newestFirst"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)facebookInitWithArray:(NSArray *)facebookArray{
	[FacebookBBrosemer sharedInstance].facebookPostsArray = [NSMutableArray arrayWithArray:facebookArray];
}



+(NSString *)getAccessTokenClass{
	return [FacebookBBrosemer sharedInstance].accessToken;
}

//GUI Method
+(void)presentFacebookTableModal:(BOOL)animated andCurrentViewController:(UIViewController *)viewController{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if([FacebookBBrosemer sharedInstance].iPadView == nil){
			[FacebookBBrosemer sharedInstance].iPadView = [[iPadTableViewController alloc] init];
		}
	}else{
		if([FacebookBBrosemer sharedInstance].navController == nil){
			if([FacebookBBrosemer sharedInstance].facebookTable == nil){
				[FacebookBBrosemer sharedInstance].facebookTable = [[FacebookHashTableNavigationController alloc] init];
			}
			[FacebookBBrosemer sharedInstance].navController = [[UINavigationController alloc] 
																initWithRootViewController:[FacebookBBrosemer sharedInstance].facebookTable];
		}
		if([FacebookBBrosemer sharedInstance].facebookTable == nil){
			[[FacebookBBrosemer sharedInstance].navController release];
			[FacebookBBrosemer sharedInstance].facebookTable = [[FacebookHashTableNavigationController alloc] init];
			[FacebookBBrosemer sharedInstance].navController = [[UINavigationController alloc] 
																initWithRootViewController:[FacebookBBrosemer sharedInstance].facebookTable];
		}
		[FacebookBBrosemer sharedInstance].navController.navigationBarHidden = YES;
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad code
		//[FacebookBBrosemer sharedInstance].iPadView.modalPresentationStyle = UIModalPresentationFullScreen;
		//[FacebookBBrosemer sharedInstance].iPadView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].iPadView animated:YES];
	} else {
		// iPhone or iPod Touch code
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].navController animated:animated];
	}
}

+(void)presentFacebookChatController:(BOOL)animated
			andCurrentViewController:(UIViewController *)viewController{
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if([FacebookBBrosemer sharedInstance].rootViewController == nil){
			[FacebookBBrosemer sharedInstance].rootViewController = [[RootViewController alloc] init];
		}
	}else{
		if([FacebookBBrosemer sharedInstance].rootViewController == nil){
			[FacebookBBrosemer sharedInstance].rootViewController = [[RootViewController alloc] init];
			UINavigationController *navController = [[[UINavigationController alloc] 
																initWithRootViewController:[FacebookBBrosemer sharedInstance].rootViewController] autorelease];
			[viewController presentModalViewController:navController animated:animated];

		}else{
			UINavigationController *navController = [[[UINavigationController alloc] 
													  initWithRootViewController:[FacebookBBrosemer sharedInstance].rootViewController] autorelease];
			[viewController presentModalViewController:navController animated:animated];
		}
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad code
		//[FacebookBBrosemer sharedInstance].iPadView.modalPresentationStyle = UIModalPresentationFullScreen;
		//[FacebookBBrosemer sharedInstance].iPadView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].iPadView animated:YES];
	} else {
		// iPhone or iPod Touch code
		//[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].navController animated:animated];
	}
	
}

+(void)presentFacebookMessageControllerModal:(BOOL)animated withTitle:(NSString *)title withLink:(NSString *)linkURL
					andCurrentViewController:(UIViewController *)viewController{
	if([FacebookBBrosemer sharedInstance].accessToken != nil){
	if([FacebookBBrosemer sharedInstance].friendList == nil){
		if([FacebookBBrosemer sharedInstance].meUser == nil){
			[FacebookBBrosemer getUserPic];
		}
		[FacebookBBrosemer sharedInstance].friendList = [[FacebookFriends alloc] init];
		[[FacebookBBrosemer sharedInstance].friendList refreshFriends];
	}
	if([FacebookBBrosemer sharedInstance].wallPostController == nil){
		[FacebookBBrosemer sharedInstance].wallPostController = [[FacebookWallPostController alloc] init];			
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad code
		
		[FacebookBBrosemer sharedInstance].wallPostController.modalPresentationStyle = UIModalPresentationFullScreen;
		[FacebookBBrosemer sharedInstance].wallPostController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:YES];
		//[FacebookBBrosemer sharedInstance].wallPostController.view.superview.frame = CGRectMake(0,-100,245,320);
		//[FacebookBBrosemer sharedInstance].wallPostController.view.superview.center = viewController.view.center;
		//[FacebookBBrosemer sharedInstance].wallPostController.view.superview.center = viewController.view.center;
		[viewController shouldAutorotateToInterfaceOrientation:YES]; 
		//[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:animated];
		
	} else {
		// iPhone or iPod Touch code
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:animated];
	}
	
	
	
	[FacebookBBrosemer sharedInstance].wallPostController.storyURL = [NSString stringWithString:linkURL];
	[FacebookBBrosemer sharedInstance].wallPostController.imageURL = nil;
	[FacebookBBrosemer sharedInstance].wallPostController.storyTitle = [NSString stringWithString:title];
	}else{
		[self login];
	}
	
}


+(void)presentFacebookMessageControllerModal:(BOOL)animated withTitle:(NSString *)title withLink:(NSString *)linkURL withImageURL:(NSString *)imageURL
					andCurrentViewController:(UIViewController *)viewController{
	if([FacebookBBrosemer sharedInstance].accessToken != nil){
	if([FacebookBBrosemer sharedInstance].friendList == nil){
		if([FacebookBBrosemer sharedInstance].meUser == nil){
			[FacebookBBrosemer getUserPic];
		}
		[FacebookBBrosemer sharedInstance].friendList = [[FacebookFriends alloc] init];
		[[FacebookBBrosemer sharedInstance].friendList refreshFriends];
	}
	if([FacebookBBrosemer sharedInstance].wallPostController == nil){
		[FacebookBBrosemer sharedInstance].wallPostController = [[FacebookWallPostController alloc] init];			
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad code
		
		[FacebookBBrosemer sharedInstance].wallPostController.modalPresentationStyle = UIModalPresentationFullScreen;
		[FacebookBBrosemer sharedInstance].wallPostController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:YES];
		//[FacebookBBrosemer sharedInstance].wallPostController.view.superview.frame = CGRectMake(0, 0,245,320);
		//[FacebookBBrosemer sharedInstance].wallPostController.view.superview.center = viewController.view.center;
		
		//[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:animated];
		
	} else {
		// iPhone or iPod Touch code
		[viewController presentModalViewController:[FacebookBBrosemer sharedInstance].wallPostController animated:animated];
	}
	
	[FacebookBBrosemer sharedInstance].wallPostController.storyURL = [NSString stringWithString:linkURL];
	[FacebookBBrosemer sharedInstance].wallPostController.imageURL = [NSString stringWithString:imageURL];
	[FacebookBBrosemer sharedInstance].wallPostController.storyTitle = [NSString stringWithString:title];
	}else{
		[self login];
	}
	
}

+(MutableChatDictionary *)mutableChatDictionary{
	return [[FacebookBBrosemer sharedInstance] mutableChatDictionary];
}

+(XMPPStream *)xmppStream{
	return [[FacebookBBrosemer sharedInstance] xmppStream];
}

+(XMPPRoster *)xmppRoster{
	return [[FacebookBBrosemer sharedInstance] xmppRoster];
}
+(XMPPRosterCoreDataStorage *)xmppRosterStorage{
	return  [[FacebookBBrosemer sharedInstance] xmppRosterStorage];
}
 

+(void)appLaunchedWithFacebookClientId:(NSString *)facebookClientId andPermissions:(NSString*)perm{
	
	
	// You may need to alter these settings depending on the server you're connecting to
	//allowSelfSignedCertificates = NO;
	//allowSSLHostNameMismatch = NO;
	[[FacebookBBrosemer sharedInstance] signInChat];
	NSData *testValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookPostsArray"] retain];
	NSData *testValue2 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestFirst"] retain];
	if (testValue == nil){
		[FacebookBBrosemer sharedInstance].facebookPostsArray = [[NSMutableArray alloc]init];
		[FacebookBBrosemer sharedInstance].newestFirstArray = [[NSMutableArray alloc]init];
	}else{
		NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:testValue];
		NSArray *oldSavedArray2 = [NSKeyedUnarchiver unarchiveObjectWithData:testValue2];
		[FacebookBBrosemer sharedInstance].facebookPostsArray = [[NSMutableArray alloc]initWithArray:oldSavedArray];
		[FacebookBBrosemer sharedInstance].newestFirstArray = [[NSMutableArray alloc]initWithArray:oldSavedArray2];
		if(debugMode)
			NSLog(@"Facebook Array %@",[FacebookBBrosemer sharedInstance].facebookPostsArray);
	}
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]!=nil){
		[FacebookBBrosemer sharedInstance].accessToken = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]];
		[FacebookBBrosemer sharedInstance].globalLogin = YES;
	}
	[testValue release];
	
	[[FacebookBBrosemer sharedInstance] setFbClientID:facebookClientId];
	[FacebookBBrosemer sharedInstance].permissions = perm;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[navController release];
	[facebookTable release];
	[permissions release];
	// Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
	[super dealloc];
	[navController release];
	[facebookTable release];
	[permissions release];
}









@end


@implementation FacebookBBrosemer (UIDeprecated)

//App Delegate Methods
+(void)appLaunched{
	NSData *testValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookPostsArray"] retain];
	NSData *testValue2 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"newestFirst"] retain];
	if (testValue == nil){
		[FacebookBBrosemer sharedInstance].facebookPostsArray = [[NSMutableArray alloc]init];
		[FacebookBBrosemer sharedInstance].newestFirstArray = [[NSMutableArray alloc]init];
	}else{
		NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:testValue];
		NSArray *oldSavedArray2 = [NSKeyedUnarchiver unarchiveObjectWithData:testValue2];
		[FacebookBBrosemer sharedInstance].facebookPostsArray = [[NSMutableArray alloc]initWithArray:oldSavedArray];
		[FacebookBBrosemer sharedInstance].newestFirstArray = [[NSMutableArray alloc]initWithArray:oldSavedArray2];
		[FacebookBBrosemer sharedInstance].accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
		if(debugMode)
			NSLog(@"Facebook Array %@",[FacebookBBrosemer sharedInstance].facebookPostsArray);
	}
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]!=nil){
		[FacebookBBrosemer sharedInstance].accessToken = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]];
		[FacebookBBrosemer sharedInstance].globalLogin = YES;
	}
	[testValue release];
}


//Store With Post Data For Faster Fetching
+(int)userPostLink:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return 0;
	}
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
	[variables setObject:message forKey:@"message"];
 	[variables setObject:link forKey:@"link"];
 	[variables setObject:title forKey:@"name"];
	FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:@"me/feed" withPostVars:variables];
	return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
}



+(void)initWithFacebookClientId:(NSString *)facebookClientId{
	[[FacebookBBrosemer sharedInstance] setFbClientID:facebookClientId];
}
+(void)initWithPermissions:(NSString *)perm{
	[FacebookBBrosemer sharedInstance].permissions = perm;
}


+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return 0;
	}else{
		[NSThread detachNewThreadSelector:@selector(presentProgressDelegate) 
								 toTarget:self 
							   withObject:nil];	
		[NSThread sleepForTimeInterval:2.0];
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		[variables setObject:link forKey:@"link"];
		[variables setObject:title forKey:@"name"];
		FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:@"me/feed" withPostVars:variables];
		return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
		
	}
}


+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andPictureURL:(NSString *)pictureURL{
	if([FacebookBBrosemer sharedInstance].globalLogin == NO){
		[self login];
		UIAlertView *tempAlert = [[UIAlertView alloc] initWithTitle:@"Logging In First" 
															message:@"First the App Had To Log You Into Facebook, If Successful You Can Now Post" delegate:self 
												  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[tempAlert show];
		[tempAlert release];
		return 0;
	}else{
		[NSThread detachNewThreadSelector:@selector(presentProgressDelegate) 
								 toTarget:self 
							   withObject:nil];	
		[NSThread sleepForTimeInterval:2.0];
		NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
		[variables setObject:message forKey:@"message"];
		[variables setObject:link forKey:@"link"];
		[variables setObject:title forKey:@"name"];
		[variables setObject:pictureURL forKey:@"picture"];
		FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:@"me/feed" withPostVars:variables];
		return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
	}
}


@end

