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

@synthesize averagePrice = _avgPrice;

#define kProxCoder  @"Prox"
#define kSrcCoder   @"Src"

- (id)initWithCoder:(NSCoder *)decoder {
    THHomePriceIndexProximity p = [decoder decodeIntForKey:kProxCoder];
    THHomePriceIndexSource s = [decoder decodeIntForKey:kSrcCoder];
    
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
        prox = THHomePriceIndexProximityCity;
    else if ([proxStr isEqualToString:TH_Proximity_State_Str])
        prox = THHomePriceIndexProximityState;
    else if ([proxStr isEqualToString:TH_Proximity_Country_Str])
        prox = THHomePriceIndexProximityCountry;
    else if ([proxStr isEqualToString:TH_Proximity_Global_Str])
        prox = THHomePriceIndexProximityGlobal;
    else
        prox = THHomePriceIndexProximityUnknown;
}

- (void)setSourceTypeStr:(NSString *)srcStr {
    if (sourceTypeStr)
        [sourceTypeStr release];
    sourceTypeStr = [srcStr copy];
    
    if ([srcStr isEqualToString:TH_Source_Govt_Str])
        src = THHomePriceIndexSourceGovt;
    else if ([srcStr isEqualToString:TH_Source_Branded_Str])
        src = THHomePriceIndexSourceBranded;
    else if ([srcStr isEqualToString:TH_Source_Other_Str])
        src = THHomePriceIndexSourceOther;
    else
        src = THHomePriceIndexSourceUnknown;
}

- (THHomePriceIndexProximity) prox {
    return prox;
}

- (void)setProx:(THHomePriceIndexProximity) p {
    prox = p;
    switch (p) {
        case THHomePriceIndexProximityCity:
            proximityStr = TH_Proximity_City_Str;
            break;
        case THHomePriceIndexProximityState:
            proximityStr = TH_Proximity_State_Str;
            break;
        case THHomePriceIndexProximityCountry:
            proximityStr = TH_Proximity_Country_Str;
            break;
        case THHomePriceIndexProximityGlobal:
            proximityStr = TH_Proximity_Global_Str;
            break;

        default:
            proximityStr = @"Unknown";
            break;
    }
}

- (THHomePriceIndexSource) src {
    return src;
}

- (void)setSrc:(THHomePriceIndexSource) s {
    src = s;
    switch (s) {
        case THHomePriceIndexSourceGovt:
            sourceTypeStr = TH_Source_Govt_Str;
            break;
        case THHomePriceIndexSourceBranded:
            sourceTypeStr = TH_Source_Branded_Str;
            break;
        case THHomePriceIndexSourceOther:
            sourceTypeStr = TH_Source_Other_Str;
            break;
            
        default:
            sourceTypeStr = @"Unknown";
            break;
    }
}

- (int)relevanceScore {
    //basic implementation
    return prox * src;
}

- (void)dealloc {
    
    [super dealloc];
}

- (NSString *)description {
    return [super description];
}

@end
