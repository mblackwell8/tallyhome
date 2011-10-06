//
//  THURLCreator.m
//  TallyHome
//
//  Created by Mark Blackwell on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THURLCreator.h"
#import "THAppDelegate.h"
#import "DebugMacros.h"

@implementation THURLCreator

@synthesize tallyId = _tallyId, userId = _userId, location = _location, countryCode, 
    firstDate = _firstDt, lastDate = _lastDt;

- (id) init {
    if ((self = [super init])) {
        _tallyId = @"";
        _userId = @"";
        _location = [[THPlaceName alloc] initWithCity:@"" state:@"" country:@""];
        countryCode = 0;
        
    }
    
    return  self;
}

- (NSURL *)makeURL {
//    //TEMP
//    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/price_events.xml"];    
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    THAppDelegate *appD = [[UIApplication sharedApplication] delegate];
    
    //http://data.tallyho.me/v1/data?tallyID=%@&userID=%@&lat=%@&lon=%@&city=%@&state=%@&country=%@&ctryCode=%@&firstDt=%@&lastDt=%@
    NSString *cgiURLformat = [appD.appDefaults objectForKey:@"dataInterfaceURL"];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *firstDtStr = _firstDt ? [dateFormatter stringFromDate:_firstDt] : @"";
    NSString *lastDtStr = _lastDt ? [dateFormatter stringFromDate:_lastDt] : @"";
    
    NSString *lat = @"", *lon = @"";
    lat = [NSString stringWithFormat:@"%7.5f", _coordinate.latitude];
    lon = [NSString stringWithFormat:@"%7.5f", _coordinate.longitude];
    
    NSString *urlStr = [NSString stringWithFormat:cgiURLformat,
                        _tallyId,
                        _userId,
                        lat, lon,
                        _location.city,
                        _location.state,
                        _location.country,
                        countryCode > 0 ? [NSString stringWithFormat:@"%d", countryCode] : @"",
                        firstDtStr, lastDtStr];
                        
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
    return url;
}

@end

