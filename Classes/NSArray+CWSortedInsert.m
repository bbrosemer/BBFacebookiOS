//
//  NSArray+CWSortedInsert.m
//
//  Created by Fredrik Olsson on 2008-03-21.
//  Copyright 2008 Jayway. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of the <organization> nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY <copyright holder> ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSArray+CWSortedInsert.h"
#import <objc/runtime.h>
#import "FacebookMutableArray.h"

@implementation NSArray (CWSortedInsert)

-(NSUInteger)indexForInsertingObject:(id)anObject sortedUsingfunction:(NSInteger (*)(id, id, void *))compare context:(void*)context;
{
  NSUInteger index = 0;
	NSUInteger topIndex = [self count];
  IMP objectAtIndexImp = [self methodForSelector:@selector(objectAtIndex:)];
  while (index < topIndex) {
    NSUInteger midIndex = (index + topIndex) / 2;
    id testObject = objectAtIndexImp(self, @selector(objectAtIndex:), midIndex);
    if (compare(anObject, testObject, context) < 0) {
      index = midIndex + 1;
    } else {
      topIndex = midIndex;
    }
  }
  return index;
}

static NSComparisonResult cw_SelectorCompare(id a, id b, void* aSelector) {
	return (NSComparisonResult)objc_msgSend(a, (SEL)aSelector, b);
}

-(NSUInteger)indexForInsertingObject:(id)anObject sortedUsingSelector:(SEL)aSelector;
{
	return [self indexForInsertingObject:anObject sortedUsingfunction:&cw_SelectorCompare context:aSelector];
}

static IMP cw_compareObjectToObjectImp = NULL;
static IMP cw_ascendingImp = NULL;

+(void)initialize;
{
  cw_compareObjectToObjectImp = [NSSortDescriptor instanceMethodForSelector:@selector(compareObject:toObject:)];
	cw_ascendingImp = [NSSortDescriptor instanceMethodForSelector:@selector(ascending)];
}

static NSComparisonResult cw_DescriptorCompare(id a, id b, void* descriptors) {
	NSComparisonResult result = NSOrderedSame;
  for (NSSortDescriptor* sortDescriptor in (NSArray*)descriptors) {
		result = (NSComparisonResult)cw_compareObjectToObjectImp(sortDescriptor, @selector(compareObject:toObject:), a, b);
    if (result != NSOrderedSame) {
      if (!cw_ascendingImp(sortDescriptor, @selector(ascending))) {
      	result = 0 - result;
      }
      break;
    }
  }
  return result;
}

-(NSUInteger)indexForInsertingObject:(id)anObject sortedUsingDescriptors:(NSArray*)descriptors;
{
	return [self indexForInsertingObject:anObject sortedUsingfunction:&cw_DescriptorCompare context:descriptors];
}

@end


@implementation NSMutableArray (CWSortedInsert)

-(void)insertObject:(id)anObject sortedUsingfunction:(NSInteger (*)(id, id, void *))compare context:(void*)context;
{
	NSUInteger index = [self indexForInsertingObject:anObject sortedUsingfunction:compare context:context];
  [self insertObject:anObject atIndex:index];
}

-(void)insertObject:(id)anObject sortedUsingSelector:(SEL)aSelector;
{
	NSUInteger index = [self indexForInsertingObject:anObject sortedUsingfunction:&cw_SelectorCompare context:aSelector];
	[self insertObject:anObject atIndex:index];
}

-(void)insertObject:(id)anObject sortedUsingDescriptors:(NSArray*)descriptors;
{
	NSUInteger index = [self indexForInsertingObject:anObject sortedUsingDescriptors:descriptors];
  [self insertObject:anObject atIndex:index];
}

- (unsigned) indexOfObject:(id)object inArraySortedBy:(SEL)compareSelector{
	int numElements = [self count];
	// if there are no items in the array, we can just return NSNotFound
	if (numElements == 0)
		return NSNotFound;
    
	// searchRange is the range of items that we need to search.  We initialize it
	// to cover all the items in the array.
	NSRange searchRange = NSMakeRange(0, numElements);
	
	// when the length of our range hits zero, we've found the index of this item. 
	while(searchRange.length > 0)
	{
		// checkIndex in the index of the item in the array that we're going to compare with
		// to find out if the item we're looking for is located before or after.  checkIndex is set
		// to be the middle of the search range.
		unsigned int checkIndex = searchRange.location + (searchRange.length / 2);
        
		// checkObject is the object at checkIndex
		id checkObject = [self objectAtIndex:checkIndex];
        
		// we call compare: on the checkObject, passing it the item we're looking for.
		NSComparisonResult order = (NSComparisonResult) [checkObject performSelector:compareSelector withObject:object];
		
		switch (order)
		{
			case NSOrderedAscending:
			{
				// the item we're looking for appears after the item we checked against.
				// Now, the search range starts with the item after the item we just checked, and ends
				// at the same place as the previous search range.
                
				// end point remains the same, start point moves to next element.
				unsigned int endPoint = searchRange.location + searchRange.length;
				searchRange.location = checkIndex + 1;
				searchRange.length = endPoint - searchRange.location;
				break;
			}
				
			case NSOrderedDescending:
			{
				// the item we're looking for appears before the item we checked against.
				// Now, the search range starts at the same place as the previous search range,
				// and ends with the item just before the item we just checked.
                
				// start point remains the same, end point moves to previous element
				searchRange.length = (checkIndex - 1) - searchRange.location + 1;
				break;
			}
				
			case NSOrderedSame:
			{
				// we have found the item.  Return the index.
				return checkIndex;
				break;
			}
				
			default:
			{
				// we should never get here.  Freak out if we do.  It means you wrote your compare: method wrong.
				assert(0);
				break;
			}
		}
	}
	
	// If we reach here, we have not found the item.  Return NSNotFound.
	return NSNotFound;
}

- (void) addObject:(id)object intoArraySortedBy:(SEL)compareSelector
{
	int numElements = [self count];
	
	// if there are no objects in this array, we can just
	// add this item
	if (numElements == 0)
	{
		[self addObject:object];
		return;
	}
	
	// we need to find out where in the array we need to add this item.
	// So, we do a binary search.
	
	// searchRange is the range of items that we need to search.  We initialize it
	// to cover all the items in the array.
	NSRange searchRange = NSMakeRange(0, numElements);
	
	// when the length of our range hits zero, we've found where we need to
	// insert this item. 
	while(searchRange.length > 0)
	{
		// checkIndex in the index of the item in the array that we're going to compare with
		// to find out if the new item needs to be added before or after.  checkIndex is set
		// to be the middle of the search range.
		unsigned int checkIndex = searchRange.location + (searchRange.length / 2);
        
		// checkObject is the object at checkIndex
		id checkObject = [self objectAtIndex:checkIndex];
        
		// we call compare: on the checkObject, passing it the item we want to add.
		NSComparisonResult order = (NSComparisonResult) [checkObject performSelector:compareSelector withObject:object];
		
		switch (order)
		{
			case NSOrderedAscending:
			{
				// the item we want to add to this array appears after the item we checked against.
				// Now, the search range starts with the item after the item we just checked, and ends
				// at the same place as the previous search range.
                
				// end point remains the same, start point moves to next element.
				unsigned int endPoint = searchRange.location + searchRange.length;
				searchRange.location = checkIndex + 1;
				searchRange.length = endPoint - searchRange.location;
				break;
			}
				
			case NSOrderedDescending:
			{
				// the item we want to add to this array appears before the item we checked against.
				// Now, the search range starts at the same place as the previous search range,
				// and ends with the item just before the item we just checked.
                
				// start point remains the same, end point moves to previous element
				searchRange.length = (checkIndex - 1) - searchRange.location + 1;
				break;
			}
				
			case NSOrderedSame:
			{
				//NSLog(@"Object already exists in array");
				//[[NSException exceptionWithName:@"ElementExists" reason:nil userInfo:nil] raise];
				return;
                break;
			}
				
			default:
			{
				// we should never get here.  Freak out if we do.  It means you wrote your compare: method wrong.
				//assert(0);
                return;
				break;
			}
		}
	}
	
	// now that we have found where in the array to add the item, add it.
	[self insertObject:object atIndex:searchRange.location];
}

- (void)addByDate:(id)object intoArraySortedBy:(SEL)compareSelector{
	int numElements = [self count];
	
	// if there are no objects in this array, we can just
	// add this item
	if (numElements == 0)
	{
		[self addObject:((FacebookItem *)object).itemId];
		return;
	}
	
	// we need to find out where in the array we need to add this item.
	// So, we do a binary search.
	
	// searchRange is the range of items that we need to search.  We initialize it
	// to cover all the items in the array.
	NSRange searchRange = NSMakeRange(0, numElements);
	
	// when the length of our range hits zero, we've found where we need to
	// insert this item. 
	while(searchRange.length > 0)
	{
		// checkIndex in the index of the item in the array that we're going to compare with
		// to find out if the new item needs to be added before or after.  checkIndex is set
		// to be the middle of the search range.
		unsigned int checkIndex = searchRange.location + (searchRange.length / 2);
        
		// checkObject is the object at checkIndex
		id checkObject = [self getFacebookItemFromItemObjects:[self objectAtIndex:checkIndex]];
        
		// we call compare: on the checkObject, passing it the item we want to add.
		NSComparisonResult order = (NSComparisonResult) [checkObject performSelector:compareSelector withObject:object];
		
		switch (order)
		{
			case NSOrderedAscending:
			{
				// the item we want to add to this array appears after the item we checked against.
				// Now, the search range starts with the item after the item we just checked, and ends
				// at the same place as the previous search range.
                
				// end point remains the same, start point moves to next element.
				unsigned int endPoint = searchRange.location + searchRange.length;
				searchRange.location = checkIndex + 1;
				searchRange.length = endPoint - searchRange.location;
				break;
			}
				
			case NSOrderedDescending:
			{
				// the item we want to add to this array appears before the item we checked against.
				// Now, the search range starts at the same place as the previous search range,
				// and ends with the item just before the item we just checked.
                
				// start point remains the same, end point moves to previous element
				searchRange.length = (checkIndex - 1) - searchRange.location + 1;
				break;
			}
				
			case NSOrderedSame:
			{
				//NSLog(@"Object already exists in array");
				//[[NSException exceptionWithName:@"ElementExists" reason:nil userInfo:nil] raise];
				return;
                break;
			}
				
			default:
			{
				// we should never get here.  Freak out if we do.  It means you wrote your compare: method wrong.
				//assert(0);
                return;
				break;
			}
		}
	}
    [self insertObject:((FacebookItem *)object).itemId atIndex:searchRange.location];
	// now that we have found where in the array to add the item, add it.
}



@end
