//
//  PricePath.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THHomePricePath.h"
#import "DebugMacros.h"

@interface THHomePricePath ()

@property (nonatomic, retain) NSString *xmlCurrentIxName, *xmlCurrentIxProx, *xmlCurrentIxSource;
@property (nonatomic, retain) NSMutableArray *xmlIndices;
@property (nonatomic, retain) THDateVal *xmlAveragePrice;
@property (nonatomic, retain) NSDateFormatter *xmlDateFormatter;
    
@end

@implementation THHomePricePath

@synthesize sources;
@synthesize proximities;
@synthesize innerSerieses = _serieses;
@synthesize manualPriceAdjustments = _manualPriceAdjustments;
@synthesize buyPrice = _buyPrice;


@synthesize xmlCurrentIxName = _xmlCurrentIxName, xmlCurrentIxProx = _xmlCurrentIxProx, xmlCurrentIxSource = _xmlCurrentIxSource, xmlIndices = _xmlIndices, xmlAveragePrice = _xmlAveragePrice, xmlDateFormatter = _xmlDateFormatter;

- (id) init {
    if ((self = [super init])) {
        sources = THHomePriceIndexSourceAllKnown;
        proximities = THHomePriceIndexProximityAllKnown;
        _serieses = [[NSMutableArray alloc] init];
        _buyPrice = nil;
    }
    
    return self;
}

#define kSeriesesCoder  @"Serieses"
#define kBuyPriceCoder  @"BuyPrice"
#define kSrcsCoder      @"Srcs"
#define kProxsCoder     @"Proxs"

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *s = [decoder decodeObjectForKey:kSeriesesCoder];
    THDateVal *dv = [decoder decodeObjectForKey:kBuyPriceCoder];
    int srcs = [decoder decodeIntForKey:kSrcsCoder];
    int proxs = [decoder decodeIntForKey:kProxsCoder];
    
    if ((self = [super init])) {
        _serieses = [s retain];
        _buyPrice = [dv retain];
        sources = srcs;
        proximities = proxs;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:sources forKey:kSrcsCoder];
    [encoder encodeInt:proximities forKey:kProxsCoder];
    [encoder encodeObject:_serieses forKey:kSeriesesCoder];
    [encoder encodeObject:_buyPrice forKey:kBuyPriceCoder];
}

- (id) initWithXmlString:(NSString *)xml {
    if ((self = [self init])) {
    
        NSData* data = [xml dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        self.xmlDateFormatter = df;
        [df release];
        
        [parser parse]; // return value not used
        // if not successful, delegate is informed of error
        
        [parser release];
    }
    
    return self;
}

- (id) initWithURL:(NSURL *)url {
    if ((self = [self init])) {
        
        //NSLog(@"Commencing XML parse from %@", url);
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        self.xmlDateFormatter = df;
        [df release];
        
        [parser parse]; // return value not used
        // if not successful, delegate is informed of error
        [parser release];
    }
    
    return self;
}

- (void) dealloc {
    [_serieses release];
    [_buyPrice release];
    [_xmlDateFormatter release];
    [_xmlAveragePrice release];
    [_xmlCurrentIxName release];
    [_xmlCurrentIxProx release];
    [_xmlCurrentIxSource release];
    [_xmlIndices release];
    
    [super dealloc];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"Found start element: %@", elementName);
    if ([elementName isEqualToString:@"AverageHousePrice"]) {
        isReadingAvgPrice = YES;
        return;
    }
    if ([elementName isEqualToString:@"Indexes"]) {
        
        return;
    }
    
    if ([elementName isEqualToString:@"Index"]) {
        self.xmlCurrentIxName = [attributeDict valueForKey:@"name"];
        self.xmlCurrentIxProx = [attributeDict valueForKey:@"prox"];
        self.xmlCurrentIxSource = [attributeDict valueForKey:@"sourceType"];
        
        NSMutableArray *indices = [[NSMutableArray alloc] init];
        self.xmlIndices = indices;
        self.xmlAveragePrice = nil;
        
        return;
    }
    
    if ([elementName isEqualToString:@"Indice"]) {
        NSString *dateStr = [attributeDict valueForKey:@"date"];
        NSDate *date = [_xmlDateFormatter dateFromString:dateStr];
        
        NSString *valStr = [attributeDict valueForKey:@"value"];
        double val = [valStr doubleValue];
        THDateVal *i = [[THDateVal alloc] initWithVal:val at:date];
        if (isReadingAvgPrice) {
            //HACK: clumsy mem mgt
            self.xmlAveragePrice = i;
            isReadingAvgPrice = NO;
        }
        else {
            [_xmlIndices addObject:i];
        }
        [i release];
        
        return;
    }
    
    return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Found end element: %@", elementName);
    // ignore root and empty elements
    if ([elementName isEqualToString:@"Index"]) {
        THHomePriceIndex *hpi = [[THHomePriceIndex alloc] initWithValues:_xmlIndices];
        hpi.proximityStr = _xmlCurrentIxProx;
        hpi.sourceTypeStr = _xmlCurrentIxSource;
        hpi.averagePrice = _xmlAveragePrice;
        
        [_serieses addObject:hpi];
        
        [hpi release];
        
        return;
        
    }
    
    if ([elementName isEqualToString:@"Indexes"]) {
                
        return;
        
    }
    
    return;
}

- (THDateVal *)calcBestAveragePrice {
    return [self calcBestAveragePriceFromSources:sources proximities:proximities];
}

- (THDateVal *)calcBestAveragePriceFromSources:(int)srcs proximities:(int)proxs {
    if (_serieses.count == 1)
        return [[_serieses objectAtIndex:0] averagePrice];
    
    THDateVal *best = nil;
    int currBestScore = INT32_MAX;
    for (THHomePriceIndex *hpi in _serieses) {
        DLog(@"count = %d, src: %@, prox: %@", hpi.count, hpi.sourceTypeStr, hpi.proximityStr);
        if (hpi.count > 0 &&
           (hpi.src & srcs) &&
           (hpi.prox & proxs)) {
            if (!hpi.averagePrice)
                continue;
            
            int relevance = hpi.relevanceScore;
            if (currBestScore == INT32_MAX || relevance < currBestScore) {
                currBestScore = relevance;
                best = hpi.averagePrice;
            }
        }
    }
    
    //may be nil if too fussy on srcs or proxs
    return best;
}

- (THTimeSeries *)makePricePath {
    return [self makePricePathFromSources:sources proximities:proximities];
}

// computes an equally weighted index from the specified sources and proximities
- (THTimeSeries *)makePricePathFromSources:(int)srcs proximities:(int)proxs {
    if (!_buyPrice)
        self.buyPrice = [self calcBestAveragePrice];
    
    if (!_buyPrice)
        _buyPrice = [[THDateVal alloc] initWithVal:100.0 at:[NSDate date]];

    if (_serieses.count == 1)
        return [[[_serieses objectAtIndex:0] copy] autorelease];
    
    NSDate *firstDt = nil, *finalDt = nil;
    NSMutableArray *relevantIndexes = [[NSMutableArray alloc] initWithCapacity:_serieses.count];
    for (THHomePriceIndex *hpi in _serieses) {
        if (hpi.count > 0 &&
            (hpi.src & srcs) &&
            (hpi.prox & proxs)) {
            [relevantIndexes addObject:hpi];
            if (!firstDt || [firstDt isAfter:[[hpi objectAtIndex:0] date]])
                firstDt = [[hpi objectAtIndex:0] date];
            if (!finalDt || [finalDt isBefore:[[hpi lastObject] date]])
                finalDt = [[hpi lastObject] date];
        }
    }
    
    if (relevantIndexes.count == 0)
        return nil;
    if (relevantIndexes.count == 1) 
        return [[[relevantIndexes objectAtIndex:0] copy] autorelease];
    
    NSAssert(firstDt, @"First date not set");
    NSAssert(finalDt, @"Last date not set");
    
    NSMutableArray *pricePath = [[NSMutableArray alloc] init];
    THDateVal *curr = [[THDateVal alloc] initWithVal:100.0 at:firstDt];
    [pricePath addObject:curr];

    NSMutableArray *nexts = [[NSMutableArray alloc] init];
    for (THHomePriceIndex *hpi in relevantIndexes) {
        THDateVal *next = [hpi firstAfter:curr.date];
        NSAssert(next, @"firstAfter should not be nil!");
        [nexts addObject:next];
    }
    
    do {
        NSAssert(nexts.count == relevantIndexes.count, @"Not enough nexts");
        
        //set next to be the earliest next dateval
        THDateVal *next = nil;
        for (THDateVal *v in nexts) {
            if (!next || [v.date isBefore:next.date])
                next = v;
        }
        NSAssert(next, @"should not be nil");
        
        double roc = 0.0;
        for (THHomePriceIndex *hpi in relevantIndexes) {
            double thisRoc = [hpi dailyRateOfChangeAt:next.date];
            //NSLog(@"RoC is %5.5f\%", thisRoc * 100.0);
            roc += thisRoc;
        }
        
        NSAssert(relevantIndexes.count > 0, @"Should have been checked above");
        roc /= relevantIndexes.count;
        
        double numDays = [curr.date daysUntil:next.date];
        numDays = fmin(numDays, [curr.date daysUntil:finalDt]);
        double nextVal = curr.val * pow((1.0 + roc), numDays);
        THDateVal *nextCreated = [[THDateVal alloc] initWithVal:nextVal at:[curr.date addDays:numDays]];
        [pricePath addObject:nextCreated];
        
        //replace any of the nexts that have the same or earlier date than next
        //(mostly this should be where has same date)
        NSMutableArray *removes = [[NSMutableArray alloc] init];
        for (THDateVal *v in nexts) {
            if ([v.date isBeforeOrEqualTo:next.date] && [v.date isBefore:finalDt])
                [removes addObject:v];
        }
        
        // if next.date is after finalDt then we will have removal from nexts of a THDateVal
        // that will not have a valid .ix reference, because it was created by the process below
        // this will crash the process below
        //NSAssert([next.date isBeforeOrEqualTo:finalDt], @"removes will be broken");
        for (THDateVal *v in removes) {
            [nexts removeObject:v];
            
            THDateVal *vnext = nil;
            if (v.next != nil)
                vnext = v.next;
            else
                vnext = [v.ix calcValueAt:finalDt];
            
            NSAssert(vnext || [curr.date isAfterOrEqualTo:finalDt], @"should not be nil");
            [nexts addObject:vnext];
        }
        [removes release];
        
        [curr release];
        curr = [nextCreated retain];
        [nextCreated release];
        
    } while ([curr.date isBefore:finalDt]);
            
    // adjust the series to reflect the users buy price
    THHomePriceIndex *tmpPP = [[THHomePriceIndex alloc] initWithValues:pricePath];
    [pricePath removeAllObjects];
    THDateVal *ixValAtBuyDate = [tmpPP calcValueAt:_buyPrice.date];
    for (THDateVal *dv in tmpPP) {
        double val = _buyPrice.val * dv.val / ixValAtBuyDate.val;
        THDateVal *i = [[THDateVal alloc] initWithVal:val at:dv.date];
        [pricePath addObject:i];
        [i release];
    }
    [tmpPP release];
    
    //insert buy price
    [pricePath addObject:[_buyPrice copy]];    
    THHomePriceIndex *finalPP = [[THHomePriceIndex alloc] initWithValues:pricePath];
    finalPP.prox = proxs;
    finalPP.src = srcs;
    
    //TODO: apply manual price adjustments
    
    [pricePath release];
    [nexts release];
    [curr release]; 
    [relevantIndexes release];
     
    return [finalPP autorelease];
}
    
//    NSMutableArray *subset = [[NSMutableArray alloc] init];
//    NSDate *currDt = firstDt;
//    double ixVal = 100.0;
//    NSDate *lastIxDt = firstDt;
//    double roc = 0.0;
//    do {
//        NSDate *tmDt = [currDt addOneDay];
//        double tmRoc = 0.0;
//        for (THHomePriceIndex *hpi in relevantIndexes) {
//            double thisRoc = [hpi dailyRateOfChangeAt:tmDt];
//            //NSLog(@"RoC is %5.5f\%", thisRoc * 100.0);
//            tmRoc += thisRoc;
//        }  
//        NSAssert(relevantIndexes.count > 0, @"Should have been checked above");
//        tmRoc /= relevantIndexes.count;
//        //NSLog(@"Av RoC is %5.5f\%", tmRoc * 100.0);
//        if ([currDt isEqualToDate:firstDt] || 
//            [currDt isEqualToDate:finalDt] ||
//            tmRoc != roc) {
//            double numDays = [lastIxDt daysUntil:currDt];
//            NSAssert([currDt isEqualToDate:firstDt] || numDays > 0.0, @"ERROR");
//            ixVal = ixVal * pow((1.0 + roc), numDays);
//            THDateVal *i = [[THDateVal alloc] initWithVal:ixVal at:currDt];
//            [subset addObject:i];
//            [i release];
//            
//            lastIxDt = currDt;
//        }
//        currDt = tmDt;
//        roc = tmRoc;
//    } while ([currDt isBeforeOrEqualTo:finalDt]);
//    
//    //TODO: apply manual price adjustments
//    
//    //TODO: appy buy price
//        
//    THHomePriceIndex *retVal = [[THHomePriceIndex alloc] initWithValues:subset];
//    [subset release];
//    
//    retVal.prox = proxs;
//    retVal.src = srcs;
//    
//    return [retVal autorelease];
//}



@end