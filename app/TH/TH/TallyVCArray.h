//
//  TallyVCArray.h
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TallyVCArray : NSObject <NSCoding> {    
    NSMutableArray *_tallyViewDetailControllers;
}

@property (nonatomic, retain) NSArray *detailControllers;

+ (NSString *)uniqueUserId;

- (void)swapObjectAtIndex:(NSUInteger)i1 withObjectAtIndex:(NSUInteger)i2;

// funnel through to the underlying array
- (void)addObject:(id)anObject;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)ix;
- (NSUInteger)count;
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

@end
