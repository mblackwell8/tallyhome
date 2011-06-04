//
//  PricePath.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceEvent.h"

#define TH_OneYearTimeInterval      365 * 24 * 60 * 60
#define TH_FiveYearTimeInterval     365 * 24 * 60 * 60 * 5
#define TH_TenYearTimeInterval      365 * 24 * 60 * 60 * 10


@interface PricePath : NSObject {
    NSArray *priceEvents;
    NSTimeInterval backwardsExtrapolationInterval;
    NSTimeInterval forwardsExtrapolationInterval;
    
    NSArray *appliedPriceEvents;
}

@property (retain) NSArray *priceEvents;
@property NSTimeInterval backwardsExtrapolationInterval;
@property NSTimeInterval forwardsExtrapolationInterval;
@property (retain) NSArray *appliedPriceEvents;


- (NSArray *) applyTo:(double) startingPrice from:(NSDate *) startDate to:(NSDate *) endDate;

// annual growth, trending forward (ie. using most recent data)
- (double) calcTrendGrowth;
- (double) calcTrendGrowthForTimeInterval:(NSTimeInterval) interval;

- (double) calcBackwardsTrendGrowth;

@end
