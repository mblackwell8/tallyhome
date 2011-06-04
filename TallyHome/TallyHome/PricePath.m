//
//  PricePath.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PricePath.h"


@implementation PricePath

@synthesize priceEvents;
@synthesize  backwardsExtrapolationInterval;
@synthesize  forwardsExtrapolationInterval;
@synthesize appliedPriceEvents;

- (id) init {
    if ((self = [super init])) {
        backwardsExtrapolationInterval = TH_FiveYearTimeInterval;
        forwardsExtrapolationInterval = TH_FiveYearTimeInterval;
    }
    
    return self;
}

- (id) initFromXmlString:(NSString *)xml {
    
    
    return NULL;
}


- (NSArray *) applyTo:(double) startingPrice from:(NSDate *) startDate to:(NSDate *) endDate {
    if (self.appliedPriceEvents)
        [self.appliedPriceEvents release];
    
    self.appliedPriceEvents = [[NSMutableArray alloc] init];
    
    //if startDate is earlier than the first date in the PricePath then extrapolate backwards
    PriceEvent *firstEvent = [priceEvents objectAtIndex:0];
    if ([startDate timeIntervalSinceDate:firstEvent.date] < 0) {
        PriceEvent *newFirst = [[PriceEvent alloc] init];
        newFirst.date = startDate;
        newFirst.sourceType = TH_SOURCETYPE_EXTRAPOLATED;
        
        PriceEvent *oldFirst = [priceEvents objectAtIndex:0];
        double periodInDays = [oldFirst.date timeIntervalSinceDate:newFirst.date] / (24.0 * 60 * 60);
        oldFirst.impactSinceLast = [self calcBackwardsTrendGrowth] * periodInDays / 365.0;
        
        [self.appliedPriceEvents addObject:newFirst];
        [newFirst release];
    }
    
    //else find the price event before the start date
    int index = [self indexOfFirstEventBeforeDate:startDate];    
    while (index < priceEvents.count) {
        PriceEvent *event = [priceEvents objectAtIndex:index];
        if ([endDate timeIntervalSinceDate:event.date] > 0) {
            break;
        }
        
        [self.appliedPriceEvents addObject:[priceEvents objectAtIndex:index]];
        index += 1;
    }
    
    
    //HACK: does not handle (unusual) case where the requested endDate doesn't need to be extrapolated
    NSAssert(index == priceEvents.count, @"PricePath not properly extrapolated");
    
    //if endDate is later than last date then extrapolate forwards
    PriceEvent *lastEvent = [priceEvents lastObject];
    if ([endDate timeIntervalSinceDate:lastEvent.date] > 0) {
        PriceEvent *newLast = [[PriceEvent alloc] init];
        
        double periodInDays = [newLast.date timeIntervalSinceDate:lastEvent.date] / (24.0 * 60 * 60);
        newLast.impactSinceLast = [self calcTrendGrowth] * periodInDays / 365.0;
        
        [self.appliedPriceEvents addObject:newLast];
        [newLast release];
    }
    
    return appliedPriceEvents;
}

- (double) calcTrendGrowth {
    return [self calcTrendGrowthForTimeInterval: forwardsExtrapolationInterval];
}

- (double) calcTrendGrowthForTimeInterval:(NSTimeInterval) interval {
    // find the closest price event, interval ago
    NSDate *now = [NSDate date];
    NSDate *ago = [now dateByAddingTimeInterval:-interval];
    int trendIx = [self indexOfFirstEventBeforeDate:ago];
    
    trendIx = (trendIx == priceEvents.count ? trendIx - 2 : trendIx);
    
    double totalGrowth = 0.0;
    int index = trendIx;
    while (index < priceEvents.count) {
        PriceEvent *ev = [priceEvents objectAtIndex:index];
        totalGrowth = (1.0 + totalGrowth) * (1.0 + ev.impactSinceLast) - 1.0;
        index += 1;
    }
    
    PriceEvent *last = [priceEvents lastObject];
    PriceEvent *trend = [priceEvents objectAtIndex:index];
    double daysBetween = [last.date timeIntervalSinceDate:trend.date] / (24.0 * 60 * 60);
    
    //HACK: linear approximation of geometric growth
    double annualisedGrowth = totalGrowth * 365.0 / daysBetween;
    
    [now release];
    
    return annualisedGrowth;
}

- (double) calcBackwardsTrendGrowth {
    
    
    return 0.0;
}

- (int) indexOfFirstEventBeforeDate:(NSDate *)date {
    int index = 0;
    while ((index + 1) < priceEvents.count) {
        // will fail if price events are not in order
        PriceEvent *first = [priceEvents objectAtIndex:index];
        PriceEvent *second = [priceEvents objectAtIndex:(index + 1)];
        NSAssert(first && second &&
                 [second.date timeIntervalSinceDate:first.date] > 0, @"PricePath events out of order");
        if ([first.date timeIntervalSinceDate:date] < 0 &&
            [second.date timeIntervalSinceDate:date] > 0) {
            break;
        }
        index += 1;
    }
    
    return index;

}


@end
