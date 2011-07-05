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
    NSArray *_serieses;
    NSArray *_manualPriceAdjustments;
    THDateVal *_buyPrice;
    
    //bitmasked
    int sources;
    int proximities;
    
    NSString *_xmlCurrentIxName;
    NSString *_xmlCurrentIxProx;
    NSString *_xmlCurrentIxSource;
    NSMutableArray *_xmlIndices;
    NSDateFormatter *_xmlDateFormatter;
}

@property (nonatomic, retain) NSArray *innerSerieses;
@property int sources;
@property int proximities;
@property (nonatomic, retain) NSArray *manualPriceAdjustments;
@property (nonatomic, retain) THDateVal *buyPrice;

-(id)initWithXmlString:(NSString *)xml;
-(id)initWithURL:(NSURL *)url;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;


- (THTimeSeries *) makePricePath;
- (THTimeSeries *) makePricePathFromSources:(int) sources proximities:(int) proximities;

- (void) dealloc;

@end
