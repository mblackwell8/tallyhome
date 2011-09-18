//
//  PricePath.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THHomePriceIndex.h"
#import "THTimeSeries.h"


@interface THHomePricePath : NSObject <NSXMLParserDelegate, NSCoding> {
    NSMutableArray *_serieses;
    //NSMutableArray *_manualPriceAdjustments;
    THDateVal *_buyPrice;
    
    //bitmasked
    THHomePriceIndexSource sources;
    THHomePriceIndexProximity proximities;
    
    //NSTimeInterval _trendExtrapolationInterval;
    
    NSString *_xmlCurrentIxName;
    NSString *_xmlCurrentIxProx;
    NSString *_xmlCurrentIxSource;
    NSMutableArray *_xmlIndices;
    THDateVal *_xmlAveragePrice;
    NSDateFormatter *_xmlDateFormatter;
    BOOL isReadingAvgPrice;
    NSDate *_lastServerUpdate;
}

@property (nonatomic, retain) NSArray *innerSerieses;
@property (nonatomic, assign) THHomePriceIndexSource sources;
@property (nonatomic, assign) THHomePriceIndexProximity proximities;
@property (nonatomic, retain) THDateVal *buyPrice;
@property (nonatomic, readonly, retain) NSDate *lastServerUpdate;

-(id)initWithXmlString:(NSString *)xml;
-(id)initWithURL:(NSURL *)url;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
//- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

- (THDateVal *)calcBestAveragePrice;
- (THDateVal *)calcBestAveragePriceFromSources:(int) srcs proximities:(int) proxs;
- (THTimeSeries *) makePricePath;
- (THTimeSeries *) makePricePathFromSources:(int) sources proximities:(int) proximities;

- (void) dealloc;

@end
