//
//  Indice.h
//  TallyHome
//
//  Created by Mark Blackwell on 11/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THDateVal.h"

@class THTimeSeries;

@interface THIndice : THDateVal {
    
    // weak ref, do not retain
    THTimeSeries *_ix;
   
    THIndice *_last;
}

// weak ref, do not retain
@property (assign) THTimeSeries *ix;
@property (retain) THIndice *last;

- (void)dealloc;

@end

