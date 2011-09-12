//
//  Indice.h
//  TallyHome
//
//  Created by Mark Blackwell on 5/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THTimeSeries.h"

#define TH_Proximity_City_Str @"City"
#define TH_Proximity_State_Str @"State"
#define TH_Proximity_Country_Str @"Country"
#define TH_Proximity_Global_Str @"Global"

#define TH_Source_Govt_Str @"Govt"
#define TH_Source_Branded_Str @"Branded"
#define TH_Source_Other_Str @"Other"
//
//#define TH_Proximity_City       1
//#define TH_Proximity_State      2
//#define TH_Proximity_Country    4
//#define TH_Proximity_Global     8
//
//
//#define TH_Source_Govt          1
//#define TH_Source_Agency        2
//#define TH_Source_Other         4
//

typedef enum { 
    THHomePriceIndexProximityUnknown = 256,
    THHomePriceIndexProximityCity = 1, 
    THHomePriceIndexProximityState = 2, 
    THHomePriceIndexProximityCountry = 4, 
    THHomePriceIndexProximityGlobal = 8
} THHomePriceIndexProximity;
#define THHomePriceIndexProximityAllKnown        15

typedef enum { 
    THHomePriceIndexSourceUnknown = 256, 
    THHomePriceIndexSourceGovt = 1, 
    THHomePriceIndexSourceBranded = 2, 
    THHomePriceIndexSourceOther = 4 
} THHomePriceIndexSource;
#define THHomePriceIndexSourceAllKnown           7


@interface THHomePriceIndex : THTimeSeries <NSCoding, NSCopying> {

    THHomePriceIndexProximity prox;
    NSString *proximityStr;
    THHomePriceIndexSource src;
    NSString *sourceTypeStr;
    
    THDateVal *_avgPrice;
}

@property THHomePriceIndexProximity prox;
@property (nonatomic, copy) NSString *proximityStr;
@property THHomePriceIndexSource src;
@property (nonatomic, copy) NSString *sourceTypeStr;
@property (nonatomic, copy) THDateVal *averagePrice;

- (id)copyWithZone:(NSZone *)zone;

- (int)relevanceScore;

- (NSString *)description;

@end
