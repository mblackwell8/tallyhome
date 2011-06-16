//
//  PricePath.h
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomePriceIndex.h"
#import "THIndex.h"


@interface PricePath : NSObject <NSXMLParserDelegate> {
    NSArray *_indexes;
    
    //bitmasked
    int sources;
    int proximities;
    
    NSString *_xmlCurrentIxName;
    NSString *_xmlCurrentIxProx;
    NSString *_xmlCurrentIxSource;
    NSMutableArray *_xmlIndices;
    NSDateFormatter *_xmlDateFormatter;
}

@property (retain) NSArray *innerIndexes;
@property int sources;
@property int proximities;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;


- (THIndex *) makeSubsetIndex;
- (THIndex *) makeSubsetIndexFromSources:(int) sources proximities:(int) proximities;

- (void) dealloc;

@end
