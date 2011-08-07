//
//  Index.h
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "THDateVal.h"
#import "THDate.h"

#define TH_OneYearTimeInterval      365 * 24 * 60 * 60
#define TH_FiveYearTimeInterval     365 * 24 * 60 * 60 * 5
#define TH_TenYearTimeInterval      365 * 24 * 60 * 60 * 10

//immutable, ordered collection of THDateVal objects
@interface THTimeSeries : NSObject <NSFastEnumeration, NSCoding, NSCopying> {
    NSArray  *_innerSeries;
    //NSTimeInterval backwardsExtrapolationInterval;
    NSTimeInterval trendExtrapolationInterval;
    
    NSMutableDictionary *_calcedIndices;
}

@property (retain, nonatomic) NSArray *innerIndex;
//@property NSTimeInterval backwardsExtrapolationInterval;
@property NSTimeInterval trendExtrapolationInterval;

- (id)initWithValues:(NSArray *)indices;

- (id)copyWithZone:(NSZone *)zone;

- (double)dailyRateOfChangeAt:(NSDate *)date;
+ (double)dailyRateOfChangeFrom:(THDateVal *)first to:(THDateVal *)last;
//+ (double)daysFrom:(NSDate *)first to:(NSDate *)last;
- (THDateVal *)calcValueAt:(NSDate *)date;
- (THDateVal *)calcValueAt:(NSDate *)date usingBaseValue:(THDateVal *)i;

// annual growth, trending forward (ie. using most recent data)
- (double)calcTrendGrowth;
- (double)calcTrendGrowthOver:(NSTimeInterval) interval;
//- (double) calcBackwardsTrendGrowth;
//- (double) calcBackwardsTrendGrowthOver:(NSTimeInterval) interval;
+ (double)calcTrendGrowthFrom:(THDateVal *)first to:(THDateVal *)last;
//- (int) indexOfFirstBefore:(NSDate *)date;
- (THDateVal *)firstBefore:(NSDate *)date;
- (THDateVal *)firstAfter:(NSDate *)date;
- (THDateVal *)valueAt:(NSDate *)date;
- (THDateVal *)binarySearch:(NSDate *)date minIndex:(int)min maxIndex:(int)max;

- (THDateVal *)maxValue;
- (THDateVal *)minValue;

- (NSEnumerator *)dailyEnumerator;
- (NSEnumerator *)dailyEnumeratorStartingAt:(NSDate *)date;

// add a few convenience access methods to underlying array
- (NSUInteger)count;
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (void) dealloc;

@end
