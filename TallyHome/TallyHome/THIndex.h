//
//  Index.h
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "THIndice.h"

#define TH_OneYearTimeInterval      365 * 24 * 60 * 60
#define TH_FiveYearTimeInterval     365 * 24 * 60 * 60 * 5
#define TH_TenYearTimeInterval      365 * 24 * 60 * 60 * 10

//@class Indice;

@interface THIndex : NSObject <NSFastEnumeration> {
    NSArray  *_innerIndex;
    NSTimeInterval backwardsExtrapolationInterval;
    NSTimeInterval forwardsExtrapolationInterval;
    
    NSMutableArray *_calcedIndices;
}

@property (retain) NSArray *innerIndex;
@property NSTimeInterval backwardsExtrapolationInterval;
@property NSTimeInterval forwardsExtrapolationInterval;

- (id) initWithIndices:(NSArray *)indices;

- (double)dailyRateOfChangeAt:(NSDate *)date;
+ (double)dailyRateOfChangeFrom:(THIndice *)first to:(THIndice *)last;
+ (double)daysFrom:(NSDate *)first to:(NSDate *)last;
- (THIndice *)calcIndiceAt:(NSDate *)date;
- (THIndice *)calcIndiceAt:(NSDate *)date usingBaseIndice:(THIndice *)i;

// annual growth, trending forward (ie. using most recent data)
- (double) calcTrendGrowth;
- (double) calcTrendGrowthOver:(NSTimeInterval) interval;
- (double) calcBackwardsTrendGrowth;
- (double) calcBackwardsTrendGrowthOver:(NSTimeInterval) interval;
+ (double) calcTrendGrowthFrom:(THIndice *)first to:(THIndice *)last;
//- (int) indexOfFirstBefore:(NSDate *)date;
- (THIndice *) firstBefore:(NSDate *)date;
- (THIndice *) firstAfter:(NSDate *)date;
//- (THIndice *) indiceAtDate:(NSDate *)date;

- (NSEnumerator *) dailyEnumerator;
- (NSEnumerator *) dailyEnumeratorStartingAt:(NSDate *)date;

// add a few convenience access methods to underlying array
- (NSUInteger)count;
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;

- (void) dealloc;

@end
