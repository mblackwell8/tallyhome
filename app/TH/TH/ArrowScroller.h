//
//  ArrowScroller.h
//  TH
//
//  Created by Mark Blackwell on 25/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>


typedef enum {
    ArrowScrollDirectionLeft,
    ArrowScrollDirectionRight
} ArrowScrollDirection;

@class ArrowScroller;

@protocol ArrowScrollerDelegate <NSObject>

@required
- (void)arrowScroller:(ArrowScroller *)scroller didScroll:(NSInteger)steps;
- (void)arrowScrollerTapped:(ArrowScroller *)scroller;

@end


@interface ArrowScroller : UIView {
    
    CGPoint _lastTouch;
    NSTimeInterval _lastTouchTime;
    BOOL _isSingleTap, _isDoubleTap, _isScrolling;
    ArrowScrollDirection _scrollDirection;
    
    CGFloat _pixelsSinceLastStep;
    
    
    SystemSoundID tockSoundID;
}

@property (readonly) CGFloat lastScroll, lastScrollVelocity;
@property (retain, nonatomic) id <ArrowScrollerDelegate> delegate;
@property (assign, nonatomic) CGFloat fullScale, stepScale;
@property (readonly) BOOL isScrolling;
@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, assign) ArrowScrollDirection scrollDirection;


@end
