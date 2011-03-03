//
//  ImageItem.m
//  FacebookStaticTest
//
//  Created by Brandyn on 2/12/11.
//  Copyright 2011 bbrosemer.com. All rights reserved.
//

#import "ImageItem.h"
#import "FacebookItemHandler.h"


@implementation ImageItem
@synthesize imageItemCreationDate, imageItemCreator,imageItemLarge,imageItemLargeURL,imageItemNormal,imageItemNormalURL,imageItemPostID,imageItemTags,imageItemThumb,imageItemThumbURL,imageItemTitle,queue,imageViewThumb;//delegate;

-(id)initWithThumb:(NSString *)imageItemThumbURL{
    self = [super init];
    if (self) {
        self.imageItemThumbURL = [NSString stringWithString:imageItemThumbURL];
        self.imageItemThumb = [[UIImage alloc] init];
        self.imageViewThumb = [[[UIImageView alloc] init] retain];
    }
    return self;
}

-(id)initWithNormal:(NSURL *)imageItemNormalURL{
    self = [super init];
    if (self) {
        self.imageItemNormalURL = [[NSURL URLWithString:imageItemNormalURL]retain];
    }
    return self;
}
-(id)initWithLarge:(NSURL *)imageItemLargeURL{
    self = [super init];
    if (self) {
        self.imageItemLargeURL = [[NSURL URLWithString:imageItemLargeURL]retain];
    }
    return self;
}
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL{
    self = [super init];
    if (self) {
        self.imageItemThumbURL = [[NSURL URLWithString:imageItemThumbURL]retain];
        self.imageItemNormalURL = [[NSURL URLWithString:imageItemNormalURL]retain];
    }
    return self;
}
-(id)initWithThumb:(NSURL *)imageItemThumbURL andNormal:(NSURL *)imageItemNormalURL andLarge:(NSURL *)imageItemLargeURL{
    self = [super init];
    if (self) {
        self.imageItemThumbURL = [[NSURL URLWithString:imageItemThumbURL]retain];
        self.imageItemNormalURL = [[NSURL URLWithString:imageItemNormalURL]retain];
        self.imageItemLargeURL = [[NSURL URLWithString:imageItemLargeURL]retain];

    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.imageItemCreationDate forKey:@"imageItemCreationDate"];
    [aCoder encodeObject:self.imageItemCreator forKey:@"imageItemCreator"];
    [aCoder encodeObject:self.imageItemLarge forKey:@"imageItemLarge"];
    [aCoder encodeObject:self.imageItemLargeURL forKey:@"imageItemLargeURL"];
    [aCoder encodeObject:self.imageItemNormal forKey:@"imageItemNormal"];
    [aCoder encodeObject:self.imageItemNormalURL forKey:@"imageItemNormalURL"];
    [aCoder encodeObject:self.imageItemPostID forKey:@"imageItemPostID"];
    [aCoder encodeObject:self.imageItemTags forKey:@"imageItemTags"];
    [aCoder encodeObject:self.imageItemThumb forKey:@"imageItemThumb"];
    [aCoder encodeObject:self.imageItemThumbURL forKey:@"imageItemThumbURL"];
    [aCoder encodeObject:self.imageItemTitle forKey:@"imageItemTitle"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.imageItemCreationDate = [aDecoder decodeObjectForKey:@"imageItemCreationDate"];
        self.imageItemCreator = [aDecoder decodeObjectForKey:@"imageItemCreator"];
        self.imageItemLarge = [aDecoder decodeObjectForKey:@"imageItemLarge"];
        self.imageItemLargeURL = [aDecoder decodeObjectForKey:@"imageItemLargeURL"];
        self.imageItemNormal = [aDecoder decodeObjectForKey:@"imageItemNormal"];
        self.imageItemNormalURL = [aDecoder decodeObjectForKey:@"imageItemNormalURL"];
        self.imageItemPostID = [aDecoder decodeObjectForKey:@"imageItemPostID"];
        self.imageItemTags = [aDecoder decodeObjectForKey:@"imageItemTags"];
        self.imageItemThumb = [aDecoder decodeObjectForKey:@"imageItemThumb"];
        self.imageItemThumbURL = [aDecoder decodeObjectForKey:@"imageItemThumbURL"];
        self.imageItemTitle = [aDecoder decodeObjectForKey:@"imageItemTitle"];
    }
    return self; 
}


-(void)mainAttributes:(NSString *)creator andCreationDate:(NSString *)imageItemCreationDate andTitle:(NSString *)title{
        
}
/*
-(void)stopRequest{
    if(request != nil){
        [request cancel];
    }
}*/

-(void)fetchThumbImage{
  //  NSLog(@"Called");

    if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.imageItemThumbURL]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(thumbDone:)];
	[request setDidFailSelector:@selector(thumbWentWrong:)];
	[[self queue] addOperation:request];
}
-(void)fetchNormalImage{
    if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.imageItemNormalURL]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(normalDone:)];
	[request setDidFailSelector:@selector(normalWentWrong:)];
	[[self queue] addOperation:request];
}
-(void)fetchLargeImage{
    
}
-(void)fetchAllImages{
    
}
    
- (void)thumbDone:(ASIHTTPRequest *)request{
    self.imageItemThumb = [UIImage imageWithData:[request responseData]];
    self.imageViewThumb.image = self.imageItemThumb;
   // [self.imageViewThumb ];
}
    
- (void)thumbWentWrong:(ASIHTTPRequest *)request{
    //NSLog(@"failure");
}

- (void)normalDone:(ASIHTTPRequest *)request{
    NSData *response = [request responseData];
    self.imageItemNormal = [[UIImage alloc] initWithData:response];
    [response release];
}

- (void)normalWentWrong:(ASIHTTPRequest *)request{
    
}

-(BOOL)isLoadingThumb{
    if(self.imageItemThumbURL != nil){
        if(self.imageItemThumb != nil){
            return NO;
        }
    }
    return NO;
}

-(BOOL)isLoadingNormal{
    if(self.imageItemNormalURL != nil){
        if(self.imageItemNormal!= nil){
            return NO;
        }
    }
    return NO;
}

-(BOOL)isLoadingLarge{
    if(self.imageItemLargeURL != nil){
        if(self.imageItemLarge != nil){
            return NO;
        }
    }
    return NO;
}
    


@end
