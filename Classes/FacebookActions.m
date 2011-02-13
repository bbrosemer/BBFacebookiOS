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

#import "FacebookActions.h"


@implementation FacebookActions
@synthesize facebookActionCommentString;
@synthesize facebookActionLikeString;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        facebookActionCommentString = [[[NSString alloc]initWithString:@""] retain];
        facebookActionLikeString = [[[NSString alloc] initWithString:@""] retain];
    }
    return self;
}



//=========================================================== 
//  Keyed Archiving
//
//=========================================================== 
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.facebookActionCommentString forKey:@"facebookActionCommentString"];
    [encoder encodeObject:self.facebookActionLikeString forKey:@"facebookActionLikeString"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.facebookActionCommentString = [decoder decodeObjectForKey:@"facebookActionCommentString"];
        self.facebookActionLikeString = [decoder decodeObjectForKey:@"facebookActionLikeString"];
    }
    return self;
}

//=========================================================== 
// - (NSArray *)keyPaths
//
//=========================================================== 
- (NSArray *)keyPaths
{
    NSArray *result = [NSArray arrayWithObjects:
					   @"facebookActionCommentString",
					   @"facebookActionLikeString",
					   nil];
	
    return result;
}


//=========================================================== 
// - (void)startObservingObject:
//
//=========================================================== 
- (void)startObservingObject:(id)thisObject
{
    if ([thisObject respondsToSelector:@selector(keyPaths)]) {
        NSEnumerator *e = [[thisObject keyPaths] objectEnumerator];
        NSString *thisKey;
		
        while (thisKey = [e nextObject]) {
            [thisObject addObserver:self
						 forKeyPath:thisKey
							options:NSKeyValueObservingOptionOld
							context:NULL];
        }
    }
}
- (void)stopObservingObject:(id)thisObject
{
    if ([thisObject respondsToSelector:@selector(keyPaths)]) {
        NSEnumerator *e = [[thisObject keyPaths] objectEnumerator];
        NSString *thisKey;
		
        while (thisKey = [e nextObject]) {
            [thisObject removeObserver:self forKeyPath:thisKey];
        }
    }
}

//=========================================================== 
// - (NSString *)descriptionForKeyPaths
//
//=========================================================== 
- (NSString *)descriptionForKeyPaths 
{
    NSMutableString *desc = [NSMutableString string];
    NSEnumerator *e = [[self keyPaths] objectEnumerator];
    NSString *thisKey;
    [desc appendString:@"\n\n"];
	
    while (thisKey = [e nextObject]) {
        [desc appendFormat: @"%@: %@\n", thisKey, [self valueForKey:thisKey]];
    }
	
    return [NSString stringWithString:desc];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [facebookActionCommentString release];
    [facebookActionLikeString release];
	
    [super dealloc];
}




@end
