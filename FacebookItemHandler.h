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
#import "FacebookItem.h"
#import "FacebookUser.h"
#import"FacebookGraphData.h"
#import"FacebookGraphDataResponse.h"
#import "FacebookLoginHandler.h"
#import "FacebookMutableArray.h"
//#import "ISO8601DateFormatter.h"

@protocol FacebookItemHandlerDelegate
@optional
-(void)facebookItemHandlerUpdated;
-(void)userWallLoaded;
@end

@interface FacebookItemHandler : NSObject {
    NSMutableArray *facebookItemObjects;
    NSMutableArray *facebookIDByDate;
    NSMutableArray *facebookUsers;
    NSMutableArray *facebookUserFriends;
    NSMutableArray *facebookPictureItemIDS;
    NSMutableArray *facebookStatusItemIDS;
    NSMutableArray *facebookVideoItemIDS;
    NSMutableArray *friendImportanceIDS;
    id <FacebookItemHandlerDelegate> delegate;
    //Array of facebook user id's who are your friends -> sorted 
    NSMutableArray *facebookFirends;
    
    FacebookUser *me;
    NSOperationQueue *queue;
}



@property(nonatomic,retain)NSMutableArray *facebookItemObjects;
@property(nonatomic,retain)NSMutableArray *facebookIDByDate;
@property(nonatomic,retain)NSMutableArray *facebookUsers;
@property(nonatomic,retain)NSMutableArray *facebookPictureItemIDS;
@property(nonatomic,retain)NSMutableArray *facebookStatusItemIDS;
@property(nonatomic,retain)NSMutableArray *facebookVideoItemIDS;
@property(nonatomic,retain)NSMutableArray *friendImportanceIDS;
@property(nonatomic,retain)NSOperationQueue *queue;
@property(nonatomic,retain)NSMutableArray *facebookUserFriends;
@property(nonatomic,retain)id delegate;

//Array of facebook user id's who are your friends -> sorted 
@property(nonatomic,retain)NSMutableArray *facebookFirends;
@property(nonatomic,retain)FacebookUser *me;

+(void)somethingUpdated;
+(void)wallDone;
+(void)thumbsDone;

//Defaults to highest NSQueuePriority
+(NSMutableArray *)getFacebookUsers;
+(void)getMeFriends;
+(NSMutableArray *)getItems;

+(void)getFacebookUserMe;

+(void)gatherNewsFeedUpdates:(FacebookItemType)facebookItemType;
+(NSString *)returnIDFromFacebookPost:(NSDictionary *)facebookItemDict;

+(FacebookUser *)returnFacebookUserFromID:(NSString *)userID;
+(FacebookUser *)createUser:(NSString *)userName andGather:(BOOL)gather;


+(void)userPostMessage:(NSString *)message andTitle:(NSString *)title andLink:(NSString *)link andTo:(NSString *)userName;

@end


@interface FacebookItemHandler  (private)

+(FacebookItemHandler*)sharedInstance;
-(void)insertFacebookItem:(FacebookItem *)facebookItem;
-(BOOL)doesFacebookItemExist:(FacebookItem*)facebookItem;
-(BOOL)shouldUpdateFacebookItem:(FacebookItem*)facebookItem;


//ME Oriented
//Inbox -> and Outbox -> and Updates
-(FacebookUser *)createFacebookUser:(NSString *)userId andGather:(BOOL)gather;
-(void)gatherUserMail;
-(void)gatherUserInbox;
-(void)gatherUserOutbox;
-(void)gatherUserUpdates;
///////////////////////////////

//User Helper Methods



-(void)autonamousBackgroundDataFetch;
//Autonamous Helper Methods
-(void)fetchUserProfile;
-(void)updateItem:(FacebookItem *)facebookItem;
-(FacebookItem *)getTopFacebookItemFromID:(NSString *)facebookID;


//Graph API 
- (FacebookGraphDataResponse *)doGraphGet:(NSString *)action withGetVars:(NSDictionary *)get_vars;
- (FacebookGraphDataResponse *)doGraphGetWithUrlString:(NSString *)url_string;
- (FacebookGraphDataResponse *)doGraphPost:(NSString *)action withPostVars:(NSDictionary *)post_vars;

@end

