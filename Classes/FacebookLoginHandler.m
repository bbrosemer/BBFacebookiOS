//
//  FacebookLoginHandler.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/16/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "FacebookLoginHandler.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>


@implementation FacebookLoginHandler (private)

+(FacebookLoginHandler*)sharedInstance {
	static FacebookLoginHandler *facebookLogin = nil;
	if (facebookLogin == nil)
	{
		@synchronized(self) {
			if (facebookLogin == nil)
				facebookLogin = [[FacebookLoginHandler alloc] init];
		}
	}
	
	return facebookLogin;
}

-(void)setAccessToken:(NSString *)textValue
{
    if (textValue != accessToken)
    {
        [textValue retain];
        [accessToken release];
        accessToken = textValue;
        [[FacebookLoginHandler sharedInstance] setFacebookLoginStatus:FacebookLoggedIn];
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
	
}

-(void)success:(NSString *)success{

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


- (void)setFbClientID:(NSString *)fbcid{
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

+(void)fbGraphCallback:(id)sender{
    NSLog(@"Logged In");
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView{
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
	NSLog(@"URL STRING TEST %@",url_string);
	//looking for "access_token="
	NSRange access_token_range = [url_string rangeOfString:@"access_token="];
	
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
		[FacebookLoginHandler sharedInstance].accessToken = [NSString stringWithString:access_token];
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





-(BOOL)getFacebookLoginStatus{
    if(facebookLoginStatus == FacebookLoggedIn){
        return TRUE;
    }
    return FALSE;
}

-(void)setFacebookLoginStatus:(FacebookLoginStatus)status{
    facebookLoginStatus = status;
}

-(NSString *)getPermissions{
    return permissions;
}

@end

@implementation FacebookLoginHandler
@synthesize accessToken,facebookClientID,globalLogin,loggedIn,permissions,redirectUri;

+(BOOL)loginUser{
    if([[FacebookLoginHandler sharedInstance] getFacebookLoginStatus]){
        return TRUE;
    }else{
        [[FacebookLoginHandler sharedInstance] authenticateUserWithCallbackObject:self andSelector:@selector(fbGraphCallback:) 
                                                        andExtendedPermissions:[[FacebookLoginHandler sharedInstance] getPermissions]]; 
    }
    return FALSE;
}

+(void)appLaunchedWithPermissions:(NSString *)permissions andFacebookClientID:(NSString *)facebookClientID{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]!=nil){
		[[FacebookLoginHandler sharedInstance] setAccessToken:[NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]];
	}
    [FacebookLoginHandler sharedInstance].permissions = permissions;
    [[FacebookLoginHandler sharedInstance] setFbClientID:facebookClientID]; 
    
}

+(NSString *)getAccessToken{
    return [[FacebookLoginHandler sharedInstance] getAccessToken];
}

@end
