//
//  PriceEvent.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TH_SOURCETYPE_EXTRAPOLATED @"Extrapolated"

@interface PriceEvent : NSObject {
    NSDate *date;
    PriceEvent *last;
    
    //for first PriceEvent in collection this is ignored and last is null
    double impactSinceLast;
    NSString *proximity;
    NSString *sourceType;
    BOOL shouldIgnore;
}

@property (retain) NSDate *date;
@property (retain) PriceEvent *last;
@property double impactSinceLast;
@property (copy) NSString *proximity;
@property (copy) NSString *sourceType;
@property BOOL shouldIgnore;

- (NSComparisonResult)compareByDate:(PriceEvent *)anotherEvent;

@end
