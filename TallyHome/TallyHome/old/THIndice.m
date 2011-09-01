//
//  Indice.m
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THIndice.h"


@implementation THIndice


@synthesize ix = _ix, last = _last;

- (id) init {
    if ((self = [super init])) {
    }
    
    return self;
}

- (void)dealloc {
    if (_last) {
        [_last release];
        _last = nil;
    }
    
    [super dealloc];
}

@end
