//
//  TickingValueLabel.m
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TickingValueLabel.h"

@implementation TickingValueLabel

@synthesize value = _value;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setValue:(double)value {
    NSString *newVal = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
    if ([newVal isEqualToString:_valueStr])
        return;
    
    
}

//- (void)drawRect:(CGRect)rect {
//    //draw everything to left of dec place
//    
//    //draw everything to right of dec place, in smaller text, aligned top
//    
//}

@end
