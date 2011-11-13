//
//  THURLCreator.h
//  TallyHome
//
//  Created by Mark Blackwell on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "THPlaceName.h"

// the server side responds to an HTTP GET
// query string may include:
// tallyID=
// userID=
// lat=
// long=
// city=
// state=
// ctry=
// ctryCode=
// firstDt=
// lastDt=

// this URL can be sent to the THPricePath initializer




@interface THURLCreator : NSObject <CLLocationManagerDelegate> {
    NSString *_tallyId;
    NSString *_userId;
    
    THPlaceName *_location;
    int countryCode;
    
    NSDate *_firstDt, *_lastDt;

//    BOOL shouldLocate;    
//    CLLocationManager *_locnMgr;
//    NSCondition *_locationFoundCondition;
//    BOOL _isLocationFound, _isLocationError;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic, copy) NSString *tallyId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, retain) THPlaceName *location;
@property (nonatomic, assign) int countryCode;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
//@property BOOL shouldLocate;
@property (nonatomic, copy) NSDate *firstDate, *lastDate;

- (NSURL *)makeURL;

@end
