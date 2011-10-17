//
//  ScrollWheel.h
//  TallyHome
//
//  Created by Mark Blackwell on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>

typedef enum  {
    //Upper/Lower is the MSB
    //Left/Right is the LSB
    
    ScrollWheelQuadrantUpperLeft = 0,
    ScrollWheelQuadrantUpperRight = 1,
    ScrollWheelQuadrantLowerLeft =  2,
    ScrollWheelQuadrantLowerRight = 3
} ScrollWheelQuadrant;

typedef enum {
    ScrollWheelTapAreaDead = 0, // outside the scroller, but inside CGRect
    
    //bitmask on 8 identifies any scroller tap
    ScrollWheelTapAreaScroller = 8,
    ScrollWhellTapAreaScroller_Left = 9, //used for directional taps
    ScrollWheelTapAreaScroller_Right = 10,
    ScrollWheelTapAreaScroller_Bottom = 11,
    ScrollWheelTapAreaScroller_Top = 12,
    ScrollWheelTapAreaScroller_Other = 13,
    
    ScrollWheelTapAreaButton = 16
} ScrollWheelTapArea;

@class ScrollWheel;

@protocol ScrollWheelDelegate <NSObject>

@required
- (void)scrollWheel:(ScrollWheel *)sw didRotate:(NSInteger)rotationSteps;
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw;

@optional
- (void)scrollWheelLeftTap:(ScrollWheel *)sw;
- (void)scrollWheelRightTap:(ScrollWheel *)sw;
- (void)scrollWheelBottomTap:(ScrollWheel *)sw;
- (void)scrollWheelTopTap:(ScrollWheel *)sw;

@end

@interface ScrollWheel : UIView {
    id <ScrollWheelDelegate> _delegate;
    
    CGFloat _buttonPercentSize;
    NSString *_buttonLabel;
    CGFloat _halfHeight, _halfWidth;
    
    UIBezierPath *_scrollCircle;
    UIBezierPath *_buttonCircle;
    
    CGGradientRef _backgroundGradient;
    
    CGPoint _lastTouch;
    CGFloat _lastRadians;
    ScrollWheelQuadrant _lastQuadrant;
    ScrollWheelTapArea _lastTapArea;
    CGFloat _lastRotation; // in radians
    NSTimeInterval _lastTouchTime;
    CGFloat _lastRotationVelocity;  // in radians per sec
    BOOL _isSingleTap, _isDoubleTap, _isRotating;
    
    CGFloat _fullCircleScale;
    CGFloat _stepScale; //will call delegate method every step, zero for every touchMoved
    CGFloat _radiansSinceLastStep;
    
    SystemSoundID tockSoundID;
}

@property (readonly) CGFloat lastRotation, lastRotationVelocity;
@property (assign, nonatomic) CGFloat buttonPercentSize;
@property (copy, nonatomic) NSString *buttonLabel;
@property (retain, nonatomic) id <ScrollWheelDelegate> delegate;
@property (assign, nonatomic) CGFloat fullCircleScale, stepScale;
@property (readonly) BOOL isRotating;

@end
