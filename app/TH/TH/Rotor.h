//
//  Rotor.h
//  TH
//
//  Created by Mark Blackwell on 16/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>

typedef enum  {
    //Upper/Lower is the MSB
    //Left/Right is the LSB
    
    RotorQuadrantUpperLeft = 0,
    RotorQuadrantUpperRight = 1,
    RotorQuadrantLowerLeft =  2,
    RotorQuadrantLowerRight = 3
} RotorQuadrant;

typedef enum {
    RotorTapAreaDead = 0, // outside the scroller, but inside CGRect
    RotorTapAreaRotor,
    RotorTapAreaButton
} RotorTapArea;

@class Rotor;

@protocol RotorDelegate <NSObject>

@required
- (void)rotor:(Rotor *)rotor didRotate:(NSInteger)rotationSteps;
- (NSUInteger)numberOfSectionsForRotor:(Rotor *)rotor;
- (NSString *)labelForSectionNumber:(NSUInteger)section;

@end

@interface Rotor : UIView {
    UIImageView *_wheel;
    
    CGFloat _halfHeight, _halfWidth;
    
    UIBezierPath *_rotorCircle;
    CGRect _rhsCoverRect;
    CGPoint _lastTouch;
    CGFloat _lastRadians;
    RotorQuadrant _lastQuadrant;
    RotorTapArea _lastTapArea;
    CGFloat _lastRotation, _totalRotation; // in radians
    NSTimeInterval _lastTouchTime;
    CGFloat _lastRotationVelocity;  // in radians per sec
    BOOL _isSingleTap, _isDoubleTap, _isRotating;
    
    BOOL _shouldReload;
    
    NSUInteger _nSteps;
    CGFloat _beginRadians, _radiansSinceLastStep;
    
    SystemSoundID tockSoundID;

    
    id <RotorDelegate> _delegate;
    
}

@property (nonatomic, retain) UIImageView *wheel;
@property (readonly) CGFloat lastRotation, lastRotationVelocity;
@property (retain, nonatomic) id <RotorDelegate> delegate;
@property (readonly) BOOL isRotating;

@end
