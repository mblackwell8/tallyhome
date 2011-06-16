//
//  PricePath.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PricePath.h"


@implementation PricePath

@synthesize sources;
@synthesize proximities;
@synthesize innerIndexes = _indexes;

- (id) init {
    if ((self = [super init])) {
        sources = TH_Source_AllKnown;
        proximities = TH_Proximity_AllKnown;
        _indexes = [[NSMutableArray alloc] init];
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
        if (_xmlIndices) {
            [_xmlIndices release];
            _xmlIndices = nil;
        }
        
        _xmlIndices = [[NSMutableArray alloc] init];
        return;
    }
    
    if ([elementName isEqualToString:@"Index"]) {
        _xmlCurrentIxName = [attributeDict valueForKey:@"name"];
        _xmlCurrentIxProx = [attributeDict valueForKey:@"prox"];
        _xmlCurrentIxSource = [attributeDict valueForKey:@"sourceType"];
        
        return;
    }
    
    if ([elementName isEqualToString:@"Indice"]) {
                
        if (!_xmlDateFormatter) {
            _xmlDateFormatter = [[NSDateFormatter alloc] init];
            [_xmlDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            [_xmlDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        }
        
        NSString *dateStr = [attributeDict valueForKey:@"date"];
        NSDate *date = [_xmlDateFormatter dateFromString:dateStr];
        
        NSString *valStr = [attributeDict valueForKey:@"value"];
        double val = [valStr doubleValue];
        THIndice *i = [[THIndice alloc] initWithVal:val at:date];
                
        [_xmlIndices addObject:i];
        
        return;
    }
    
    return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Found end element: %@", elementName);
    // ignore root and empty elements
    if ([elementName isEqualToString:@"Index"]) {
        //sort the price events by date
        [_xmlIndices sortUsingSelector:@selector(compareByDate:)];
        HomePriceIndex *hpi = [[HomePriceIndex alloc] initWithIndices:_xmlIndices];
        hpi.proximityStr = _xmlCurrentIxProx;
        hpi.sourceTypeStr = _xmlCurrentIxSource;
        
        [_indexes addObject:hpi];
        
        [hpi release];
        [_xmlIndices release];
        _xmlIndices = nil;
        
        return;
        
    }
    
    if ([elementName isEqualToString:@"Indexes"]) {
        [_xmlDateFormatter release];
        _xmlDateFormatter = nil;
        
        return;
        
    }
    
    return;
}

- (THIndex *) makeSubsetIndex {
    return [self makeSubsetIndexFromSources:sources proximities:proximities];
}

// computes an equally weighted index from the specified sources and proximities
- (THIndex *) makeSubsetIndexFromSources:(int) srcs proximities:(int) proxs {
    if (_indexes.count == 1)
        return [_indexes objectAtIndex:0];
    
    NSDate *firstDt = nil, *lastDt = nil;
    NSMutableArray *relevantIndexes = [[NSMutableArray alloc] initWithCapacity:_indexes.count];
    for (HomePriceIndex *hpi in _indexes) {
        if ((hpi.src & srcs) &&
            (hpi.prox & proxs)) {
            [relevantIndexes addObject:hpi];
            if (!firstDt || [firstDt timeIntervalSinceDate:[[hpi objectAtIndex:0] date]] < 0)
                firstDt = [[hpi objectAtIndex:0] date];
            if (!lastDt || [lastDt timeIntervalSinceDate:[[hpi lastObject] date]] > 0)
                lastDt = [[hpi lastObject] date];
        }
    }
    
    if (relevantIndexes.count == 0)
        return nil;
    if (relevantIndexes.count == 1)
        return [relevantIndexes objectAtIndex:0];
    
    NSAssert(firstDt, @"First date not set");
    NSAssert(lastDt, @"Last date not set");
    
    THIndice *currIndice = [[THIndice alloc] initWithVal:100.0 at:firstDt];
    NSMutableArray *subset = [[NSMutableArray alloc] init];
    [subset addObject:currIndice];
    NSDate *currDt = firstDt;
    double lastRoc;
    while ([currDt timeIntervalSinceDate:lastDt] <= 0) {
        double roc = 0.0;
        for (HomePriceIndex *hpi in relevantIndexes) {
            roc += [hpi dailyRateOfChangeAt:currDt];
        }
        roc /= relevantIndexes.count;
        if (roc != lastRoc) {
            NSDate *lastDt = [currDt dateByAddingTimeInterval:-24.0*60*60];
            double numDays = [THIndex daysFrom:currIndice.date to:lastDt];
            NSAssert(numDays > 0.0, @"ERROR");
            double newVal = currIndice.val * pow((1.0 + lastRoc), numDays);
            [currIndice release];
            currIndice = [[THIndice alloc] initWithVal:newVal at:lastDt];
            [subset addObject:currIndice];
        }
        
        currDt = [currDt dateByAddingTimeInterval:(24.0 * 60 * 60)];
    }
    
    [currIndice release];
    [relevantIndexes release];
        
    [subset sortUsingSelector:@selector(compareByDate:)];
    HomePriceIndex *retVal = [[HomePriceIndex alloc] initWithIndices:subset];
    [subset release];
    
    retVal.prox = proxs;
    retVal.src = srcs;
    
    return [retVal autorelease];
}

- (void) dealloc {
    [_indexes release];
    _indexes = nil;
    
    [super dealloc];
}


@end
