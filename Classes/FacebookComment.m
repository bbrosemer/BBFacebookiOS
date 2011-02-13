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

#import "FacebookComment.h"


@implementation FacebookComment
@synthesize commentItem;

//=========================================================== 
// - (id)init
//
//=========================================================== 
- (id)init
{
    self = [super init];
    if (self) {
        commentItem = [[[FacebookItem alloc]init] retain];
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
					   @"commentItem",
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
    [commentItem release];
	
    [super dealloc];
}






@end
