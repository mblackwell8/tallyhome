//
//  Rotor.m
//  TH
//
//  Created by Mark Blackwell on 16/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Rotor.h"
#import "DebugMacros.h"
#import "TallyHomeConstants.h"

@interface Rotor ()

@property (retain, nonatomic) UIBezierPath *scrollCircle;

- (CGFloat)calcRadiansAroundOriginForPoint:(CGPoint)pt;
- (RotorQuadrant)calcQuadrantOfPoint:(CGPoint)touch;

@end

@implementation Rotor

- (void)doInit {
    self.backgroundColor = [UIColor clearColor];
    
    _radiansSinceLastStep = 0.0;
    _isRotating = NO;
    _shouldReload = YES;
    
    NSString *tockpath = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:tockpath], &tockSoundID);
    
    //    NSString *imgpath = [[NSBundle mainBundle] pathForResource:@"Wheel" ofType:@"png"];
    //    UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgpath];
    //    UIImageView *bgrdImgView = [[UIImageView alloc] initWithImage:img];
    //    [self addSubview:bgrdImgView];
    //    [img release];
    //    [bgrdImgView release];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self doInit];
}

- (void) dealloc {
    [super dealloc];
    
    //CGGradientRelease(_backgroundGradient);
    
    [_rotorCircle release];
    
    [_delegate release];
    
    AudioServicesDisposeSystemSoundID(tockSoundID);
}

@synthesize wheel = _wheel;
@synthesize lastRotation = _lastRotation, lastRotationVelocity = _lastRotationVelocity;
@synthesize delegate = _delegate;
@synthesize scrollCircle = _scrollCircle;
@synthesize isRotating = _isRotating;



- (void)layoutSubviews {
    if (!_shouldReload)
        return;
    
    DLog(@"doing");
    CGRect frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    _halfWidth = frame.size.width / 2.0;
    _halfHeight = frame.size.height / 2.0;
    
    self.scrollCircle = [UIBezierPath bezierPathWithOvalInRect:frame];
    
    // Create a UIImageView with the circle image and center it in the main view.
    UIImageView *container = [[UIImageView alloc] initWithFrame:frame];
    //    container.image = [UIImage imageNamed:@"CircleInSquare"];
    container.center = CGPointMake(_halfWidth, _halfHeight);
    [self addSubview:container];
    
    // Calculate the angle between each label based on the number of labels.
    _nSteps = [_delegate numberOfSectionsForRotor:self];
    CGFloat angleSize = 2.0 * M_PI / _nSteps;
    
    // Each label gets the exact same inital frame, 
    // but a different transform is applied to space them around the circle.
    for (int i = 0; i < _nSteps; ++i) {
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _halfWidth, 25.0f)];
        sectionLabel.text = [_delegate labelForSectionNumber:i];;
        sectionLabel.font = [UIFont systemFontOfSize:25.0];
        sectionLabel.textColor = [UIColor whiteColor];
        //sectionLabel.backgroundColor = [UIColor clearColor];
        sectionLabel.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.2f alpha:0.5f];
        
        // anchor point on right middle...
        sectionLabel.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        // places anchorPoint of each label directly in the center of the circle.
        sectionLabel.layer.position = CGPointMake(_halfWidth, _halfHeight); 
        sectionLabel.transform = CGAffineTransformMakeRotation(angleSize * i);
        [container addSubview:sectionLabel];
        [sectionLabel release];
    }
    self.wheel = container;
    [container release];
    
    _shouldReload = NO;

}



- (RotorQuadrant)calcQuadrantOfPoint:(CGPoint)touch {
    // start with top left
    RotorQuadrant qr = 0;
    
    // equality will stay in top and/or left
    if (touch.x > _halfWidth)
        qr += 1;
    if (touch.y > _halfHeight) 
        qr += 2;
    
    return qr;
}

- (RotorTapArea)calcTapAreaOfPoint:(CGPoint)touch {
    if ([_scrollCircle containsPoint:touch]) {
        //TODO: check whether the touch is in the dead rect or button
        return RotorTapAreaRotor;
    }
    
    return RotorTapAreaDead;
}

- (CGFloat)calcRadiansAroundOriginForPoint:(CGPoint)pt {
    //the calcQuadrant method considers pts on the halfHeight line to be
    //at the top, so stop the atan2 from flipping from +2pi to -2pi in that instance
    CGFloat adjY = (pt.y == _halfHeight ? -0.01 : pt.y - _halfHeight);
    return atan2f(adjY, pt.x - _halfWidth);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self];
    _lastTouchTime = [NSDate timeIntervalSinceReferenceDate];
    _lastQuadrant = [self calcQuadrantOfPoint:_lastTouch];
    _lastTapArea = [self calcTapAreaOfPoint:_lastTouch];
    _beginRadians = [self calcRadiansAroundOriginForPoint:_lastTouch];
    _lastRadians = _beginRadians;
    _radiansSinceLastStep = 0.0;
    
    //if we already have a tap before a move, then it's a doubletap
    if (_isSingleTap)
        _isDoubleTap = YES;
    
    _isSingleTap = (touches.count == 1);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSingleTap = NO;
    _isDoubleTap = NO;
    
    CGPoint movedPoint = [[touches anyObject] locationInView:self];
    //DLog(@"last touch (%@) moved to %@", NSStringFromCGPoint(_lastTouch), NSStringFromCGPoint(movedPoint));
    NSTimeInterval movedTime = [NSDate timeIntervalSinceReferenceDate];
    RotorTapArea tapArea = [self calcTapAreaOfPoint:movedPoint];
    CGFloat thisRadians = [self calcRadiansAroundOriginForPoint:movedPoint];
    RotorQuadrant thisQuadrant = [self calcQuadrantOfPoint:movedPoint];
    if (_lastTapArea & RotorTapAreaRotor &&
        tapArea & RotorTapAreaRotor) {
        _isRotating = YES;
        
        // CW is positive, ACW is negative
        _lastRotation = thisRadians - _lastRadians;
        _totalRotation = thisRadians - _beginRadians;
        if (_lastQuadrant == RotorQuadrantLowerLeft &&
            thisQuadrant == RotorQuadrantUpperLeft) {
            DLog(@"crossed qdrt boundary LL->UL, _lastRotation = %5.2f", _lastRotation);
            _lastRotation += M_PI * 2.0;
            _totalRotation += M_PI * 2.0;
        }
        else if (_lastQuadrant == RotorQuadrantUpperLeft &&
                 thisQuadrant == RotorQuadrantLowerLeft) {
            DLog(@"crossed qdrt boundary UL->LL, _lastRotation = %5.2f", _lastRotation);
            _lastRotation -= M_PI * 2.0; 
            _totalRotation -= M_PI * 2.0;
        }
        
        //DLog(@"last radians (%5.2f) moved to %5.2f = rotation %5.2f", _lastRadians, thisRadians, _lastRotation);
        _lastRotationVelocity = _lastRotation / (movedTime - _lastTouchTime);
        
        _wheel.transform = CGAffineTransformRotate(_wheel.transform, _lastRotation);
        
        //a full rotation is 2pi
        _radiansSinceLastStep += _lastRotation;
        //DLog(@"lastRotation: %5.2f", _lastRotation);
        //DLog(@"radiansSinceLastStep: %5.2f", _radiansSinceLastStep);
        CGFloat steps = _radiansSinceLastStep * _nSteps / (M_PI * 2.0);
        if (ABS(steps) >= 1.0) {
            [_delegate rotor:self didRotate:(NSInteger)steps];
            AudioServicesPlaySystemSound(tockSoundID);
            _radiansSinceLastStep = 0.0;
        }
    }
    
    _lastRadians = thisRadians;
    _lastQuadrant = thisQuadrant;
    _lastTouch = movedPoint;
    _lastTouchTime = movedTime;
    _lastTapArea = tapArea;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap) { 
        RotorTapArea tap = [self calcTapAreaOfPoint:_lastTouch];
        DLog(@"tap: %d", tap);
        switch (tap) {
            case RotorTapAreaButton:
                AudioServicesPlaySystemSound(tockSoundID);
                //[_delegate scrollWheelButtonPressed:self];
                break;
                
            default:
                break;
        }
    }
    else {
        //snap the last rotation to a round step if it's more than half way
        CGFloat stepRadians = (M_PI * 2.0) / _nSteps;
        CGFloat currentRadians = atan2f(_wheel.transform.b, _wheel.transform.a);
        // _radiansSinceLastStep seems to suffer from rounding problems
        CGFloat actStepNum = currentRadians / stepRadians;
        CGFloat roundStepNum = round(actStepNum);
        NSNumber *roundingSteps = [NSNumber numberWithInt:(int)(roundStepNum - (int)actStepNum)];
//        if (roundStepNum > floor(actStepNum))
//            roundingSteps = [NSNumber numberWithInt:1];
//        else if (roundStepNum < floor(actStepNum))
//            roundingSteps = [NSNumber numberWithInt:-1];
//        else
//            roundingSteps = [NSNumber numberWithInt:0];
        
        [UIView beginAnimations:nil context:roundingSteps];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(wheelAnimationDidStop:finished:context:)];
        _wheel.transform = CGAffineTransformMakeRotation(stepRadians * roundStepNum);
        [UIView commitAnimations];
        
    }
    
    _isRotating = NO;
    
}

- (void)wheelAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSNumber *steps = (NSNumber *)context;
    [_delegate rotor:self didRotate:[steps integerValue]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isRotating = NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
