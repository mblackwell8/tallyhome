//
//  THArray.m
//  TallyHome
//
//  Created by Mark Blackwell on 20/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THArray.h"


@interface NSArray (BinarySearchPrivate)
- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex;
@end


@implementation NSArray (THArray)

- (NSInteger)binarySearch:(id)searchItem
{
    if (searchItem == nil)
        return NSNotFound;
    return [self binarySearch:searchItem minIndex:0 maxIndex:[self count] - 1];
}


- (NSInteger)binarySearch:(id)searchItem minIndex:(NSInteger)minIndex maxIndex:(NSInteger)maxIndex
{
    // If the subarray is empty, return not found
    if (maxIndex < minIndex) 
        return NSNotFound;
    
    NSInteger midIndex = (minIndex + maxIndex) / 2;
    id itemAtMidIndex = [self objectAtIndex:midIndex];
    
    NSComparisonResult comparison = [searchItem compare:itemAtMidIndex];
    if (comparison == NSOrderedSame)
        return midIndex;
    else if (comparison == NSOrderedAscending)
        return [self binarySearch:searchItem minIndex:minIndex maxIndex:midIndex - 1];
    else
        return [self binarySearch:searchItem minIndex:midIndex + 1 maxIndex:maxIndex];
}


@end
