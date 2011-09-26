//
//  THPlaceName.m
//  TH
//
//  Created by Mark Blackwell on 24/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THPlaceName.h"
#import "THAppDelegate.h"

@implementation THPlaceName


+ (NSArray *)loadPlaceNamesFromFileAt:(NSString *)path {
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *placeNames = [[NSMutableArray alloc] init];
    for (NSString *line in [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        
        NSArray *parts = [line componentsSeparatedByString:@","];
        // has city, state, country, latlon
        if (parts.count >= 3) {
            THPlaceName *pn = [[THPlaceName alloc] initWithCity:[[parts objectAtIndex:0]
                                                                 stringByReplacingOccurrencesOfString:@"\"" withString:@""] 
                                                          state:[[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\"" withString:@""]
                                                        country:[[parts objectAtIndex:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
            [placeNames addObject:pn];
            [pn release];
        }
    }
    
    [placeNames sortUsingSelector:@selector(compareByDescription:)];
    
    return [placeNames autorelease];
}

static NSArray *placeNamesFromFile;

+ (NSArray *)sharedPlaceNames {
    THAppDelegate *appD = [[UIApplication sharedApplication] delegate];
    NSString *fileName = [appD.appDefaults objectForKey:@"placeNamesFile"];
    
    if (!placeNamesFromFile) {
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:fileName];
        
        placeNamesFromFile = [[THPlaceName loadPlaceNamesFromFileAt:path] retain];
    }
    
    return placeNamesFromFile;
}


@synthesize city = _city, state = _state, country = _country;


- (id)initWithCity:(NSString *)city state:(NSString *)state country:(NSString *)country {
    self = [super init];
    if (self) {
        _city = [city retain];
        _state = [state retain];
        _country = [country retain];
    }
    
    return self;
}

#define kCity           @"City"
#define kState          @"State"
#define kCountry        @"Country"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_city forKey:kCity];
    [encoder encodeObject:_state forKey:kState];
    [encoder encodeObject:_country forKey:kCountry];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        if (!(_city = [[decoder decodeObjectForKey:kCity] retain])) {
            _city = @"";
        }
        if (!(_state = [[decoder decodeObjectForKey:kState] retain])) {
            _state = @"";
        }
        if (!(_country = [[decoder decodeObjectForKey:kCountry] retain])) {
            _country = @"";
        }
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    THPlaceName *copy = [[THPlaceName allocWithZone:zone] initWithCity:self.city 
                                                                 state:self.state 
                                                               country:self.country];
    //don't copy first, last or ix... these are mutable
    return copy;
}

- (void)dealloc {
    [super dealloc];
    
    [_city release];
    [_state release];
    [_country release];
}


- (BOOL)hasOneOrMoreNamesMatching:(NSString *)place {
    NSComparisonResult result = [_city compare:place 
                                       options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
                                         range:NSMakeRange(0, place.length)];
    if (result == NSOrderedSame) 
        return YES;
    
    result = [_state compare:place 
                     options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
                       range:NSMakeRange(0, place.length)];
    if (result == NSOrderedSame) 
        return YES;
    
    result = [_country compare:place 
                       options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
                         range:NSMakeRange(0, place.length)];
    if (result == NSOrderedSame) 
        return YES;
    
    return NO;
}

- (NSString *)description {
    //should deal with majority of situations...
    if (![_city isEqualToString:@""] && ![_state isEqualToString:@""] && ![_country isEqualToString:@""])
        return [NSString stringWithFormat:@"%@, %@, %@", _city, _state, _country];
    
    if (![_state isEqualToString:@""] && ![_country isEqualToString:@""])
        return [NSString stringWithFormat:@"%@, %@", _state, _country];
    
    if (![_country isEqualToString:@""])
        return _country;
    
    return [NSString stringWithFormat:@"%@, %@, %@", _city, _state, _country];
}

- (NSString *)shortDescription {
    if (![_city isEqualToString:@""])
        return _city;
    
    if (![_state isEqualToString:@""])
        return _state;
    
    if (![_country isEqualToString:@""])
        return _country;
    
    return @"Unknown";
}


- (BOOL)isEqual:(id)other{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToPlaceName:other];
}

- (BOOL)isEqualToPlaceName:(THPlaceName *)other {
    if (self == other)
        return YES;
    
    if ([_city isEqualToString:other.city] && [_state isEqualToString:other.state] && [_country isEqualToString:other.country])
        return YES;
    
    return NO;
}

- (NSUInteger)hash {
    int prime = 31;
    NSUInteger result = 1;
    
    //5 sig digits on val
    result = prime * result + [_city hash];
    result = prime * result + [_state hash];
    result = prime * result + [_country hash];

    
    return result;
}

- (NSComparisonResult)compareByDescription:(THPlaceName *)another {
    //if another is null this place is considered higher in sort order
    if (!another)
        return NSOrderedAscending;
    
    NSString *anotherDesc = [another description];
    if ([anotherDesc isEqualToString:@""])
        return NSOrderedAscending;
    
    return [[self description] compare:anotherDesc];
}




@end
