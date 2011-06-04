//
//  PricePath.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

struct PricePoint {
    NSDate *date;
    double price;
};

@interface PricePath : NSObject {
    NSArray *priceEvents;
    
    
}

@property NSArray *priceEvents;

- (NSArray *) applyTo:(double) startingPrice from:(NSDate *) startDate to:(NSDate *) endDate;

- (double) calcTrendGrowthForTimeInterval:(NSTimeInterval *) interval;

@end
