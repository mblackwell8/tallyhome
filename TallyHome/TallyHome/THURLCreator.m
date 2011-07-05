//
//  THURLCreator.m
//  TallyHome
//
//  Created by Mark Blackwell on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THURLCreator.h"


@implementation THURLCreator

@synthesize dataId = _dataId, userId = _userId, city = _city, country = _country, countryCode, shouldLocate;

- (id) init {
    if ((self = [super init])) {
        shouldLocate = NO;
    }
    
    return  self;
}

- (NSURL *)makeURL {
    //TEMP
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/price_events.xml"];    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppDefaults" ofType:@"plist"];
//    NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:path];
//    
//    
//    [defaults release];
    
    return [url autorelease];
}

@end
