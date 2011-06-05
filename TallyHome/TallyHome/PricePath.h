//
//  PricePath.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Indice.h"

#define TH_OneYearTimeInterval      365 * 24 * 60 * 60
#define TH_FiveYearTimeInterval     365 * 24 * 60 * 60 * 5
#define TH_TenYearTimeInterval      365 * 24 * 60 * 60 * 10


@interface PricePath : NSObject <NSXMLParserDelegate> {
    NSArray *indices;
    NSTimeInterval backwardsExtrapolationInterval;
    NSTimeInterval forwardsExtrapolationInterval;
    
    //bitmasked
    int sources;
    int proximities;
    
    NSMutableArray *appliedIndices;
    
    NSString *xmlCurrentIxName;
    NSString *xmlCurrentIxProx;
    NSString *xmlCurrentIxSource;
    NSMutableArray *xmlIndices;
    Indice *xmlIndice;
    NSMutableString *xmlChars;
    NSDateFormatter *xmlDateFormatter;
}

@property (retain) NSArray *indices;
@property NSTimeInterval backwardsExtrapolationInterval;
@property NSTimeInterval forwardsExtrapolationInterval;
@property (retain) NSMutableArray *appliedIndices;
@property int sources;
@property int proximities;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;



- (NSArray *) applyPathFrom:(NSDate *) startDate to:(NSDate *) endDate;

// annual growth, trending forward (ie. using most recent data)
- (double) calcTrendGrowth;
- (double) calcTrendGrowthForTimeInterval:(NSTimeInterval) interval;

- (double) calcBackwardsTrendGrowth;

- (int) indexOfFirstEventBeforeDate:(NSDate *) date;


@end
