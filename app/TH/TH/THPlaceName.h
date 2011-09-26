//
//  THPlaceName.h
//  TH
//
//  Created by Mark Blackwell on 24/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THPlaceName : NSObject <NSCoding> {
    NSString *_city, *_state, *_country;
}

@property (nonatomic, retain, readonly) NSString *city, *state, *country;

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
