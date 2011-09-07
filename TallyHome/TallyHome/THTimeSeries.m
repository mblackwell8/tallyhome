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
    
    [super dealloc];
}

- (double)dailyRateOfChangeAt:(NSDate *)date {
    THDateVal *firstBefore = [self firstBefore:date];
    if (firstBefore == nil) {
        double dailyGr = [self calcDailyTrendGrowthPreSeries];
        
        return dailyGr;
    }
    
    if (firstBefore.next == nil) {
        double dailyGr = [self calcDailyTrendGrowth];
        
        return dailyGr;
    }
    
    double daysBetween = [firstBefore.date daysUntil:firstBefore.next.date];
    double dailyRoC = pow(firstBefore.next.val / firstBefore.val, (1.0 / daysBetween)) - 1.0;
    
    //DLog(@"ROC %5.5f", dailyRoC);
    return dailyRoC;
}

- (THDateVal *)calcValueAt:(NSDate *)date {
    THDateVal *equalTo = [self valueAt:date];
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

- (THDateVal *)calcValueAt:(NSDate *)date usingBaseValue:(THDateVal *)baseVal {
    if ([date isEqualToDate:baseVal.date])
        return baseVal;
    
    double val = 0.0;
    
    // if the series encloses the base value (ie. we have next and date is after baseVal)
    // then do linear interpolation
    if (baseVal.next && [date isAfter:baseVal.date]) {
        double dailyGr = (baseVal.next.val - baseVal.val) / [baseVal.next.date daysSince:baseVal.date];
        val = baseVal.val + dailyGr * [date daysSince:baseVal.date];
    }
    // if there's no next and date is after, forecast using forward daily trend
    else if (!baseVal.next && [date isAfter:baseVal.date]) {
        double daysBetween = [baseVal.date daysUntil:date];
        val = baseVal.val * pow(1.0 + [self calcDailyTrendGrowth], daysBetween);
    }
    // if there is a next, but the date is before, precast using backwards daily trend
    else if (baseVal.next && [date isBefore:baseVal.date]) {
        double daysBetween = [baseVal.date daysUntil:date];
        val = baseVal.val * pow(1.0 + [self calcDailyTrendGrowthPreSeries], daysBetween);
    }
    else {
        NSAssert(FALSE, @"Should not get here");
    }
    
    
    THDateVal *retVal = [[THDateVal alloc] initWithVal:val at:date];
    
    return [retVal autorelease];
}

- (double)calcDailyTrendGrowth {
    if (!_fwdGrowthCalced) {
        _fwdDailyGrowth = [self calcDailyTrendGrowthOver:trendExtrapolationInterval];
        _fwdGrowthCalced = YES;
    }
    
    return _fwdDailyGrowth;
}

- (double)calcDailyTrendGrowthPreSeries {
    if (!_backwardGrowthCalced) {
        _backwardDailyGrowth = [self calcDailyTrendGrowthOver:-trendExtrapolationInterval];
        _backwardGrowthCalced = YES;
    }
    
    return _backwardDailyGrowth;
}

- (double)calcDailyTrendGrowthOver:(NSTimeInterval) interval {
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
        
        return [THTimeSeries calcSMADailyTrendGrowthFrom:first to:last];
    }
    else if (interval < 0) {
        first = [_innerSeries objectAtIndex:0];
        NSDate *firstDate = [first.date dateByAddingTimeInterval:-interval];
        if ([firstDate isAfterOrEqualTo:[[_innerSeries lastObject] date]]) {
            last = [_innerSeries lastObject];
        }
        else {
            // use the indice that is the first after the interval, to maximise the length
            // of the interval
            last = [self firstAfter:firstDate];
        }
        
        return [THTimeSeries calcSMADailyTrendGrowthFrom:first to:last];
        
    }
    else {
        return 0.0;
    }
    
    NSAssert(FALSE, @"Should not get here");
    
    return 0.0;
}

+ (double)calcSMADailyTrendGrowthFrom:(THDateVal *)first to:(THDateVal *)last {
    if (first == last || ABS([first.date daysUntil:last.date]) == 0.0)
        return 0.0;
    
    // calc the SMA daily growth between two points
    double n = 0.0;
    double sum = 0.0;
    THDateVal *current = first;
    while (current.next && current != last) {
        double days = [current.date daysUntil:current.next.date];
        sum += pow(current.next.val / current.val, 1.0 / days) - 1.0;
        n += 1.0;
        current = current.next;
    }
    
    return (sum / n);
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
