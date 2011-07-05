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

#define TH_Source_Govt_Str @"Government"
#define TH_Source_Agency_Str @"Agency"
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

typedef enum { UnknownProximity = 0, City=1, State=2, Country=4, Global=8 } Proximity;
#define TH_Proximity_AllKnown        15

typedef enum { UnknownSource = 0, Govt=1, Agency=2, Other=4 } Source;
#define TH_Source_AllKnown           7


@interface THHomePriceIndex : THTimeSeries <NSCoding> {

    Proximity prox;
    NSString *proximityStr;
    Source src;
    NSString *sourceTypeStr;
}

@property Proximity prox;
@property (copy) NSString *proximityStr;
@property Source src;
@property (copy) NSString *sourceTypeStr;


- (NSString *)description;

@end
