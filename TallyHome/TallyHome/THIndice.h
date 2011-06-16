//
//  Indice.h
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THIndex;

@interface THIndice : NSObject {
    
    // weak ref, do not retain
    THIndex *_ix;
    NSDate *_date;
    
    THIndice *_last;
    double val;
}

// weak ref, do not retain
@property (assign) THIndex *ix;
@property (retain) THIndice *last;

@property (readonly, retain) NSDate *date;
@property (readonly) double val;

- (id) initWithVal:(double)v at:(NSDate *)dt;

- (NSComparisonResult)compareByDate:(THIndice *)another;

- (NSString *)description;

@end

