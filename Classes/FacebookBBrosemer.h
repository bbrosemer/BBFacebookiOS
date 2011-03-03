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

#import <Foundation/Foundation.h>


#import"SBJSON.h"
#import"FacebookItem.h"
#import"FacebookWallPostController.h"
#import"FacebookFriends.h"
#import"FacebookUser.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MutableChatDictionary.h"
#import "iPadFacebookProfileController.h"
@class XMPPStream;
@class XMPPRoster;
@class XMPPRosterCoreDataStorage;




@protocol FacebookDelegate <NSObject>
@optional
-(void)facebook;
@end

static BOOL debugMode;

@class FacebookHashTableNavigationController;
@class iPadTableViewController;
@class FacebookWallPostController;
@class RootViewController;

@interface FacebookBBrosemer : NSObject <UIWebViewDelegate> {
	NSMutableArray *facebookPostsArray,*newestFirstArray;
	FacebookFriends *friendsList;
	UIAlertView *baseAlert2;
	NSString *accessToken;
	UIWebView *webView;
	UIProgressView *progressView;
	UINavigationController *navController;
	UIAlertView *progressAlert;
	FacebookHashTableNavigationController *facebookTable;
	FacebookWallPostController *wallPostController;
	RootViewController *rootViewController;
	iPadTableViewController *iPadView;
	FacebookUser *meUser;
	id delegate;
	
	
	
	XMPPStream *xmppStream;
	XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
	
	NSString *password;
	
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isOpen;
	UIView *alertView;
	UILabel *alertLabel;
	UIWindow *window;
	UINavigationController *navigationController;
	MutableChatDictionary *chats;
}
@property (nonatomic, retain) NSMutableArray *facebookPostsArray,*newestFirstArray;
//@property (nonatomic, retain) NSString *facebookClientID;
//@property (nonatomic, retain) NSString *redirectUri;
//@property (nonatomic, retain) NSString *permissions;
@property (nonatomic, retain) FacebookFriends *friendList;
@property (nonatomic, retain) UIImage *userImage;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) FacebookHashTableNavigationController *facebookTable;
@property (nonatomic, retain) FacebookWallPostController *wallPostController;
@property (nonatomic, retain) iPadTableViewController *iPadView;
@property (nonatomic, retain) RootViewController *rootViewController;
@property (nonatomic, retain) FacebookUser *meUser;
//@property (nonatomic, assign, getter=is_isLoggedIn) BOOL loggedIn;
//@property (nonatomic, assign, getter=is_isGlobalLogin) BOOL globalLogin;
@property (nonatomic, assign) id <FacebookDelegate> delegate;
@property (nonatomic, assign) UIProgressView *progressView;
@property (nonatomic, assign) UIAlertView *progressAlert;
@property (nonatomic, retain) NSString *password;




@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
//////////////////////////////////////////
//LOGIN
+(void)login;
//////////////////////////////////////////


//////////////////////////////////////////
//User Actions
+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andTo:(NSString *)userName;
+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andPictureURL:(NSString *)pictureURL andTo:(NSString *)userName;
+(int)userPostPicture:(UIImage *)image andMessage:(NSString *)message andTo:(NSString *)userName;

+(void)userPostComment:(NSString *)message andFacebookItem:(FacebookItem *)facebookItem;

+(void *)getUserPic;
+(UIImage *)getUserImage;
+(NSArray *)getUserFriends;
//////////////////////////////////////////

//////////////////////////////////////////
//Facebook Application Actions
+(int)applicationPostLink:(NSString *)appId andMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link;
+(int)bothPostLink:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link;
+(int)applicationPostPicture:(UIImage *)image andMessage:(NSString *)message;
//////////////////////////////////////////

//////////////////////////////////////////
//Fast Fetch -> Store the returing int from a user or application post with the associated 
//item so that it can be accessed
//via binary search
+(FacebookItem *)getPostFromPID:(int)pid;
+(NSString *)deletePostPID:(int)pid;
//////////////////////////////////////////


//////////////////////////////////////////
//Slow Fetch If Information Lost
+(FacebookItem *)getPostFromStoryTitle:(NSString *)title;
+(FacebookItem *)getPostFromStoryLink:(NSString *)link;
//////////////////////////////////////////


//////////////////////////////////////////
//Present Prebuilt Post Controller Knowing the INT returned in the post
+(NSString *)presentModalUserPostControllerFromUPID:(int)upid;
+(NSString *)presentModalApplicationPostControllerFromAPID:(int)apid;
//Presents All Posts From User and Application
+(NSString *)presentModalAllPostControllerFromUPID:(int)upid andAPID:(int)apid;
///////////////////////////////////////////////

////////////////////////////////////
//Helper Mehtods
+(void)update;
+(void)friendsUpdated;
+(NSString *)getAccessTokenClass;
+(NSMutableArray *)getArray;
+(NSMutableArray *)getNewestFirstArray;
+(FacebookUser *)getMeUser;
////////////////////////////////////

///////////////////////////////////////////
//App Delegate Methods
+(void)appLaunchedWithFacebookClientId:(NSString *)facebookClientId andPermissions:(NSString*)perm;
+(void)appEnteredBackground;
+(void)appWillQuit;
+(void)facebookInitWithArray:(NSArray *)facebookArray;
///////////////////////////////////////////

///////////////////////////////////////////
//Pre-existing facebook item view controller
+(void)presentFacebookTableModal:(BOOL)animated 
		andCurrentViewController:(UIViewController *)viewController;

//Chat Controller
+(void)presentFacebookChatController:(BOOL)animated
			andCurrentViewController:(UIViewController *)viewController;

//Post Message Controller
+(void)presentFacebookMessageControllerModal:(BOOL)animated withTitle:(NSString *)title withLink:(NSString *)linkURL withImageURL:(NSString *)imageURL
					andCurrentViewController:(UIViewController *)viewController;
+(void)presentFacebookMessageControllerModal:(BOOL)animated withTitle:(NSString *)title withLink:(NSString *)linkURL
					andCurrentViewController:(UIViewController *)viewController;
///////////////////////////////////////////
+(void)presentFacebookUserProfileModal:(BOOL)animated andUserId:(NSString *)userId andCurrentViewController:(UIViewController *)viewController;


//////////////////////////////////////////
//Displyay Various NSLogMessages
+(void)setDebugMode:(BOOL)mode; 
//////////////////////////////////////////


//XMPP
+(XMPPStream *)xmppStream;
+(XMPPRoster *)xmppRoster;
+(XMPPRosterCoreDataStorage *)xmppRosterStorage;
+(MutableChatDictionary *)mutableChatDictionary;

@end

@interface FacebookBBrosemer (UIDeprecated)
//////////////////////////////////////////
//User post link ... Facebook will handle the picture based on the URL
+(int)userPostLink:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link;

// If User "likes the application" it will post to the application wall and Facebook 
//will handle the picture based on the URL
+(int)applicationPostLink:(NSString *)appId andMessage:(NSString *)message 
				 andTitle:(NSString *)title andLink:(NSString *)link;


//////////////////////////////////////////
//Set the Client ID
+(void)initWithFacebookClientId:(NSString *)facebookClientId; 
//////////////////////////////////////////

//////////////////////////////////////////
//Set the permissions
+(void)initWithPermissions:(NSString *)perm; 
//////////////////////////////////////////

//////////////////////////////////////////
//Must be called in the application did finish launching 
+(void)appLaunched;
//////////////////////////////////////////

+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link;
+(int)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andPictureURL:(NSString *)pictureURL;
+(int)userPostPicture:(UIImage *)image andMessage:(NSString *)message;



@end
