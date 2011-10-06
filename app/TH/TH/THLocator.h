//
//  THLocator.h
//  TH
//
//  Created by Mark Blackwell on 28/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface  THLocator : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
}

+ (THLocator *)sharedInstance;

- (void)start;
- (void)stop;
- (BOOL)locationKnown;

@property (nonatomic, retain) CLLocation *currentLocation;

@end
