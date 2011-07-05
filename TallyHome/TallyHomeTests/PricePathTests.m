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
    testPath = [[THHomePricePath alloc] initWithURL:url];
    NSLog(@"TestPath has %d indexes", testPath.innerSerieses.count);
    //NSLog(@"Distant past is %@", [NSDate distantPast]);
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
    STAssertTrue(testPath.innerSerieses.count > 0, @"No price events found or loaded");
}

- (void)testTrendGrowthCalcs {
    double trGr = [[testPath makePricePath] calcTrendGrowth];
    NSLog(@"Trend growth is %5.2f", trGr * 100.0);
    
}

- (void)testApplyPricePath {
    NSDate *start = [[NSDate alloc] initWithTimeIntervalSinceNow:(-2.0 * 365 * 24 * 60 * 60)];
    THTimeSeries *thi = [testPath makePricePath];
    for (THDateVal *i in thi) {
        NSLog(@"%@", i);
    }
}

#endif

@end
