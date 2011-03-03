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
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "FacebookLoginHandler.h"
typedef enum {
    UserTypeMe,
    UserTypeFriend,
    UserTypeFriendOfFriend,
} FacebookUserType;

@protocol FacebookUserDelegate <NSObject>
@optional
-(void)userUpadated;
-(void)userItemUpadated;
@end


@interface FacebookUser : NSObject <ASICacheDelegate,ASIHTTPRequestDelegate,ASIProgressDelegate> {
	NSString *facebookUserId;
    NSString *itemId;
    
	NSString *facebookUserName;
	UIImage *facebookUserImageSmall;
    UIImage *facebookUserImageNormal;
    UIImage *facebookUserImageLarge;
	NSString *facebookUserImageURL;
    
    NSString *facebookUserUpdatedTime;
    NSDate *facebookUserUpdatedDateTime;
    
    
    NSString *facebookUserBirthday;
    NSString *facebookUserEmail;
    NSString *facebookUserFirstName;
    NSString *facebookUserGender;
    NSString *facebookUserHometown;
    NSString *facebookUserInterestedIn;
    NSString *facebookUserLastName;
    NSString *facebookUserLink;
    NSString *facebookUserPolitical;
    NSString *facebookUserQuotes;
    NSString *facebookUserRelationshipStatus;
    
    NSArray *facebookUserWork;
    NSArray *facebookUserLanguages;
    NSArray *facebookUserEducation;
    

    
    //An array of facebook userID strings
    NSMutableArray *facebookUserFriends;
    //An array of facebook itemID strings
    NSMutableArray *facebookUserWall;
    //An array of strings ... for now 
    NSMutableArray *facebookUserLikes;
    //An array of strings ... for now 
    NSMutableArray *facebookUserMovies;
    //An array of strings ... for now 
    NSMutableArray *facebookUserMusic;
    //An array of strings ... for now 
    NSMutableArray *facebookUserBooks;
    //An array of strings ... for now 
    NSMutableArray *facebookUserNotes;
    //An array of facebook item id strings
    NSMutableArray *facebookUserPhotosTaggedIn;
    //An array of something need to look at the album output // will come back to this one at a a later time
    NSMutableArray *facebookUserPhotoAlbums;
    
	id delegate;
}
@property(nonatomic,retain)NSMutableArray *facebookUserPhotosTaggedIn;
@property(nonatomic,retain)NSMutableArray *facebookUserWall;


@property (nonatomic, retain) NSString *facebookUserId;
@property (nonatomic, retain) NSString *itemId;


@property (nonatomic, retain)NSString *facebookUserBirthday;
@property (nonatomic, retain)NSString *facebookUserEmail;
@property (nonatomic, retain)NSString *facebookUserFirstName;
@property (nonatomic, retain)NSString *facebookUserGender;
@property (nonatomic, retain)NSString *facebookUserHometown;
@property (nonatomic, retain)NSString *facebookUserInterestedIn;
@property (nonatomic, retain)NSString *facebookUserLastName;
@property (nonatomic, retain)NSString *facebookUserLink;
@property (nonatomic, retain)NSString *facebookUserPolitical;
@property (nonatomic, retain)NSString *facebookUserQuotes;
@property (nonatomic, retain)NSString *facebookUserRelationshipStatus;

@property (nonatomic, retain)NSArray *facebookUserWork;
@property (nonatomic, retain)NSArray *facebookUserLanguages;
@property (nonatomic, retain)NSArray *facebookUserEducation;



@property (nonatomic, retain) NSString *facebookUserUpdatedTime;
@property (nonatomic, retain) NSDate *facebookUserUpdatedDateTime;
@property (nonatomic, retain) NSString *facebookUserName;
@property (nonatomic, retain) UIImage *facebookUserImageSmall;
@property (nonatomic, retain) UIImage *facebookUserImageNormal;
@property (nonatomic, retain) UIImage *facebookUserImageLarge;
@property (nonatomic, retain) NSString *facebookUserImageURL;
@property (nonatomic, assign) id <FacebookUserDelegate> delegate;
- (id)init;

- (NSArray *)keyPaths;
- (void)startObservingObject:(id)thisObject;
- (void)stopObservingObject:(id)thisObject;
-(void)setFacebookUserType:(FacebookUserType)type;
-(FacebookUserType)getFacebookUserType;

-(void)createFacebookUser:(NSOperationQueue *)queue andID:(NSString *)userId andGather:(BOOL)gather;


//Photo Centric
-(void)gatherUserAlbums;
-(void)loadImagesOfUserFromFacebook:(NSOperationQueue *)queue;
-(void)parseFacebookUsersTaggedData;
-(void)setUserTaggedInID;
-(void)getBackgroundItemImageSmall:(NSOperationQueue *)queue;
-(void)getBackgroundItemImageMedium:(NSOperationQueue *)queue;
-(void)getBackgroundItemImageLarge:(NSOperationQueue *)queue;
///////////////////////////////////////////////

//MISC
-(void)getFriends;
-(void)gatherUserWall:(NSOperationQueue *)queue;
-(void)gatherUserLikes;
-(void)gtherUserMovies;
-(void)gatherUserMusic;
-(void)gatherUserBooks;
-(void)gatherUserNotes;
-(void)gatherUserEvents;
-(void)gatherUserGroups;
-(void)gatherUserCheckins;
-(void)gatherUserTelevision;
-(void)gatherUserInterests;
-(void)gatherUserActivities;
-(void)gatherUserTaggedInVideos;
-(void)gatherUserVideoUploads;
/////////////////////////////////////////



@end
