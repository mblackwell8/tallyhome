//
//  THPlaceName.h
//  TH
//
//  Created by Mark Blackwell on 24/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface THPlaceName : NSObject <NSCoding, NSCopying> {
    NSString *_city, *_state, *_country;
    CLLocation* _location;
}

@property (nonatomic, copy, readonly) NSString *city, *state, *country;
@property (nonatomic, retain) CLLocation *location;

- (id)initWithCity:(NSString *)city state:(NSString *)state country:(NSString *)country;
- (BOOL)hasOneOrMoreNamesMatching:(NSString *)place;

- (id)copyWithZone:(NSZone *)zone;

+ (NSArray *)sharedPlaceNames;
+ (NSArray *)loadPlaceNamesFromFileAt:(NSString *)path;

- (BOOL)isEqual:(id)anObject;
- (BOOL)isEqualToPlaceName:(THPlaceName *)other;
- (NSUInteger)hash;

- (NSString *)description;
- (NSString *)shortDescription;

- (NSComparisonResult)compareByDescription:(THPlaceName *)another;

@end
