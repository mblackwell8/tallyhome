//
//  Indice.m
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THIndice.h"


// per http://stackoverflow.com/questions/2736762/initializing-a-readonly-property

@interface THIndice ()

@property (readwrite, retain) NSDate *date;
@property (readwrite) double val;


@end

@implementation THIndice


@synthesize ix = _ix, date = _date, last = _last, val;

- (id) init {
    if ((self = [super init])) {
    }
    
    return self;
}

- (id) initWithVal:(double)v at:(NSDate *)dt {
    if ((self = [self init])) {
        self.val = v;
        self.date = dt;
    }
    
    return self;
}

- (NSComparisonResult)compareByDate:(THIndice *)another {
    //if other index is null or has a null date, this event is considered later
    if (!another || !(another.date))
        return NSOrderedDescending;
    
    return [_date compare:another.date];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: val=%5.2f", _date, val];
}

@end
