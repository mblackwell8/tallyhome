//
//  PricePath.m
//  TallyHome iPhone
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THHomePricePath.h"


@implementation THHomePricePath

@synthesize sources;
@synthesize proximities;
@synthesize innerSerieses = _serieses;
@synthesize manualPriceAdjustments = _manualPriceAdjustments;
@synthesize buyPrice = _buyPrice;

- (id) init {
    if ((self = [super init])) {
        sources = TH_Source_AllKnown;
        proximities = TH_Proximity_AllKnown;
        self.innerSerieses = [[NSMutableArray alloc] init];
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
        self.innerSerieses = s;
        self.buyPrice = dv;
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
        THDateVal *i = [[THDateVal alloc] initWithVal:val at:date];
                
        [_xmlIndices addObject:i];
        
        return;
    }
    
    return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"Found end element: %@", elementName);
    // ignore root and empty elements
    if ([elementName isEqualToString:@"Index"]) {
        THHomePriceIndex *hpi = [[THHomePriceIndex alloc] initWithValues:_xmlIndices];
        hpi.proximityStr = _xmlCurrentIxProx;
        hpi.sourceTypeStr = _xmlCurrentIxSource;
        
        [_serieses addObject:hpi];
        
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

- (THTimeSeries *) makePricePath {
    return [self makePricePathFromSources:sources proximities:proximities];
}

// computes an equally weighted index from the specified sources and proximities
- (THTimeSeries *) makePricePathFromSources:(int) srcs proximities:(int) proxs {
    if (_serieses.count == 1)
        return [_serieses objectAtIndex:0];
    
    NSDate *firstDt = nil, *finalDt = nil;
    NSMutableArray *relevantIndexes = [[NSMutableArray alloc] initWithCapacity:_serieses.count];
    for (THHomePriceIndex *hpi in _serieses) {
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
        for (THHomePriceIndex *hpi in relevantIndexes) {
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
            THDateVal *i = [[THDateVal alloc] initWithVal:ixVal at:currDt];
            [subset addObject:i];
            [i release];
            
            lastIxDt = currDt;
        }
        currDt = tmDt;
        roc = tmRoc;
    } while ([currDt isBeforeOrEqualTo:finalDt]);
    
    //TODO: apply manual price adjustments
    
    //TODO: appy buy price
        
    THHomePriceIndex *retVal = [[THHomePriceIndex alloc] initWithValues:subset];
    [subset release];
    
    retVal.prox = proxs;
    retVal.src = srcs;
    
    return [retVal autorelease];
}

- (void) dealloc {
    [_serieses release];
    _serieses = nil;
    
    [super dealloc];
}


@end
