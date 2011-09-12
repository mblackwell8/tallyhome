//
//  THURLCreator.h
//  TallyHome
//
//  Created by Mark Blackwell on 26/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// the server side responds to an HTTP GET
// query string may include:
// tallyID=
// userID=
// lat=
// long=
// city=
// ctry=
// ctryCode=
// firstDt=
// lastDt=

//http://tallyho.me/data?tallyID=%@&userID=%@&lat=%@&lon=%@&city=%@&country=%@&ctryCode=%@&firstDt=%@&lastDt=%@

// this URL can be sent to the THPricePath initializer




@interface THURLCreator : NSObject {
    NSString *_tallyId;
    NSString *_userId;
    
    BOOL shouldLocate;
    
    NSString *_city;
    NSString *_country;
    int countryCode;
    
    NSDate *_firstDt, *_lastDt;
    
}

@property (nonatomic, copy) NSString *tallyId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property int countryCode;
@property BOOL shouldLocate;
@property (nonatomic, copy) NSDate *firstDate, *lastDate;

- (NSURL *)makeURL;

@end
