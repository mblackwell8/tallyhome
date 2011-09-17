//
//  THURLCreator.m
//  TallyHome
//
//  Created by Mark Blackwell on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THURLCreator.h"
#import "THAppDelegate.h"


@implementation THURLCreator

@synthesize tallyId = _tallyId, userId = _userId, city = _city, country = _country, countryCode, 
    shouldLocate, firstDate = _firstDt, lastDate = _lastDt;

- (id) init {
    if ((self = [super init])) {
        shouldLocate = NO;
        _tallyId = @"";
        _userId = @"";
        _city = @"";
        _country = @"";
        countryCode = 0;
        
    }
    
    return  self;
}

- (NSURL *)makeURL {
//    //TEMP
//    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/price_events.xml"];    
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    THAppDelegate *appD = [[UIApplication sharedApplication] delegate];
    NSString *cgiURLformat = [appD.appDefaults objectForKey:@"dataInterfaceURL"];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *firstDtStr = [dateFormatter stringFromDate:_firstDt];
    NSString *lastDtStr = [dateFormatter stringFromDate:_lastDt];
    
    //don't do core location yet...
    NSString *lat = @"", *lon = @"";
    
    NSString *urlStr = [NSString stringWithFormat:cgiURLformat,
                        _tallyId,
                        _userId,
                        lat, lon,
                        _city,
                        _country,
                        countryCode > 0 ? [NSString stringWithFormat:@"%d", countryCode] : @"",
                        firstDtStr, lastDtStr];
                        
    NSURL *url = [NSURL URLWithString:urlStr];
        
    return url;
}

@end
