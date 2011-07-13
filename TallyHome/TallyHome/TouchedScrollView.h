//
//  TouchedScrollView.h
//  TallyHome
//
//  Created by Mark Blackwell on 10/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum ScrollDirection  {
    ScrollNone = 0,
    ScrollUp = 1,
    ScrollDown = 2,
    ScrollLeft = 4,
    ScrollRight = 8
    } ScrollDirection;

@interface TouchedScrollView : UIScrollView {
    NSSet *_touchesBeganAt, *_touchesEndedAt, *_touchesMovedTo;
}

@property (nonatomic, retain) NSSet *touchesBeganAt;
@property (nonatomic, retain) NSSet *touchesEndedAt;
@property (nonatomic, retain) NSSet *touchesMovedTo;

- (ScrollDirection) scrollDirection;

@end
