//
//  PricePath.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PricePath.h"


@implementation PricePath

@synthesize indices;
@synthesize backwardsExtrapolationInterval;
@synthesize forwardsExtrapolationInterval;
@synthesize subsetIndex;
@synthesize extrapolatedSubsetIndex;
@synthesize sources;
@synthesize proximities;

- (id) init {
    if ((self = [super init])) {
        backwardsExtrapolationInterval = TH_FiveYearTimeInterval;
        forwardsExtrapolationInterval = TH_FiveYearTimeInterval;
        sources = TH_Source_AllKnown;
        proximities = TH_Proximity_AllKnown;
    }
    
    return self;
}

- (id) initWithXmlString:(NSString *)xml {
    if ((self = [self init])) {
    
        NSData* data=[xml dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        [parser parse]; // return value not used
        // if not successful, delegate is informed of error
    }
    
    return self;
}

- (id) initWithURL:(NSURL *)url {
    if ((self = [self init])) {
        
        //NSLog(@"Commencing XML parse from %@", url);
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        [parser parse]; // return value not used
        // if not successful, delegate is informed of error
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"Found start element: %@", elementName);
    if ([elementName isEqualToString:@"Indexes"]) {
        if (xmlIndices) {
            [xmlIndices release];
            xmlIndices = nil;
        }
        
        xmlIndices = [[NSMutableArray alloc] init];
        return;
    }
    
    if ([elementName isEqualToString:@"Index"]) {
        xmlCurrentIxName = [attributeDict valueForKey:@"name"];
        xmlCurrentIxProx = [attributeDict valueForKey:@"prox"];
        xmlCurrentIxSource = [attributeDict valueForKey:@"sourceType"];
        
        return;
    }
    
    if ([elementName isEqualToString:@"Indice"]) {
        Indice *lastIndice = xmlIndice;
        xmlIndice = [[Indice alloc] init];
        xmlIndice.ixName = xmlCurrentIxName;
        
        if (!xmlDateFormatter) {
            xmlDateFormatter = [[NSDateFormatter alloc] init];
            [xmlDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [xmlDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        
        NSString *dateStr = [attributeDict valueForKey:@"date"];
        NSDate *date = [xmlDateFormatter dateFromString:dateStr];
        xmlIndice.date = date;
        xmlIndice.proximityStr = xmlCurrentIxProx;
        xmlIndice.sourceTypeStr = xmlCurrentIxSource;
        
        NSString *valStr = [attributeDict valueForKey:@"value"];
        xmlIndice.val = [valStr doubleValue];
        xmlIndice.last = lastIndice;
        
        [xmlIndices addObject:xmlIndice];
        
        if (lastIndice)
            [lastIndice release];
        
        return;
    }
    
    return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Found end element: %@", elementName);
    // ignore root and empty elements
    if ([elementName isEqualToString:@"Indexes"]) {
        //sort the price events by date
        indices = [xmlIndices sortedArrayUsingSelector:@selector(compareByDate:)];
        
        [xmlDateFormatter release];
        xmlDateFormatter = nil;
        
        [xmlIndices release];
        xmlIndices = nil;
        
        return;
        
    }
    
    return;
}

- (NSArray *) makeSubsetIndex {
    return [self makeSubsetIndexFromSources:sources proximities:proximities];
}
- (NSArray *) makeSubsetIndexFromSources:(int) srcs proximities:(int) proxs {
    if (subsetIndex) {
        [subsetIndex release];
    }
    
    self.subsetIndex = [[NSMutableArray alloc] init];
    
    for (Indice *i in indices) {
        if ((i.src & srcs) &&
            (i.prox & proxs)) {
            [subsetIndex addObject:i];
        }
    }
    
    return subsetIndex;
}

- (NSArray *) makeExtrapolatedSubsetIndexFrom:(NSDate *) startDate to:(NSDate *) endDate {
    if (extrapolatedSubsetIndex)
        [extrapolatedSubsetIndex release];
    
    self.extrapolatedSubsetIndex = [[NSMutableArray alloc] initWithArray:[self makeSubsetIndex]];
    
    //if startDate is earlier than the first date in the PricePath then extrapolate backwards
    int index = 0;
    Indice *first = [extrapolatedSubsetIndex objectAtIndex:index];
    if ([startDate timeIntervalSinceDate:first.date] < 0) {
        Indice *newFirst = [[Indice alloc] init];
        newFirst.date = startDate;
        newFirst.sourceTypeStr = TH_Source_Extrapolated;
        newFirst.prox = proximities;
        
        double periodInDays = [first.date timeIntervalSinceDate:newFirst.date] / (24.0 * 60 * 60);
        newFirst.val = first.val * (1 + [self calcBackwardsTrendGrowth]) * periodInDays / 365.0;
        
        [extrapolatedSubsetIndex insertObject:newFirst atIndex:0];
        [newFirst release];
    }
    else if ([startDate timeIntervalSinceDate:first.date] > 0) {
        //else remove the price event before the start date
        NSLog(@"Interpolating subset index not implemented");
    }
    else {
        //do nothing
    }
        
    //HACK: does not handle (unusual) case where the requested endDate doesn't need to be extrapolated
    if ([endDate timeIntervalSinceDate:[[extrapolatedSubsetIndex lastObject] date]] < 0)
        NSLog(@"Interpolating subset index not implemented");
    
    //if endDate is later than last date then extrapolate forwards
    Indice *last = [extrapolatedSubsetIndex lastObject];
    if ([endDate timeIntervalSinceDate:last.date] > 0) {
        Indice *newLast = [[Indice alloc] init];
        newLast.date = endDate;
        newLast.sourceTypeStr = TH_Source_Extrapolated;
        newLast.prox = proximities;
        
        double periodInDays = [newLast.date timeIntervalSinceDate:last.date] / (24.0 * 60 * 60);
        newLast.val = last.val * (1 + [self calcTrendGrowth]) * periodInDays / 365.0;
        
        [extrapolatedSubsetIndex addObject:newLast];
        [newLast release];
    }
    
    return extrapolatedSubsetIndex;
}

- (double) calcTrendGrowth {
    return [self calcTrendGrowthForTimeInterval: forwardsExtrapolationInterval];
}

- (double) calcTrendGrowthForTimeInterval:(NSTimeInterval) interval {
    // find the closest price event, interval ago
    NSDate *now = [NSDate date];
    NSDate *ago = [now dateByAddingTimeInterval:-interval];
    int trendIx = [self indexOfFirstEventBeforeDate:ago];
    
    trendIx = (trendIx == indices.count ? trendIx - 2 : trendIx);
    
    double totalGrowth = 0.0;
    int index = trendIx;
    while (index < indices.count) {
        PriceEvent *ev = [indices objectAtIndex:index];
        totalGrowth = (1.0 + totalGrowth) * (1.0 + ev.impactSinceLast) - 1.0;
        index += 1;
    }
    
    PriceEvent *last = [indices lastObject];
    PriceEvent *trend = [indices objectAtIndex:trendIx];
    double daysBetween = [last.date timeIntervalSinceDate:trend.date] / (24.0 * 60 * 60);
    
    //HACK: linear approximation of geometric growth
    double annualisedGrowth = totalGrowth * 365.0 / daysBetween;
    
    [now release];
    
    return annualisedGrowth;
}

- (double) calcBackwardsTrendGrowth {
    
    
    return 0.0;
}

- (int) indexOfFirstEventBeforeDate:(NSDate *)date {
    int index = 0;
    while ((index + 1) < indices.count) {
        // will fail if price events are not in order
        PriceEvent *first = [indices objectAtIndex:index];
        PriceEvent *second = [indices objectAtIndex:(index + 1)];
        NSAssert(first && second &&
                 [second.date timeIntervalSinceDate:first.date] > 0, @"PricePath events out of order");
        if ([first.date timeIntervalSinceDate:date] < 0 &&
            [second.date timeIntervalSinceDate:date] >= 0) {
            break;
        }
        index += 1;
    }
    
    return index;

}


@end
