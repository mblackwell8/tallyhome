//
//  PriceEvent.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PriceEvent.h"

@implementation PriceEvent

@synthesize date;
@synthesize last;
@synthesize impactSinceLast;
@synthesize proximity;
@synthesize sourceType;
@synthesize shouldIgnore;


- (NSComparisonResult)compareByDate:(PriceEvent *)anotherEvent {
    //if other event is null or has a null date, this event is considered later
    if (!anotherEvent || !(anotherEvent.date))
        return NSOrderedDescending;
    
    return [date compare:anotherEvent.date];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: impact=%5.2f, prox=%@, src=%@, ignore=%@", date, impactSinceLast, proximity, sourceType, shouldIgnore];
}

@end
