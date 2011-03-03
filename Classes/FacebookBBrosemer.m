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
#import "FacebookLoginHandler.h"
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
#import "iPhoneFacebookProfileController.h"







@interface FacebookBBrosemer (private)
- (void)success:(NSString *)success;
- (int)createFacebookItem:(NSString *)ID;
- (void)setFbClientID:(NSString *)fbcid;
- (BOOL)connectedToNetwork;
- (void)errorWithString:(NSString *)errorString;
+ (FacebookBBrosemer*)sharedInstance;
- (NSString *)doGraphGet:(NSString *)action;
- (void)authenticateUserWithCallbackObject:(id)anObject andSelector:(SEL)selector andExtendedPermissions:(NSString *)extended_permissions;

-(void)loginInternal;
@end

@implementation FacebookBBrosemer (private)



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

- (void)goOnline{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline{
	NSXMLElement *presence = [NSXMLElement elementWithName:@"presence"];
	[presence addAttributeWithName:@"type" stringValue:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
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

- (void)xmppStreamDidSecure:(XMPPStream *)sender{
	//NSLog(@"---------- xmppStreamDidSecure: ----------");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
	//NSLog(@"---------- xmppStreamDidConnect: ----------");
	
	isOpen = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
	//NSLog(@"---------- xmppStreamDidAuthenticate: ----------");
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
	//NSLog(@"---------- xmppStream:didNotAuthenticate: ----------");
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
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
	
}

-(void)done{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:2.0];
 	alertView.frame = CGRectMake(0, -44,320, 44);
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:alertView cache:YES];
	[UIView commitAnimations];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
	//NSLog(@"---------- xmppStream:didReceivePresence: ----------");
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error{
	//NSLog(@"---------- xmppStream:didReceiveError: ----------");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender{
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
@synthesize navController,facebookTable,iPadView;
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
	[FacebookLoginHandler loginUser]; 
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





/*
+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andTo:(NSString *)userName{
	if([FacebookLoginHandler loginUser]){
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
	if([FacebookLoginHandler loginUser]){
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

*/

+(void)userPostComment:(NSString *)message andFacebookItem:(FacebookItem *)facebookItem{
	if([FacebookLoginHandler loginUser]){
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


+(void)presentFacebookUserProfileModal:(BOOL)animated andUserId:(NSString *)userId andCurrentViewController:(UIViewController *)viewController{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        iPadFacebookProfileController *viewController2 = [[iPadFacebookProfileController alloc] init];
        viewController2.thisUser = [FacebookItemHandler createUser:userId andGather:YES];
        viewController2.modalPresentationStyle = UIModalPresentationFormSheet;
        viewController2.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [viewController presentModalViewController:viewController2 animated: YES];
    }else{
        iPhoneFacebookProfileController *viewController2 = [[iPhoneFacebookProfileController alloc] init];
        viewController2.thisUser = [FacebookItemHandler createUser:userId andGather:YES];
        viewController2.modalPresentationStyle = UIModalPresentationFormSheet;
        viewController2.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [viewController presentModalViewController:viewController2 animated: YES];  
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
    [FacebookItemHandler sharedInstance].facebookItemObjects = [[NSMutableArray alloc] init ];
    [FacebookItemHandler sharedInstance].facebookUsers = [[NSMutableArray alloc] init ];
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
	
	[testValue release];
	
	//[[FacebookBBrosemer sharedInstance] setFbClientID:facebookClientId];
	//[FacebookBBrosemer sharedInstance].permissions = perm;
    [FacebookLoginHandler appLaunchedWithPermissions:perm andFacebookClientID:facebookClientId];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[navController release];
	[facebookTable release];
	//[permissions release];
	// Release any cached data, images, etc that aren't in use.
}

-(void)dealloc{
	[super dealloc];
	[navController release];
	[facebookTable release];
	//[permissions release];
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
		//[FacebookBBrosemer sharedInstance].globalLogin = YES;
	}
	[testValue release];
}

/*
//Store With Post Data For Faster Fetching
+(int)userPostLink:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	if([FacebookLoginHandler loginUser]){
	NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithCapacity:3];
	[variables setObject:message forKey:@"message"];
 	[variables setObject:link forKey:@"link"];
 	[variables setObject:title forKey:@"name"];
	FacebookGraphDataResponse *fb_graph_response = [[FacebookBBrosemer sharedInstance] doGraphPost:@"me/feed" withPostVars:variables];
	return [[FacebookBBrosemer sharedInstance] parseFacebookPost:fb_graph_response];
    }
}





+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link{
	if([FacebookLoginHandler loginUser]){
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
	if([FacebookLoginHandler loginUser]){
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
*/

@end

