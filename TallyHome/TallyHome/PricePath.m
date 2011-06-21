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
        
        return;
    }
    
    if ([elementName isEqualToString:@"Index"]) {
        _xmlCurrentIxName = [attributeDict valueForKey:@"name"];
        _xmlCurrentIxProx = [attributeDict valueForKey:@"prox"];
        _xmlCurrentIxSource = [attributeDict valueForKey:@"sourceType"];
        
        if (_xmlIndices) {
            [_xmlIndices release];
            _xmlIndices = nil;
        }
        
        _xmlIndices = [[NSMutableArray alloc] init];
        
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
    
    NSDate *firstDt = nil, *finalDt = nil;
    NSMutableArray *relevantIndexes = [[NSMutableArray alloc] initWithCapacity:_indexes.count];
    for (HomePriceIndex *hpi in _indexes) {
        if (hpi.count > 0 &&
            (hpi.src & srcs) &&
            (hpi.prox & proxs)) {
            [relevantIndexes addObject:hpi];
            if (!firstDt || [firstDt isAfter:[[hpi objectAtIndex:0] date]])
                firstDt = [[hpi objectAtIndex:0] date];
            if (!finalDt || [finalDt isAfter:[[hpi lastObject] date]])
                finalDt = [[hpi lastObject] date];
        }
    }
    
    if (relevantIndexes.count == 0)
        return nil;
    if (relevantIndexes.count == 1)
        return [relevantIndexes objectAtIndex:0];
    
    NSAssert(firstDt, @"First date not set");
    NSAssert(finalDt, @"Last date not set");
    
    NSMutableArray *subset = [[NSMutableArray alloc] init];
    NSDate *currDt = firstDt;
    double ixVal = 100.0;
    NSDate *lastIxDt = firstDt;
    double roc = 0.0;
    do {
        NSDate *tmDt = [currDt addOneDay];
        double tmRoc = 0.0;
        for (HomePriceIndex *hpi in relevantIndexes) {
            double thisRoc = [hpi dailyRateOfChangeAt:tmDt];
            //NSLog(@"RoC is %5.5f\%", thisRoc * 100.0);
            tmRoc += thisRoc;
        }  
        NSAssert(relevantIndexes.count > 0, @"Should have been checked above");
        tmRoc /= relevantIndexes.count;
        //NSLog(@"Av RoC is %5.5f\%", tmRoc * 100.0);
        if ([currDt isEqualToDate:firstDt] || 
            [currDt isEqualToDate:finalDt] ||
            tmRoc != roc) {
            double numDays = [lastIxDt daysUntil:currDt];
            NSAssert([currDt isEqualToDate:firstDt] || numDays > 0.0, @"ERROR");
            ixVal = ixVal * pow((1.0 + roc), numDays);
            THIndice *i = [[THIndice alloc] initWithVal:ixVal at:currDt];
            [subset addObject:i];
            [i release];
            
            lastIxDt = currDt;
        }
        currDt = tmDt;
        roc = tmRoc;
    } while ([currDt isBeforeOrEqualTo:finalDt]);
    
    
    
//    THIndice *lastIndice = [[THIndice alloc] initWithVal:100.0 at:firstDt];
//    NSMutableArray *subset = [[NSMutableArray alloc] init];
//    [subset addObject:lastIndice];
//    NSDate *currDt = [firstDt addOneDay];
//    double lastRoc = 0.0;
//    BOOL lastRocCalced = NO;
//    while ([currDt isBeforeOrEqualTo:finalDt]) {
//        double roc = 0.0;
//        for (HomePriceIndex *hpi in relevantIndexes) {
//            double thisRoc = [hpi dailyRateOfChangeAt:currDt];
//            //NSLog(@"RoC is %5.5f\%", thisRoc * 100.0);
//            roc += thisRoc;
//        }
//        NSAssert(relevantIndexes.count > 0, @"Should have been checked above");
//        roc /= relevantIndexes.count;
//        //NSLog(@"Av RoC is %5.5f\%", roc * 100.0);
//        if (lastRocCalced && roc != lastRoc) {
//            NSDate *yday = [currDt subtractOneDay];
//            double numDays = [lastIndice.date daysUntil:yday];
//            NSAssert(numDays > 0.0, @"ERROR");
//            double newVal = lastIndice.val * pow((1.0 + lastRoc), numDays);
//            [lastIndice release];
//            lastIndice = [[THIndice alloc] initWithVal:newVal at:yday];
//            [subset addObject:lastIndice];
//        }
//        
//        lastRoc = roc;
//        lastRocCalced = YES;
//        currDt = [currDt addOneDay];
//    }
//    
//    [lastIndice release];
//    [relevantIndexes release];
        
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
