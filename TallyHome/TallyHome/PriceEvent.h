//
//  PriceEvent.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PriceEvent : NSObject {
    NSDate *date;
    double impact;
    NSString *proximity;
    NSString *sourceType;
    BOOL shouldIgnore;
}

@property NSDate *date;
@property double impact;
@property NSString *proximity;
@property NSString *sourceType;
@property BOOL shouldIgnore;

@end
