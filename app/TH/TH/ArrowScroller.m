//
//  ArrowScroller.m
//  TH
//
//  Created by Mark Blackwell on 25/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrowScroller.h"
#import "DebugMacros.h"
#import "UIDeviceHardware.h"

@implementation ArrowScroller

@synthesize textLabel = _textLabel;
@synthesize lastScroll = _lastScroll, lastScrollVelocity = _lastScrollVelocity;
@synthesize fullScale = _fullScale, stepScale = _stepScale;
@synthesize delegate = _delegate;
@synthesize isScrolling = _isScrolling;
@synthesize scrollDirection = _scrollDirection;

static const CGFloat kArrowImageInset = 0.0;

- (void)calcMaxScrollVelocity {
    //TODO: make this a calc considering step scale, full scale and the device capability
    
    // each step seems to take roughly 100m clock cycles to calc
    
    CGFloat maxStepsPerSec = [UIDeviceHardware processorSpeedInMhz] / 100.0;
    CGFloat scrollWidth = self.frame.size.width - _arrowInUse.frame.size.width - kArrowImageInset * 2.0;
    CGFloat pixelsPerStep = scrollWidth * _stepScale /_fullScale;
    
    _maxScrollVelocity = maxStepsPerSec * pixelsPerStep;
}

- (void)doInit {
    self.backgroundColor = [UIColor clearColor];
    
    _pixelsSinceLastStep = 0.0;
    _isScrolling = NO;
    _fullScale = 10.0;
    _stepScale = 1.0;
    
    _leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftArrow.png"]];
    _rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow.png"]];

    
//    NSString *tockpath = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
//    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:tockpath], &tockSoundID);
    
    //    NSString *imgpath = [[NSBundle mainBundle] pathForResource:@"Wheel" ofType:@"png"];
    //    UIImage *img = [[UIImage alloc] initWithContentsOfFile:imgpath];
    //    UIImageView *bgrdImgView = [[UIImageView alloc] initWithImage:img];
    //    [self addSubview:bgrdImgView];
    //    [img release];
    //    [bgrdImgView release];
    
}

- (id)initWithFrame:(CGRect)frame {
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
    
    [_delegate release];
    [_leftArrow release];
    [_rightArrow release];
    
//    AudioServicesDisposeSystemSoundID(tockSoundID);
}

- (void)layoutArrowWithAnimation:(BOOL)animation {
    CGSize imgSz = _arrowInUse.frame.size;
    CGFloat yPos = 0.0;
    if (_scrollDirection == ArrowScrollDirectionRight) {
        yPos = kArrowImageInset;
    }
    else {
        yPos = self.frame.size.width - kArrowImageInset - imgSz.width;
    }
    
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
    }
    
    _arrowInUse.frame = CGRectMake(yPos, 
                                   (self.frame.size.height - imgSz.height) / 2.0, 
                                   imgSz.width, 
                                   imgSz.height);
    if (animation) {
        [UIView commitAnimations];
    }
    
}



- (void)layoutSubviews {
    DLog(@"doing");

    if (_scrollDirection == ArrowScrollDirectionLeft) {
        _arrowInUse = _leftArrow;
    }
    else {
        _arrowInUse = _rightArrow;
    }
    
    [self addSubview:_arrowInUse];
        
    [self layoutArrowWithAnimation:NO];
    
    [self calcMaxScrollVelocity];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self];
    _lastTouchTime = [NSDate timeIntervalSinceReferenceDate];
    _pixelsSinceLastStep = 0.0;
    
    //if we already have a tap before a move, then it's a doubletap
    if (_isSingleTap)
        _isDoubleTap = YES;
    
    _isSingleTap = (touches.count == 1 && CGRectContainsPoint(_arrowInUse.frame, _lastTouch));
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSingleTap = NO;
    _isDoubleTap = NO;
    
    CGPoint movedPoint = [[touches anyObject] locationInView:self];
    //DLog(@"last touch (%@) moved to %@", NSStringFromCGPoint(_lastTouch), NSStringFromCGPoint(movedPoint));
    _lastScroll = movedPoint.x - _lastTouch.x;
    
//    DLog(@"lastScroll = %5.2f", _lastScroll);
    
    //ignore invalid scrolls
    if ((_lastScroll > 0.0 && _scrollDirection == ArrowScrollDirectionLeft) ||
        (_lastScroll < 0.0 && _scrollDirection == ArrowScrollDirectionRight))
        return;
    
//    DLog(@"arrow locn is %5.2f", _arrow.frame.origin.x + _lastScroll);
    if ((_scrollDirection == ArrowScrollDirectionLeft && _arrowInUse.frame.origin.x <= kArrowImageInset) ||
        (_scrollDirection == ArrowScrollDirectionRight && 
         _arrowInUse.frame.origin.x + _arrowInUse.frame.size.width + kArrowImageInset >= self.frame.size.width))
        return;
    
    _isScrolling = YES;
    
    if (_scrollDirection == ArrowScrollDirectionLeft) {
        _lastScroll = MAX(_arrowInUse.frame.origin.x * -1, _lastScroll);
        _arrowInUse.center = CGPointMake(_arrowInUse.center.x + _lastScroll, _arrowInUse.center.y);
        _lastScroll *= -1.0;
    }
    else {
        _lastScroll = MIN(self.frame.size.width - _arrowInUse.frame.origin.x - _arrowInUse.frame.size.width, _lastScroll);
        _arrowInUse.center = CGPointMake(_arrowInUse.center.x + _lastScroll, _arrowInUse.center.y);
    }
    
    NSTimeInterval movedTime = [NSDate timeIntervalSinceReferenceDate];
    _lastScrollVelocity = _lastScroll / (movedTime - _lastTouchTime);
//    DLog(@"moving at %5.2f p/s", _lastScrollVelocity);
    
    _pixelsSinceLastStep += _lastScroll;
//    DLog(@"pixelsSinceLastStep = %5.2f", _pixelsSinceLastStep);
    if (_lastScrollVelocity < _maxScrollVelocity) {
        [self doSteps];
    }
        
    _lastTouch = movedPoint;
    _lastTouchTime = movedTime;
}

- (void)doSteps {
    CGFloat scrollWidth = self.frame.size.width - _arrowInUse.frame.size.width - kArrowImageInset * 2.0;
    //subtract 0.5 from the scroll width to make sure we get the full number of steps
    CGFloat steps = _pixelsSinceLastStep * _fullScale / (scrollWidth - 0.5);
    if (_stepScale <= 0.0 || ABS(steps) >= _stepScale) {
        [_delegate arrowScroller:self didScroll:(NSInteger)MIN(floor(steps), _fullScale)];
        //        AudioServicesPlaySystemSound(tockSoundID);
        _pixelsSinceLastStep -= floor(steps) / (_fullScale / scrollWidth);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap) { 
        [_delegate arrowScrollerTapped:self];
//        AudioServicesPlaySystemSound(tockSoundID);
    }
    else {
        [self doSteps];
        [self layoutArrowWithAnimation:YES];
        _pixelsSinceLastStep = 0.0;
    }
    
    _isScrolling = NO;
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self layoutArrowWithAnimation:NO];
    _isScrolling = NO;
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
