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
// dataId=
// userId=
// lat=
// long=
// city=
// ctry=
// ctryCode=
// firstDt=
// lastDt=

// this URL can be sent to the THPricePath initializer




@interface THURLCreator : NSObject {
    NSString *_dataId;
    NSString *_userId;
    
    BOOL shouldLocate;
    
    NSString *_city;
    NSString *_country;
    int countryCode;
    
}

@property (copy) NSString *dataId;
@property (copy) NSString *userId;
@property (copy) NSString *city;
@property (copy) NSString *country;
@property int countryCode;
@property BOOL shouldLocate;

- (NSURL *)makeURL;

@end
