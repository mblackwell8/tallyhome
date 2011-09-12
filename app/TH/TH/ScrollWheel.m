//
//  ScrollWheel.m
//  TallyHome
//
//  Created by Mark Blackwell on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollWheel.h"
#import "DebugMacros.h"
#import "TallyHomeConstants.h"

@interface ScrollWheel ()

@property (retain, nonatomic) UIBezierPath *scrollCircle, *buttonCircle;

@end

@implementation ScrollWheel

- (void)doInit {
    self.backgroundColor = [UIColor clearColor];

    _buttonPercentSize = 0.4;
    _stepScale = 0;
    _fullCircleScale = M_PI * 2;
    _radiansSinceLastStep = 0.0;
    _buttonLabel = @"Now";
    _isRotating = NO;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self doInit];
}

- (void) dealloc {
    [super dealloc];
    
    CGGradientRelease(_backgroundGradient);
    
    [_buttonLabel release];
    [_scrollCircle release];
    [_buttonCircle release];

    [_delegate release];
    
}

@synthesize lastRotation = _lastRotation, lastRotationVelocity = _lastRotationVelocity;
@synthesize buttonLabel = _buttonLabel, buttonPercentSize = _buttonPercentSize;
@synthesize delegate = _delegate;
@synthesize scrollCircle = _scrollCircle, buttonCircle = _buttonCircle;
@synthesize fullCircleScale = _fullCircleScale, stepScale = _stepScale;
@synthesize isRotating = _isRotating;


- (ScrollWheelQuadrant)calcQuadrantOfPoint:(CGPoint)touch {
    // start with top left
    ScrollWheelQuadrant qr = 0;
    
    // equality will stay in top and/or left
    if (touch.x > _halfWidth)
        qr += 1;
    if (touch.y > _halfHeight) 
        qr += 2;
    
    return qr;
}

- (ScrollWheelTapArea)calcTapAreaOfPoint:(CGPoint)touch {
    if ([_buttonCircle containsPoint:touch])
        return ScrollWheelTapAreaButton;
    
    if ([_scrollCircle containsPoint:touch])
        return ScrollWheelTapAreaScroller;
    
    return ScrollWheelTapAreaDead;
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
    ScrollWheelTapArea tapArea = [self calcTapAreaOfPoint:movedPoint];
    
    if (_lastTapArea == ScrollWheelTapAreaScroller &&
        tapArea == ScrollWheelTapAreaScroller) {
        _isRotating = YES;
        
        _lastRadians = [self calcRadiansAroundOriginForPoint:_lastTouch];
        CGFloat thisRadians = [self calcRadiansAroundOriginForPoint:movedPoint];
        ScrollWheelQuadrant thisQuadrant = [self calcQuadrantOfPoint:movedPoint];
        
        // CW is positive, ACW is negative
        _lastRotation = thisRadians - _lastRadians;
        if (_lastQuadrant == ScrollWheelQuadrantLowerLeft &&
            thisQuadrant == ScrollWheelQuadrantUpperLeft) {
            DLog(@"crossed qdrt boundary LL->UL, _lastRotation = %5.2f", _lastRotation);
            _lastRotation += M_PI * 2.0;
        }
        else if (_lastQuadrant == ScrollWheelQuadrantUpperLeft &&
                 thisQuadrant == ScrollWheelQuadrantLowerLeft) {
            DLog(@"crossed qdrt boundary UL->LL, _lastRotation = %5.2f", _lastRotation);
            _lastRotation -= M_PI * 2.0;    
        }
        
        //DLog(@"last radians (%5.2f) moved to %5.2f = rotation %5.2f", _lastRadians, thisRadians, _lastRotation);
        _lastRotationVelocity = _lastRotation / (movedTime - _lastTouchTime);
        
        //a full rotation is 2pi
        _radiansSinceLastStep += _lastRotation;
        CGFloat steps = _radiansSinceLastStep * _fullCircleScale / (M_PI * 2.0);
        if (_stepScale <= 0.0 || ABS(steps) >= _stepScale) {
            [_delegate scrollWheel:self didRotate:(NSInteger)steps];
            _radiansSinceLastStep = 0.0;
        }
        
        _lastRadians = thisRadians;
        _lastQuadrant = thisQuadrant;
    }
    
    _lastTouch = movedPoint;
    _lastTouchTime = movedTime;
    _lastTapArea = tapArea;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap && 
        [self calcTapAreaOfPoint:_lastTouch] == ScrollWheelTapAreaButton) {
        [_delegate scrollWheelButtonPressed:self];
    }
    
    _isRotating = NO;
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isRotating = NO;
}

- (void)layoutSubviews {
    CGRect frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    _halfWidth = frame.size.width / 2.0;
    _halfHeight = frame.size.height / 2.0;
    
    self.scrollCircle = [UIBezierPath bezierPathWithOvalInRect:frame];
    CGRect buttonRect = CGRectInset(frame, 
                                    frame.size.width * (1 - _buttonPercentSize) / 2.0, 
                                    frame.size.height * (1 - _buttonPercentSize) / 2.0);
    self.buttonCircle = [UIBezierPath bezierPathWithOvalInRect:buttonRect];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    
}

//#define TH_SCROLLER_DETAIL_COLOR [UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:151.0/255.0 alpha:1.0]
//#define TH_SCROLLER_DETAIL_MIDGRADIENTCOLOR [UIColor colorWithRed:27.0/255.0 green:47.0/255.0 blue:60.0/255.0 alpha:1.0]

- (CGGradientRef)backgroundGradient {
    if(NULL == _backgroundGradient) {
        // lazily create the gradient, then reuse it
        CGFloat colors[16] = {10.0 / 255.0, 68.0 / 255.0, 151.0 / 255.0, 1.0,
            27.0 / 255.0, 47.0 / 255.0, 60.0 / 255.0, 1.0,
            10.0 / 255.0, 68.0 / 255.0, 151.0 / 255.0, 1.0 };
        CGFloat colorStops[4] = {0.0, 0.5, 1.0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        _backgroundGradient = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 3);
        CGColorSpaceRelease(colorSpace);
    }
    return _backgroundGradient;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
//    [[UIColor colorWithRed:1.0/255.0 green:10.0/255.0 blue:22.0/255.0 alpha:1.0] setStroke];
//    [_scrollCircle setLineWidth:2.0];
//    [_scrollCircle stroke];

    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(c);
    CGContextAddPath(c, [_scrollCircle CGPath]);
    CGContextClip(c);
        
    //  Draw a linear gradient from top to bottom
    CGPoint start = CGPointMake(_halfWidth, 0.0);
    CGPoint end = CGPointMake(_halfWidth, self.frame.size.height);
    CGContextDrawLinearGradient(c, [self backgroundGradient], start, end, 0);
    
    CGContextRestoreGState(c);
    
    
    [[UIColor colorWithRed:151.0/255.0 green:93.0/255.0 blue:10.0/255.0 alpha:1.0] setFill];
    [_buttonCircle fill];
    [[UIColor colorWithRed:1.0/255.0 green:10.0/255.0 blue:22.0/255.0 alpha:1.0] setStroke];
    [_buttonCircle setLineWidth:2.0];
    [_buttonCircle stroke];
    
    //draw the label
    [[UIColor blackColor] setFill];
    
    CGRect btnCircRect = _buttonCircle.bounds;
    UIFont *btnLblFont = [UIFont systemFontOfSize:18.0];
    CGSize btnLblSz = [_buttonLabel sizeWithFont:btnLblFont
                               constrainedToSize:btnCircRect.size 
                                   lineBreakMode:UILineBreakModeTailTruncation];
    CGPoint btnLblPt = CGPointMake(btnCircRect.origin.x + (btnCircRect.size.width - btnLblSz.width) / 2.0, 
                                   btnCircRect.origin.y + (btnCircRect.size.height - btnLblSz.height) / 2.0);
    [_buttonLabel drawAtPoint:btnLblPt withFont:btnLblFont];

}


@end
