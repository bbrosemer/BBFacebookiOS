//
//  ImageHandler.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/12/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "ImageHandler.h"
#import "FacebookBBrosemer.h"
#import "SBJSON.h"




@interface NSMutableArray  (MyMutableArray)

-(NSMutableArray *)addObjectSorted:(FacebookItem *)object;

@end

@implementation NSMutableArray (MyMutableArray)





-(NSMutableArray *)addObjectSorted:(FacebookItem *)object{
    //NSLog(@"HMMM");
    NSNumberFormatter * form = [[NSNumberFormatter alloc] init];
    [form setNumberStyle:NSNumberFormatterNoStyle];
    
    NSNumber *tempNumber = [form numberFromString:[[self lastObject] itemId]];
    NSNumber *objectNumber = [form numberFromString:[object itemId]];
    
    if([tempNumber longLongValue] < [objectNumber longLongValue]){
       // NSLog(@"HMMM1");

		[self addObject:object];
		return self;
	}
    

                
    NSNumber *tempNumber3 = [form numberFromString:[[self objectAtIndex:0] itemId]];
	if([tempNumber3 longLongValue]>[objectNumber longLongValue]){
        //NSLog(@"HMMM2");

		[self insertObject:object atIndex:0];
		return self;
	}
	int max = [self count];
	int min = 0, mid;
	NSNumber *value = [form numberFromString:[object itemId]];
	
	//if we find our value, result = 1
	bool foundValue = false;
	
	//NSLog(@"we are checking our array for value %@",value);
    NSNumber *tempNumber2 = [form numberFromString:[[self objectAtIndex:0] itemId]];
	while (min<max ) {
		mid = (min+max)/2;
        tempNumber2 = [form numberFromString:[[self objectAtIndex:mid] itemId]];
		//NSLog(@"min = %i , max = %i, mid = %i",min,max,mid);
        if ([tempNumber2 longLongValue]==[value longLongValue]){
			foundValue = true; break;
		}else if ([value longLongValue] > [tempNumber2 longLongValue]){
			min = mid+1;
		}else{
			max = mid-1;
		}
	}if(foundValue==0){
		if([value longLongValue]<[tempNumber2 longLongValue]){
			//if(debugMode)
			//	NSLog(@"Add Object At Index %i",mid-1);
			//
			[self insertObject:object atIndex:mid-1];
		}else if([value longLongValue]>[tempNumber2 longLongValue]){
			//if(debugMode)
			//	NSLog(@"Add Object At Index %i",mid+1);
			
			[self insertObject:object atIndex:mid+1];
		}
	}
	return self;
}

@end









@implementation ImageHandler
@synthesize imagesByID,imagesByDateWithIDS;

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)addToDateArray:(FacebookItem *)object{

}

-(void)forceNormalImageItemURLFetch:(NSString *)normalImageItem{
    
    
}
-(void)forceThumbImageItemURLFetch:(NSString *)thumbImageItem{
    
}
-(void)forceLargeImageItemURLFetch:(NSString *)largeImageItem{
    
}

-(void)loadImagesOfMeFromFacebook{
    NSString *feedURL = [NSString stringWithFormat:@"https://graph.facebook.com/me/photos?"];
	if ([FacebookBBrosemer getAccessTokenClass] != nil) {
		//now that any variables have been appended, let's attach the access token....
		feedURL = [NSString stringWithFormat:@"%@access_token=%@&limit=500", feedURL, [FacebookBBrosemer getAccessTokenClass]];
	}else if([[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]!=nil){
		feedURL = [NSString stringWithFormat:@"%@access_token=%@", feedURL, 
					  [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]]];
	}
    
    
    

   feedURL = [feedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@" URL %@",feedURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:feedURL]];
    [request setDownloadProgressDelegate:self];
    [request startSynchronous];
    NSError *error = [request error];
    NSLog(@"Error %@",error);
    if (!error) {
        NSData *response = [request responseData];
        NSString *responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        SBJSON *parser = [[SBJSON alloc] init];
         
        NSDictionary  *tempDict = [parser objectWithString:responseString error:nil];
        NSArray *facebookResponse = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"data"]];
      //  NSLog(@"DEBUG %@",facebookResponse);
        for(int i = [facebookResponse count]-1; i >=0 ; i--){
            NSDictionary *dataDict = [[NSDictionary alloc] initWithDictionary:[facebookResponse objectAtIndex:i]];
            NSDictionary *creatorDictionary = [[NSDictionary alloc]initWithDictionary:[dataDict objectForKey:@"from"]];
            NSArray *imageArray = [[NSArray alloc] initWithArray:[dataDict objectForKey:@"images"]];
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
            if(imagesByID == nil){
                imagesByID = [[NSMutableArray alloc] init];
                imagesByDateWithIDS =[[NSMutableArray alloc] init];
                //[imagesByDateWithIDS addObjectDateSorted:newFacebookItem];
                [imagesByID addObject:newFacebookItem];
                [newFacebookItem release];
            }else{
                //[imagesByDateWithIDS addObjectDateSorted:newFacebookItem];
                [imagesByID addObjectSorted:newFacebookItem];
                [newFacebookItem release];
            }
        
        }
        [parser release];
        
        
        
        for(int i = 0; i<[imagesByID count];i++){
            NSLog(@"DONE");
            [((FacebookItem *)[imagesByID objectAtIndex:i]).facebookImageItem fetchThumbImage];
        }
        
    }

    
}



-(void)loadThumbnailsFromURLFACEBOOK:(NSString *)feedURL{
    if ([FacebookBBrosemer  getAccessTokenClass] != nil) {
        //now that any variables have been appended, let's attach the access token....
        feedURL = [NSString stringWithFormat:@"%@access_token=%@", feedURL, [FacebookBBrosemer getAccesToken]];
    }
    
    
    feedURL = [feedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:feedURL]];
    [request setDownloadProgressDelegate:self];
    [request startSynchronous];
    NSError *error = [request error];
    if(debugMode)
        NSLog(@"Error %@",error);
    if (!error) {
        NSData *response = [request responseData];
        NSString *responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        
        
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
           // newItem.facebookItemFrom.facebookUserId=[NSString stringWithString:[[facebook_response valueForKey:@"from"] valueForKey:@"id"]];
           // newItem.facebookItemFrom.facebookUserName=[NSString stringWithString:[[facebook_response valueForKey:@"from"] valueForKey:@"name"]];
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

        
        
    }

}




@end
