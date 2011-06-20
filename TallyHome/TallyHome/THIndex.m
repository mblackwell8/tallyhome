//
//  Index.m
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THIndex.h"


@implementation THIndex

@synthesize innerIndex = _innerIndex, trendExtrapolationInterval;

- (id) init {
    if ((self = [super init])) {
        trendExtrapolationInterval = TH_FiveYearTimeInterval;
    }
    
    return self;
}

- (id) initWithIndices:(NSArray *)indices {
    if ((self = [self init])) {
        _innerIndex = [[NSMutableArray alloc] initWithArray:indices];
    }
    
    return self;
}


- (double)dailyRateOfChangeAt:(NSDate *)date {
    THIndice *firstBefore = [self firstBefore:date];
    if (firstBefore == nil) {
        double annGr = [self calcTrendGrowthOver:-trendExtrapolationInterval];
        return pow(1.0 + annGr, 1.0 / 365.0) - 1.0;
    }
    
    THIndice *firstAfterOrEqualTo = [self indiceAt:date];
    if (!firstAfterOrEqualTo) {
        firstAfterOrEqualTo = [self firstAfter:date];
    }
    if (firstAfterOrEqualTo == nil) {
        double annGr = [self calcTrendGrowth];
        return pow(1.0 + annGr, 1.0 / 365.0) - 1.0;
    }
    
    return [THIndex dailyRateOfChangeFrom:firstBefore to:firstAfterOrEqualTo];
}

+ (double)dailyRateOfChangeFrom:(THIndice *)first to:(THIndice *)last {
    double daysBetween = [first.date daysUntil:last.date];
    
    double dailyRoC = pow(last.val / first.val, (1.0 / daysBetween)) - 1.0;
    
    return dailyRoC;
}

//+ (double)daysFrom:(NSDate *)first to:(NSDate *)last {
//    double daysBetween = [last timeIntervalSinceDate:first] / (24.0 * 60 * 60);
//    
//    return daysBetween;
//}

- (THIndice *)calcIndiceAt:(NSDate *)date {
    THIndice *equalTo = [self indiceAt:date];
    if (equalTo)
        return equalTo;
    
    equalTo = [_calcedIndices objectForKey:date];
    if (equalTo)
        return equalTo;
    
    if ([[[_innerIndex objectAtIndex:0] date] isBeforeOrEqualTo:date]) {
        if ([[[_innerIndex lastObject] date] isAfterOrEqualTo:date]) {
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
    double daysBetween = [i.date daysUntil:date];
    double roc = [self dailyRateOfChangeAt:date];
    double val = i.val * pow(1.0 + roc, daysBetween);
    THIndice *retVal = [THIndice initWithVal:val at:date];
    
    if (!_calcedIndices)
        _calcedIndices = [[NSMutableArray alloc] init];
    
    [_calcedIndices addObject:retVal];
    [retVal release];
    
    return retVal;
}

- (double) calcTrendGrowth {
    return [self calcTrendGrowthOver:trendExtrapolationInterval];
}

- (double) calcTrendGrowthOver:(NSTimeInterval) interval {
    THIndice *first = nil, *last = nil;
    if (interval > 0) {
        last = [_innerIndex lastObject];
        NSDate *firstDate = [last.date dateByAddingTimeInterval:-interval];
        if ([firstDate isBeforeOrEqualTo:[[_innerIndex objectAtIndex:0] date]]) {
            first = [_innerIndex objectAtIndex:0];
        }
        else {
            // use the indice that is the first before the interval, to maximise the length
            // of the interval
            first = [self firstBefore:firstDate];
        }
    }
    else if (interval < 0) {
        last = [_innerIndex objectAtIndex:0];
        NSDate *firstDate = [last.date dateByAddingTimeInterval:-interval];
        if ([firstDate isAfterOrEqualTo:[[_innerIndex lastObject] date]]) {
            first = [_innerIndex lastObject];
        }
        else {
            // use the indice that is the first after the interval, to maximise the length
            // of the interval
            first = [self firstAfter:firstDate];
        }

    }
    else {
        return 0.0;
    }
            
    NSAssert(first && last, @"Dates not initialised");
    return [THIndex calcTrendGrowthFrom:first to:last];
    
}

+ (double) calcTrendGrowthFrom:(THIndice *)first to:(THIndice *)last {
    double daysBetween = ABS([first.date daysUntil:last.date]);
    if (daysBetween == 0.0)
        return 0.0;
    
    double annualisedGrowth = pow(last.val / first.val, 365.0 / daysBetween) - 1.0;
    
    return annualisedGrowth;

}

//- (double) calcBackwardsTrendGrowth {
//    return [self calcBackwardsTrendGrowthOver:backwardsExtrapolationInterval];
//}
//
//// calcs trend growth going backwards in time (on same basis as fwd growth, so will mostly be negative)
//- (double) calcBackwardsTrendGrowthOver:(NSTimeInterval) interval {
//    THIndice *firstIndice = [_innerIndex objectAtIndex:0];
//    NSDate *last = [firstIndice.date dateByAddingTimeInterval:interval];
//    
//    THIndice *lastIndice = nil;
//    if ([last timeIntervalSinceDate:[[_innerIndex lastObject] date]] >= 0) {
//        lastIndice = [_innerIndex lastObject];
//    }
//    else {
//        // use the indice that is the first after the interval, to maximise the length
//        // of the interval
//        lastIndice = [self firstAfter:last];
//    }
//    
//    return [THIndex calcTrendGrowthFrom:lastIndice to:firstIndice];
//    
//}

- (THIndice *) firstBefore:(NSDate *)date {
    //if date is before or at the start of the index, return nil
    if ([date isBeforeOrEqualTo:[[_innerIndex objectAtIndex:0] date]])
        return nil;
    
    THIndice *last = nil;
    for (THIndice *next in _innerIndex) {
        // will fail if price events are not in order
        NSAssert(!last || [next.date isAfterOrEqualTo:last.date], @"Index out of order");
        if (last &&
            [last.date isBefore:date] &&
            [next.date isAfterOrEqualTo:date]) {
            
            return last;
        }
        last = next;
    }
    
    return [_innerIndex lastObject];
}

- (THIndice *) firstAfter:(NSDate *)date {
    //if date is after or at the end of the index, return nil
    if ([date isAfterOrEqualTo:[[_innerIndex lastObject] date]])
        return nil;
    
    THIndice *last = nil;
    for (THIndice *next in [_innerIndex reverseObjectEnumerator]) {
        // will fail if price events are not in order
        NSAssert(!last || [next.date isBeforeOrEqualTo:last.date], @"Index out of order");
        if (last &&
            [last.date isAfter:date] &&
            [next.date isBeforeOrEqualTo:date]) {
            
            return last;
        }
        last = next;
    }
    
    return [_innerIndex objectAtIndex:0];
}

- (THIndice *) indiceAt:(NSDate *)date {
    if (date == nil)
        return nil;
    return [self binarySearch:date minIndex:0 maxIndex:_innerIndex.count - 1];
}

- (THIndice *) binarySearch:(NSDate *)date minIndex:(int)min maxIndex:(int)max {
    // If the subarray is empty, return not found
    if (max < min) 
        return nil;
    
    int mid = (min + max) / 2;
    THIndice *midIndice = [_innerIndex objectAtIndex:mid];
    
    NSComparisonResult comparison = [date compare:midIndice.date];
    if (comparison == NSOrderedSame)
        return midIndice;
    else if (comparison == NSOrderedAscending)
        return [self binarySearch:date minIndex:min maxIndex:mid - 1];
    else
        return [self binarySearch:date minIndex:mid + 1 maxIndex:max];
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
