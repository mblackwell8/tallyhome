//
//  PricePathTests.m
//  TallyHome
//
//  Created by Mark Blackwell on 5/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PricePathTests.h"


@implementation PricePathTests

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void)testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void)setUp {
    [super setUp];
    
    // Set-up code here.
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/price_events.xml"];    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    testPath = [[PricePath alloc] initWithURL:url];
    NSLog(@"TestPath has %d price events", testPath.indices.count);
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}



- (void)testLoadFromURL {
    
    STAssertNotNil(testPath, @"PricePath not loading from price_events.xml");
    STAssertTrue(testPath.indices.count > 0, @"No price events found or loaded");
}

- (void)testTrendGrowthCalcs {
    double trGr = [testPath calcTrendGrowth];
    NSLog(@"Trend growth is %5.2f", trGr);
    
    double trGr_back = [testPath calcTrendGrowth];
    NSLog(@"Backwards trend growth is %5.2f", trGr_back);
    
}

- (void)testApplyPricePath {
    NSDate *start = [[NSDate alloc] initWithTimeIntervalSinceNow:(-2.0 * 365 * 24 * 60 * 60)];
    NSArray *pes = [testPath applyPathFrom:start to:[NSDate date]];
    for (PriceEvent *pe in pes) {
        NSLog(@"%@", pe);
    }
}

#endif

@end
