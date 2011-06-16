//
//  Index.m
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THIndex.h"


@implementation THIndex

@synthesize innerIndex = _innerIndex, backwardsExtrapolationInterval, forwardsExtrapolationInterval;

- (id) init {
    if ((self = [super init])) {
        backwardsExtrapolationInterval = TH_FiveYearTimeInterval;
        forwardsExtrapolationInterval = TH_FiveYearTimeInterval;
    }
    
    return self;
}

- (id) initWithIndices:(NSArray *)indices {
    if ((self = [self init])) {
        _innerIndex = [[NSArray alloc] initWithArray:indices];
    }
    
    return self;
}


- (double)dailyRateOfChangeAt:(NSDate *)date {
    THIndice *firstBefore = [self firstBefore:date];
    THIndice *firstAfter = [self firstAfter:date];
    
    if (firstBefore == nil)
        return [self calcTrendGrowth];
    if (firstAfter == nil)
        return [self calcBackwardsTrendGrowth];
    
    return [THIndex dailyRateOfChangeFrom:firstBefore to:firstAfter];
}

+ (double)dailyRateOfChangeFrom:(THIndice *)first to:(THIndice *)last {
    double daysBetween = [THIndex daysFrom:first.date to:last.date];
    
    double dailyRoC = pow(last.val - first.val, (1.0 / daysBetween));
    
    return dailyRoC;
}

+ (double)daysFrom:(NSDate *)first to:(NSDate *)last {
    double daysBetween = [last timeIntervalSinceDate:first] / (24.0 * 60 * 60);
    
    return daysBetween;
}

- (THIndice *)calcIndiceAt:(NSDate *)date {
    if ([[[_innerIndex objectAtIndex:0] date] timeIntervalSinceDate:date] <= 0) {
        if ([[[_innerIndex lastObject] date] timeIntervalSinceDate:date] >= 0) {
            // the requested date is enclosed by the Index
            if ([[[_innerIndex objectAtIndex:0] date] isEqualToDate:date])
                return [_innerIndex objectAtIndex:0];
            if ([[[_innerIndex lastObject] date] isEqualToDate:date])
                return [_innerIndex lastObject];
            
            THIndice *firstBefore = [self firstBefore:date];
            NSAssert(firstBefore, @"No indice available between dates");
            return [self calcIndiceAt:date usingBaseIndice:firstBefore];
        }
        // the requested date is after the end of the Index
        return [self calcIndiceAt:date usingBaseIndice:[_innerIndex lastObject]];
        
    }
    else {
        // the requested date is before the beginning of the Index
        return [self calcIndiceAt:date usingBaseIndice:[_innerIndex objectAtIndex:0]];
    }
    
    NSAssert(FALSE, @"Should not get here");
}

- (THIndice *)calcIndiceAt:(NSDate *)date usingBaseIndice:(THIndice *)i {
    double daysBetween = [THIndex daysFrom:i.date to:date];
    double roc = [self dailyRateOfChangeAt:date];
    double val = i.val * pow(1.0 + roc, daysBetween);
    THIndice *retVal = [THIndice initWithVal:val at:date];
    
    if (!_calcedIndices)
        _calcedIndices = [[NSMutableArray alloc] init];
    
    [_calcedIndices addObject:retVal];
    
    return retVal;
}

- (double) calcTrendGrowth {
    return [self calcTrendGrowthOver:forwardsExtrapolationInterval];
}

- (double) calcTrendGrowthOver:(NSTimeInterval) interval {
    THIndice *nowIndice = [_innerIndex lastObject];
    NSDate *ago = [nowIndice.date dateByAddingTimeInterval:-interval];
    THIndice *agoIndice = [self calcIndiceAt:ago];
    
    return [THIndex calcTrendGrowthFrom:agoIndice to:nowIndice];
    
}

+ (double) calcTrendGrowthFrom:(THIndice *)first to:(THIndice *)last {
    int daysBetween = [THIndex daysFrom:first.date to:last.date];
    
    double annualisedGrowth = pow(last.val / first.val, 365.0 / daysBetween) - 1.0;
    
    return annualisedGrowth;

}

- (double) calcBackwardsTrendGrowth {
    return [self calcBackwardsTrendGrowthOver:backwardsExtrapolationInterval];
}

// calcs trend growth going backwards in time (on same basis as fwd growth, so will mostly be negative)
- (double) calcBackwardsTrendGrowthOver:(NSTimeInterval) interval {
    THIndice *firstIndice = [_innerIndex objectAtIndex:0];
    NSDate *last = [firstIndice.date dateByAddingTimeInterval:interval];
    THIndice *lastIndice = [self calcIndiceAt:last];
    
    return [THIndex calcTrendGrowthFrom:lastIndice to:firstIndice];
    
}

- (THIndice *) firstBefore:(NSDate *)date {
    NSDate *first = [NSDate distantPast];
    if ([date isEqualToDate:first])
        return nil;
    
    for (THIndice *next in _innerIndex) {
        // will fail if price events are not in order
        NSAssert([next.date timeIntervalSinceDate:first] > 0, @"Index out of order");
        if ([first timeIntervalSinceDate:date] > 0 &&
            [next.date timeIntervalSinceDate:date] <= 0) {
            [first release];
            
            return next;
        }
        [first release];
        first = [next.date retain];
    }
    
    return [_innerIndex lastObject];
}

- (THIndice *) firstAfter:(NSDate *)date {
    NSDate *first = [NSDate distantFuture];
    if ([date isEqualToDate:first])
        return nil;
    
    for (THIndice *next in [_innerIndex reverseObjectEnumerator]) {
        // will fail if price events are not in order
        NSAssert([next.date timeIntervalSinceDate:first] < 0, @"Index out of order");
        if ([first timeIntervalSinceDate:date] < 0 &&
            [next.date timeIntervalSinceDate:date] >= 0) {
            [first release];
            
            return next;
        }
        [first release];
        first = [next.date retain];
    }
    
    return nil;

}

- (NSUInteger)count {
    return _innerIndex.count;
}
- (id)lastObject {
    return  [_innerIndex lastObject];
}
- (id)objectAtIndex:(NSUInteger)index {
    return [_innerIndex objectAtIndex:index];
}

- (NSEnumerator *) dailyEnumerator {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}
- (NSEnumerator *) dailyEnumeratorStartingAt:(NSDate *)date {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [_innerIndex countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (void) dealloc {
    [_innerIndex release];
    [_calcedIndices release];
    
    [super dealloc];
}

@end
