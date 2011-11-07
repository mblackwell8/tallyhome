//
//  ArrowScroller.m
//  TH
//
//  Created by Mark Blackwell on 25/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrowScroller.h"
#import "DebugMacros.h"

@implementation ArrowScroller

@synthesize textLabel = _textLabel;
@synthesize lastScroll = _lastScroll, lastScrollVelocity = _lastScrollVelocity;
@synthesize fullScale = _fullScale, stepScale = _stepScale;
@synthesize delegate = _delegate;
@synthesize isScrolling = _isScrolling;
@synthesize scrollDirection = _scrollDirection;

- (void)doInit {
    self.backgroundColor = [UIColor clearColor];
    
    _pixelsSinceLastStep = 0.0;
    _isScrolling = NO;
    _fullScale = 10.0;
    _stepScale = 1.0;
    
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
    
    [_delegate release];
    
    AudioServicesDisposeSystemSoundID(tockSoundID);
}





- (void)layoutSubviews {
    DLog(@"doing");

    //create label...
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouch = [[touches anyObject] locationInView:self];
    _lastTouchTime = [NSDate timeIntervalSinceReferenceDate];
    _pixelsSinceLastStep = 0.0;
    
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
    _lastScroll = movedPoint.x - _lastTouch.x;
    
    DLog(@"lastScroll = %5.2f", _lastScroll);
    
    //ignore invalid scrolls
    if ((_lastScroll > 0.0 && _scrollDirection == ArrowScrollDirectionLeft) ||
        (_lastScroll < 0.0 && _scrollDirection == ArrowScrollDirectionRight))
        return;
    
    _isScrolling = YES;
    
    if (_scrollDirection == ArrowScrollDirectionLeft) {
        _lastScroll *= -1.0;
    }
    NSTimeInterval movedTime = [NSDate timeIntervalSinceReferenceDate];
    _lastScrollVelocity = _lastScroll / (movedTime - _lastTouchTime);
    
    _pixelsSinceLastStep += _lastScroll;
    DLog(@"pixelsSinceLastStep = %5.2f", _pixelsSinceLastStep);
    CGFloat steps = _pixelsSinceLastStep * _fullScale / self.frame.size.width;
    if (_stepScale <= 0.0 || ABS(steps) >= _stepScale) {
        [_delegate arrowScroller:self didScroll:(NSInteger)steps];
        AudioServicesPlaySystemSound(tockSoundID);
        _pixelsSinceLastStep = 0.0;
    }
        
    _lastTouch = movedPoint;
    _lastTouchTime = movedTime;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap) { 
        [_delegate arrowScrollerTapped:self];
        AudioServicesPlaySystemSound(tockSoundID);
    }
    else {
//???        
    }
    
    _isScrolling = NO;
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
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
