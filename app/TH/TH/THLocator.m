//
//  THLocator.m
//  TH
//
//  Created by Mark Blackwell on 28/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THLocator.h"
#import "DebugMacros.h"

@implementation THLocator

@synthesize currentLocation = _currentLocation;

static THLocator *_sharedInstance;

+ (THLocator *)sharedInstance {
    @synchronized(self) {
        if(!_sharedInstance)
            _sharedInstance= [[THLocator alloc] init];       
    }
    return _sharedInstance;
}

+ (id)alloc {
    @synchronized(self) {
        NSAssert(_sharedInstance == nil, @"Attempted to allocate a second instance of a singleton.");
        _sharedInstance = [super alloc];
    }
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _currentLocation = [[CLLocation alloc] init];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [self start];
    }
    return self;
}

- (void)start {
    [_locationManager startUpdatingLocation];
}

- (void)stop {
    [_locationManager stopUpdatingLocation];
}

- (BOOL)locationKnown { 
    if (round(_currentLocation.speed) == -1) 
        return NO;
    
    return YES; 
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if (abs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) < 120) {     
        self.currentLocation = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                       message:[error description] 
                                      delegate:nil cancelButtonTitle:@"OK" 
                             otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void) dealloc {
    [_locationManager release];
    [_currentLocation release];
    [super dealloc];
}


@end

#ifdef DEBUG

@implementation CLLocationManager (TemporaryHack)

+ (BOOL)locationServicesEnabled {
    return YES;
}
- (void)hackLocationFix {
    //sydney is -33.8667,151.2000
    DLog(@"hackLocation fix called...");
    CLLocation *location = [[CLLocation alloc] initWithLatitude:-33.8667 longitude:151.2];
    [[self delegate] locationManager:self didUpdateToLocation:location fromLocation:nil];     
}
- (void)startUpdatingLocation {
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}
@end

#endif

