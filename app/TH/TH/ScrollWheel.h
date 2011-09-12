//
//  ScrollWheel.h
//  TallyHome
//
//  Created by Mark Blackwell on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

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
    ScrollWheelTapAreaScroller = 1,
    ScrollWheelTapAreaButton = 2
} ScrollWheelTapArea;

@class ScrollWheel;

@protocol ScrollWheelDelegate <NSObject>

@required
- (void)scrollWheel:(ScrollWheel *)sw didRotate:(NSInteger)rotationSteps;
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw;

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
}

@property (readonly) CGFloat lastRotation, lastRotationVelocity;
@property (assign, nonatomic) CGFloat buttonPercentSize;
@property (copy, nonatomic) NSString *buttonLabel;
@property (retain, nonatomic) id <ScrollWheelDelegate> delegate;
@property (assign, nonatomic) CGFloat fullCircleScale, stepScale;
@property (readonly) BOOL isRotating;

@end
