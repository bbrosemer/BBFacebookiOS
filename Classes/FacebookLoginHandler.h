//
//  FacebookLoginHandler.h
//  FacebookStaticTest
//
//  Created by Brandyn on 2/16/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    FacebookLoggedIn = 1,
    FacebookLoggedOut = 0
}FacebookLoginStatus;



@interface FacebookLoginHandler : NSObject <UIWebViewDelegate> {
    FacebookLoginStatus facebookLoginStatus;
    
    
    BOOL loggedIn;
	BOOL showLoad;
	BOOL globalLogin;
	UIAlertView *baseAlert2;
	NSString *facebookClientID;
	NSString *redirectUri;
	NSString *accessToken;
	NSString *permissions;
	UIWebView *webView;
    
    id callbackObject;
	SEL callbackSelector;

}
@property (nonatomic, retain) NSString *facebookClientID;
@property (nonatomic, retain) NSString *redirectUri;
@property (nonatomic, retain) NSString *permissions;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, assign, getter=is_isLoggedIn) BOOL loggedIn;
@property (nonatomic, assign, getter=is_isGlobalLogin) BOOL globalLogin;

+(BOOL)loginUser;
+(void)appLaunchedWithPermissions:(NSString *)permissions andFacebookClientID:(NSString *)facebookClientID;
+(NSString *)getAccessToken;

@end



@interface FacebookLoginHandler  (private)
+(void)fbGraphCallback:(id)sender;
- (void)setFbClientID:(NSString *)fbcid;
-(void)authenticateUserWithCallbackObject:(id)anObject andSelector:(SEL)selector andExtendedPermissions:(NSString *)extended_permissions;
//Facebook Login Status -- 
-(void)setFacebookLoginStatus:(FacebookLoginStatus)status;
-(BOOL)getFacebookLoginStatus;

@end
