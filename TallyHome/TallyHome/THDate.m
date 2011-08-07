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

+ (NSDate *) localDateFromString:(NSString *)dateStr {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterNoStyle];
    [df setDateStyle:NSDateFormatterShortStyle];
    [df setLocale:[NSLocale currentLocale]];
    NSDate *retVal = [df dateFromString:dateStr];
    [df release];
    
    return retVal;
}

@end

@implementation NSDate (Fuzzy)

- (NSString *)fuzzyRelativeDateString {
    return [self fuzzyRelativeDateString:[NSDate date]];
}

- (NSString *)fuzzyRelativeDateString:(NSDate *)compareDt {
    // works on relatively large increments (number of years)
    NSTimeInterval interval = [self timeIntervalSinceDate:compareDt];
    NSInteger nYears = (NSInteger)round(interval / (TH_OneDayInSecs * 365.0));
    if (nYears > 1) {
        return [NSString stringWithFormat:@"%d years from now", nYears];
    }
    else if (nYears == 1) {
        return @"One year from now";
    }
    else if (nYears == -1) {
        return @"One year ago";
    }
    else if (nYears < -1) {
        return [NSString stringWithFormat:@"%d years ago", -nYears];
    }
    //else
    return @"Now";
}

@end
