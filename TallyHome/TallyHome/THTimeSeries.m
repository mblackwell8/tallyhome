//
//  Index.m
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THTimeSeries.h"
#import "DebugMacros.h"

@implementation THTimeSeries

@synthesize innerIndex = _innerSeries, trendExtrapolationInterval;

//- (id)init {
//    if ((self = [super init])) {
//        trendExtrapolationInterval = TH_FiveYearTimeInterval;
//        _innerSeries = nil;
//        _calcedIndices = nil;
//    }
//    
//    return self;
//}

- (id)initWithValues:(NSArray *)indices {
    if ((self = [super init])) {
        trendExtrapolationInterval = TH_FiveYearTimeInterval;
        _calcedIndices = nil;
        NSMutableArray *tmpInnerSeries = [[NSMutableArray alloc] initWithArray:indices];
        //sort the indices by date
        [tmpInnerSeries sortUsingSelector:@selector(compareByDate:)];
        THDateVal *last = nil;
        for (THDateVal *v in tmpInnerSeries) {
            NSAssert(!v.ix && !v.last, @"Should not insert THDateVal in >1 time series... make a copy!");
            v.ix = self;
            v.last = last;
            last = v;
        }
        THDateVal *next = nil;
        for (THDateVal *v in [tmpInnerSeries reverseObjectEnumerator]) {
            NSAssert(!v.next, @"Should not insert THDateVal in >1 time series... make a copy!");
            v.next = next;
            next = v;
        }
        _innerSeries = [[NSArray alloc] initWithArray:tmpInnerSeries];
        [tmpInnerSeries release];
        //_calcedIndices = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#define kInnerSeriesCoder   @"InnerSeries"
#define kTrendExtrapCoder   @"TrendExtrap"

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *ser = [decoder decodeObjectForKey:kInnerSeriesCoder];
    NSTimeInterval ti = [decoder decodeDoubleForKey:kTrendExtrapCoder];
    
    id s = [self initWithValues:ser];
    [s setTrendExtrapolationInterval:ti];
    
    return s;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:trendExtrapolationInterval forKey:kTrendExtrapCoder];
    [coder encodeObject:_innerSeries forKey:kInnerSeriesCoder];
}

- (id)copyWithZone:(NSZone *)zone {
    THTimeSeries *copy = [[THTimeSeries allocWithZone:zone] initWithValues:_innerSeries];
    copy.trendExtrapolationInterval = trendExtrapolationInterval;
    //don't worry about calced indices
    
    return copy;
}

- (void)dealloc {
    [_innerSeries release];
    [_calcedIndices release];
    
    [super dealloc];
}


- (double)dailyRateOfChangeAt:(NSDate *)date {
    THDateVal *firstBefore = [self firstBefore:date];
    if (firstBefore == nil) {
        // calc backwards growth, which needs to be negated
        
        double annGr = [self calcTrendGrowthOver:-trendExtrapolationInterval];
        double dailyGr = -(pow(1.0 + annGr, 1.0 / 365.0) - 1.0);
        
        return dailyGr;
    }
    
    THDateVal *firstAfterOrEqualTo = [self valueAt:date];
    if (!firstAfterOrEqualTo) {
        firstAfterOrEqualTo = [self firstAfter:date];
    }
    if (firstAfterOrEqualTo == nil) {
        double annGr = [self calcTrendGrowth];
        return pow(1.0 + annGr, 1.0 / 365.0) - 1.0;
    }
    
    return [THTimeSeries dailyRateOfChangeFrom:firstBefore to:firstAfterOrEqualTo];
}

+ (double)dailyRateOfChangeFrom:(THDateVal *)first to:(THDateVal *)last {
    double daysBetween = [first.date daysUntil:last.date];
    
    double dailyRoC = pow(last.val / first.val, (1.0 / daysBetween)) - 1.0;
    
    return dailyRoC;
}

//+ (double)daysFrom:(NSDate *)first to:(NSDate *)last {
//    double daysBetween = [last timeIntervalSinceDate:first] / (24.0 * 60 * 60);
//    
//    return daysBetween;
//}

- (THDateVal *)calcValueAt:(NSDate *)date {
    THDateVal *equalTo = [self valueAt:date];
    if (equalTo)
        return equalTo;
    
    if (!_calcedIndices)
        _calcedIndices = [[NSMutableDictionary alloc] init];
    
    equalTo = [_calcedIndices objectForKey:date];
    if (equalTo)
        return equalTo;
    
    if ([[[_innerSeries objectAtIndex:0] date] isBeforeOrEqualTo:date]) {
        if ([[[_innerSeries lastObject] date] isAfterOrEqualTo:date]) {
            // the requested date is enclosed by the Index
            if ([[[_innerSeries objectAtIndex:0] date] isEqualToDate:date])
                return [_innerSeries objectAtIndex:0];
            if ([[[_innerSeries lastObject] date] isEqualToDate:date])
                return [_innerSeries lastObject];
            
            THDateVal *firstBefore = [self firstBefore:date];
            NSAssert(firstBefore, @"No indice available between dates");
            return [self calcValueAt:date usingBaseValue:firstBefore];
        }
        // the requested date is after the end of the Index
        return [self calcValueAt:date usingBaseValue:[_innerSeries lastObject]];
        
    }
    else {
        // the requested date is before the beginning of the Index
        return [self calcValueAt:date usingBaseValue:[_innerSeries objectAtIndex:0]];
    }
    
    NSAssert(FALSE, @"Should not get here");
}

- (THDateVal *)calcValueAt:(NSDate *)date usingBaseValue:(THDateVal *)i {
    double daysBetween = [i.date daysUntil:date];
    double roc = [self dailyRateOfChangeAt:date];
    double val = i.val * pow(1.0 + roc, daysBetween);
    THDateVal *retVal = [[THDateVal alloc] initWithVal:val at:date];
    
    if (!_calcedIndices)
        _calcedIndices = [[NSMutableDictionary alloc] init];
    
    [_calcedIndices setObject:retVal forKey:retVal.date];
    
    return [retVal autorelease];
}

- (double)calcTrendGrowth {
    return [self calcTrendGrowthOver:trendExtrapolationInterval];
}

- (double)calcTrendGrowthOver:(NSTimeInterval) interval {
    THDateVal *first = nil, *last = nil;
    if (interval > 0) {
        last = [_innerSeries lastObject];
        NSDate *firstDate = [last.date dateByAddingTimeInterval:-interval];
        if ([firstDate isBeforeOrEqualTo:[[_innerSeries objectAtIndex:0] date]]) {
            first = [_innerSeries objectAtIndex:0];
        }
        else {
            // use the indice that is the first before the interval, to maximise the length
            // of the interval
            first = [self firstBefore:firstDate];
        }
    }
    else if (interval < 0) {
        last = [_innerSeries objectAtIndex:0];
        NSDate *firstDate = [last.date dateByAddingTimeInterval:-interval];
        if ([firstDate isAfterOrEqualTo:[[_innerSeries lastObject] date]]) {
            first = [_innerSeries lastObject];
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
    return [THTimeSeries calcTrendGrowthFrom:first to:last];
    
}

+ (double)calcTrendGrowthFrom:(THDateVal *)first to:(THDateVal *)last {
    double daysBetween = fabs([first.date daysUntil:last.date]);
    if (daysBetween == 0.0)
        return 0.0;
    
    double annualisedGrowth = pow(last.val / first.val, 365.0 / daysBetween) - 1.0;
    
    return annualisedGrowth;

}

- (THDateVal *)firstBefore:(NSDate *)date {
    //if date is before or at the start of the index, return nil
    if ([date isBeforeOrEqualTo:[[_innerSeries objectAtIndex:0] date]])
        return nil;
    
    THDateVal *last = nil;
    for (THDateVal *next in _innerSeries) {
        // will fail if price events are not in order
        NSAssert(!last || [next.date isAfterOrEqualTo:last.date], @"Index out of order");
        if (last &&
            [last.date isBefore:date] &&
            [next.date isAfterOrEqualTo:date]) {
            
            return last;
        }
        last = next;
    }
    
    return [_innerSeries lastObject];
}

- (THDateVal *)firstAfter:(NSDate *)date {
    //if date is after or at the end of the index, return nil
    if ([date isAfterOrEqualTo:[[_innerSeries lastObject] date]])
        return nil;
    
    THDateVal *last = nil;
    for (THDateVal *next in [_innerSeries reverseObjectEnumerator]) {
        // will fail if price events are not in order
        NSAssert(!last || [next.date isBeforeOrEqualTo:last.date], @"Index out of order");
        if (last &&
            [last.date isAfter:date] &&
            [next.date isBeforeOrEqualTo:date]) {
            
            return last;
        }
        last = next;
    }
    
    return [_innerSeries objectAtIndex:0];
}

- (THDateVal *)valueAt:(NSDate *)date {
    if (date == nil)
        return nil;
    return [self binarySearch:date minIndex:0 maxIndex:_innerSeries.count - 1];
}

- (THDateVal *)binarySearch:(NSDate *)date minIndex:(int)min maxIndex:(int)max {
    // If the subarray is empty, return not found
    if (max < min) 
        return nil;
    
    int mid = (min + max) / 2;
    THDateVal *midIndice = [_innerSeries objectAtIndex:mid];
    
    NSComparisonResult comparison = [date compare:midIndice.date];
    if (comparison == NSOrderedSame)
        return midIndice;
    else if (comparison == NSOrderedAscending)
        return [self binarySearch:date minIndex:min maxIndex:mid - 1];
    else
        return [self binarySearch:date minIndex:mid + 1 maxIndex:max];
}

- (THDateVal *)maxValue {
    THDateVal *max = nil;
    for (THDateVal *i in _innerSeries) {
        if (!max || i.val > max.val)
            max = i;
    }
    return max;
}
- (THDateVal *)minValue {
    THDateVal *min = nil;
    for (THDateVal *i in _innerSeries) {
        if (!min || i.val < min.val)
            min = i;
    }    
    return min;
}


- (NSUInteger)count {
    return _innerSeries.count;
}
- (id)lastObject {
    return  [_innerSeries lastObject];
}
- (id)objectAtIndex:(NSUInteger)index {
    return [_innerSeries objectAtIndex:index];
}

- (NSEnumerator *)dailyEnumerator {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}
- (NSEnumerator *)dailyEnumeratorStartingAt:(NSDate *)date {
    NSAssert(FALSE, @"Method not implemented");
    return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [_innerSeries countByEnumeratingWithState:state objects:stackbuf count:len];
}

- (NSString *)description {
    return [_innerSeries description];
}


@end
