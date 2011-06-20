//
//  THNSDate.m
//  TallyHome
//
//  Created by Mark Blackwell on 19/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THDate.h"


@implementation NSDate (THDate)

- (BOOL) isBefore:(NSDate *)date {
    return ([self timeIntervalSinceDate:date] < 0);
}
- (BOOL) isAfter:(NSDate *)date {
    return ([self timeIntervalSinceDate:date] > 0);
}
- (BOOL) isBeforeOrEqualTo:(NSDate *)date {
    return [self isBefore:date] || [self isEqualToDate:date];
}
- (BOOL) isAfterOrEqualTo:(NSDate *)date {
    return [self isAfter:date] || [self isEqualToDate:date];
}


- (NSDate *) addDays:(double)days {
    return [self dateByAddingTimeInterval:(TH_OneDayInSecs * days)];
}

- (NSDate *) addOneDay {
    return [self dateByAddingTimeInterval:(TH_OneDayInSecs)];
}

- (NSDate *) subtractOneDay {
    return [self dateByAddingTimeInterval:-(TH_OneDayInSecs)];
}

- (double) daysSince:(NSDate *)date {
    double daysBetween = [self timeIntervalSinceDate:date] / (TH_OneDayInSecs);
    
    return daysBetween;
}

- (double) daysUntil:(NSDate *)date {
    return -[self daysSince:date];
}


@end
