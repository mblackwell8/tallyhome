//
//  Indice.m
//  TallyHome
//
//  Created by Mark Blackwell on 5/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THHomePriceIndex.h"


@implementation THHomePriceIndex

//@synthesize proximityStr;
//@synthesize sourceTypeStr;

#define kProxCoder  @"Prox"
#define kSrcCoder   @"Src"

- (id)initWithCoder:(NSCoder *)decoder {
    Proximity p = [decoder decodeIntForKey:kProxCoder];
    Source s = [decoder decodeIntForKey:kSrcCoder];
    
    if ((self = [super initWithCoder:decoder])) {
        self.prox = p;
        self.src = s;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:prox forKey:kProxCoder];
    [encoder encodeInt:src forKey:kSrcCoder];
    
    [super encodeWithCoder:encoder];
}

- (id)copyWithZone:(NSZone *)zone {
    THHomePriceIndex *copy = [[THHomePriceIndex allocWithZone:zone] initWithValues:_innerSeries];
    copy.trendExtrapolationInterval = trendExtrapolationInterval;
    copy.prox = prox;
    copy.src = src;
    
    return copy;
}

- (NSString *)proximityStr {
    return proximityStr;
}

- (NSString *)sourceTypeStr {
    return sourceTypeStr;
}

- (void)setProximityStr:(NSString *)proxStr {
    if (proximityStr)
        [proximityStr release];
    proximityStr = [proxStr copy];
    
    if ([proxStr isEqualToString:TH_Proximity_City_Str])
        prox = City;
    else if ([proxStr isEqualToString:TH_Proximity_State_Str])
        prox = State;
    else if ([proxStr isEqualToString:TH_Proximity_Country_Str])
        prox = Country;
    else if ([proxStr isEqualToString:TH_Proximity_Global_Str])
        prox = Global;
    else
        prox = UnknownProximity;
}

- (void)setSourceTypeStr:(NSString *)srcStr {
    if (sourceTypeStr)
        [sourceTypeStr release];
    sourceTypeStr = [srcStr copy];
    
    if ([srcStr isEqualToString:TH_Source_Govt_Str])
        src = Govt;
    else if ([srcStr isEqualToString:TH_Source_Agency_Str])
        src = Agency;
    else if ([srcStr isEqualToString:TH_Source_Other_Str])
        src = Other;
    else
        src = UnknownSource;
}

- (Proximity) prox {
    return prox;
}

- (void)setProx:(Proximity) p {
    prox = p;
    switch (p) {
        case City:
            proximityStr = TH_Proximity_City_Str;
            break;
        case State:
            proximityStr = TH_Proximity_State_Str;
            break;
        case Country:
            proximityStr = TH_Proximity_Country_Str;
            break;
        case Global:
            proximityStr = TH_Proximity_Global_Str;
            break;

        default:
            proximityStr = @"Unknown";
            break;
    }
}

- (Source) src {
    return src;
}

- (void)setSrc:(Source) s {
    src = s;
    switch (s) {
        case Govt:
            sourceTypeStr = TH_Source_Govt_Str;
            break;
        case Agency:
            sourceTypeStr = TH_Source_Agency_Str;
            break;
        case Other:
            sourceTypeStr = TH_Source_Other_Str;
            break;
            
        default:
            sourceTypeStr = @"Unknown";
            break;
    }
}

- (void)dealloc {
    
    [super dealloc];
}

@end
