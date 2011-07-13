//
//  TouchedScrollView.m
//  TallyHome
//
//  Created by Mark Blackwell on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchedScrollView.h"


@implementation TouchedScrollView

@synthesize touchesBeganAt = _touchesBeganAt, touchesEndedAt = _touchesEndedAt, touchesMovedTo = _touchesMovedTo;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchesBeganAt = touches;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchesMovedTo = touches;
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchesMovedTo = nil;
    self.touchesEndedAt = touches;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.touchesBeganAt = nil;
//    self.touchesMovedTo = nil;
//    self.touchesEndedAt = nil;
    [super touchesCancelled:touches withEvent:event];
}

- (ScrollDirection) scrollDirection {
    if (![super isDragging] && ![super isDecelerating])
        return ScrollNone;
    
    if (!_touchesBeganAt)
        return ScrollNone;
    
    UITouch *beginTouch = [[_touchesBeganAt allObjects] objectAtIndex:0];
    if (!beginTouch)
        return ScrollNone;
    
    UITouch *nextTouch = nil;
    if ([super isDragging]) {
        if (!_touchesMovedTo)
            return ScrollNone;
        
        nextTouch = [[_touchesMovedTo allObjects] objectAtIndex:0];
        if (!nextTouch)
            return ScrollNone;
    }
    if ([super isDecelerating]) {
        if (!_touchesEndedAt)
            return ScrollNone;
        
        nextTouch = [[_touchesEndedAt allObjects] objectAtIndex:0];
        if (!nextTouch)
            return ScrollNone;
    }
    
    CGPoint beginLocn = [beginTouch locationInView:self];
    CGPoint nextLocn = [nextTouch locationInView:self];
    
    ScrollDirection sd = 0;
    if (nextLocn.y > beginLocn.y) {
        sd = ScrollDown;
    }
    else if (nextLocn.y < beginLocn.y) {
        sd = ScrollUp;
    }
    
    if (nextLocn.x > beginLocn.x) {
        sd &= ScrollRight;
    }
    else if (nextLocn.y < beginLocn.y) {
        sd &= ScrollLeft;
    }
    
    return sd;
}

- (void)dealloc {
    self.touchesBeganAt = nil;
    self.touchesEndedAt = nil;
    self.touchesMovedTo = nil;
    
    [super dealloc];
}

@end
