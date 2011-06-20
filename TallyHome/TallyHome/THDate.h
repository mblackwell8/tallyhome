//
//  THNSDate.h
//  TallyHome
//
//  Created by Mark Blackwell on 19/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TH_OneDayInSecs 86400.0 //24.0 * 60.0 * 60.0

@interface NSDate (THDate)

- (BOOL) isBefore:(NSDate *)date;
- (BOOL) isAfter:(NSDate *)date;
- (BOOL) isBeforeOrEqualTo:(NSDate *)date;
- (BOOL) isAfterOrEqualTo:(NSDate *)date;

- (NSDate *) addDays:(double)days;
- (NSDate *) addOneDay;
- (NSDate *) subtractOneDay;

- (double) daysSince:(NSDate *)date;
- (double) daysUntil:(NSDate *)date;

@end
