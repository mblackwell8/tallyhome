//
//  FlipLabel.m
//  TH
//
//  Created by Mark Blackwell on 26/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipLabel.h"
#import "Flipper.h"
#import "DebugMacros.h"

@interface FlipLabel ()

@property (nonatomic, retain, readwrite) UILabel *visibleLabel;
@property (nonatomic, retain) NSMutableArray *bottomHalves, *topHalves, *flips;
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

- (void)createFlipImages;
- (void)incrementDigit;
- (void)decrementDigit;

- (void)flipForwardWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)flipBackwardWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration;

@end

@implementation FlipLabel

static const int kFlipImagesTag = 99;
static const double kAnimationDuration = 0.5;

@synthesize visibleLabel = _visibleLabel;
@synthesize bottomHalves = _bottomHalves, topHalves = _topHalves, flips = _flips;
@synthesize digit = _digit;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shouldReload = YES;
        
        UILabel *visLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        
        visLbl.backgroundColor = [UIColor clearColor];
        
        [self addSubview:visLbl];
        self.visibleLabel = visLbl;
        [visLbl release];

    }
    return self;
}

- (void)dealloc {
    [_visibleLabel release];
}

- (void)reload {
    [_visibleLabel removeFromSuperview];
    
    self.visibleLabel = nil;
    
    _shouldReload = YES;
    [self setNeedsDisplay];
}

- (UIFont *)font {
    return _visibleLabel.font;
}

- (void)setFont:(UIFont *)font {
    _visibleLabel.font = font;
}

- (UIColor *)textColor {
    return _visibleLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _visibleLabel.textColor = textColor;
}

- (void)setDigit:(NSUInteger)digit {
    _digit = digit;
    _visibleLabel.text = [NSString stringWithFormat:@"%d", digit];
}

- (void)incrementDigit {
    [self setDigit:(_digit == 9 ? 0 : _digit + 1)];
}
- (void)decrementDigit {
    [self setDigit:(_digit == 0 ? 9 : _digit - 1)];
}

- (void)layoutSubviews {
    if (!_shouldReload)
        return;
    
    [self createFlipImages];
    
    _shouldReload = NO;
}

- (void)createFlipImages {
    CGRect frame = self.frame;
    CGSize flipSz = CGSizeMake(frame.size.width, frame.size.height / 2.0);
    
    NSString *visTxt = _visibleLabel.text;
    NSMutableArray *bottoms = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *tops = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (int i = 0; i < 10; i++) {
        _visibleLabel.text = [NSString stringWithFormat:@"%d", i];
        
        //take an image of the top half of the visible label
        UIGraphicsBeginImageContext(flipSz);
        CGContextRef cref = UIGraphicsGetCurrentContext();
        [_visibleLabel.layer renderInContext:cref];
        UIImage *topFront = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *tfView = [[UIImageView alloc] initWithImage:topFront];
        tfView.tag = kFlipImagesTag;
        
        tfView.backgroundColor = self.backgroundColor;
        
        [tops insertObject:tfView atIndex:i];
        
        //take an image of the bottom half of the visible label
        UIGraphicsBeginImageContext(flipSz);
        cref = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(cref, 0.0, -flipSz.height);
        [_visibleLabel.layer renderInContext:cref];
        UIImage *bottomFront = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *bfView = [[UIImageView alloc] initWithImage:bottomFront];
        bfView.frame = CGRectMake(0.0, flipSz.height, flipSz.width, flipSz.height);
        bfView.tag = kFlipImagesTag;
        
        bfView.backgroundColor = self.backgroundColor;

        [bottoms insertObject:bfView atIndex:i];
        
        [tfView release];
        [bfView release];
        
    }
    
    NSMutableArray *flips = [[NSMutableArray alloc] initWithCapacity:10];    
    
    for (int f = 0; f < 10; f++) {
        //create a flipper using the top half of one image and the bottom half of the next
        Flipper *flipper = [[Flipper alloc] initWithFrame:CGRectMake(0.0, 0.0, flipSz.width, flipSz.height)];
        
        UIImageView *fv = [tops objectAtIndex:f];
        UIImageView *bv = [bottoms objectAtIndex:(f == 9 ? 0 : f + 1)];
        
        UIImageView *flipFV = [[UIImageView alloc] initWithImage:fv.image];
        flipFV.backgroundColor = self.backgroundColor;
        UIImageView *flipBV = [[UIImageView alloc] initWithImage:bv.image];
        flipBV.backgroundColor = self.backgroundColor;
        
        [flipper addFrontView:flipFV];
        [flipper addBackView:flipBV];
        [self setAnchorPoint:CGPointMake(0.5, 1.0) forView:flipper];
        flipper.tag = kFlipImagesTag;
        
        [flips insertObject:flipper atIndex:f];
        
        [flipFV release];
        [flipBV release];
        [flipper release];
    }
    
    self.bottomHalves = bottoms;
    self.topHalves = tops;
    self.flips = flips;
    
    [bottoms release];
    [tops release];
    [flips release];
    
    _visibleLabel.text = visTxt;
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (void)flipForwardTo:(NSUInteger)digit withAnimation:(BOOL)animated {
    if (!animated) {
        [self setDigit:digit];
        return;
    }
    
    NSUInteger nFlips = (digit >= _digit ? digit - _digit : digit - _digit + 10);
    NSTimeInterval duration = kAnimationDuration;
    if (nFlips > 1) {
        duration /= nFlips;
    }
    
    for (int i = 0; i < nFlips; i++) {
        [self flipForwardWithAnimation:animated duration:duration];
    }
    
}

- (void)flipForwardWithAnimation:(BOOL)animated {
    [self flipForwardWithAnimation:animated duration:kAnimationDuration];
}

- (void)flipForwardWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration {
    if (!animated || duration <= 0.0) {
        [self incrementDigit];
        
        return;
    }
    
    DLog(@"FWD flipping from %d to %d", _digit, (_digit == 9 ? 0 : _digit + 1));
    
    //show the bottom half image of the visible label
    UIImageView *bh = [_bottomHalves objectAtIndex:_digit];
    [self addSubview:bh];
        
    //get the right flipper
    Flipper *flipView = [_flips objectAtIndex:_digit];
    
    //make sure that the front is showing on the flipper
    if (!flipView.isFrontShowing) {
        DLog(@"front now showing... flipping");
        [flipView flipBackward];
    }
    
    //show the top half flipper
    [self addSubview:flipView];
    
    //increment the visible label (it's behind the others)
    [self incrementDigit];
    
    //flip the flipper
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(flipForwardAnimationDidStop:finished:context:)];
    [UIView setAnimationDuration:duration];
    
    [flipView flipForward];
    
    [UIView commitAnimations];

}
         
- (void)flipForwardAnimationDidStop:(NSString *)animationID 
                           finished:(NSNumber *)finished 
                            context:(void *)context {
    //remove the temp view
    //HACK: think this is safe...
    for (UIView *view in self.subviews) {
        if (view.tag == kFlipImagesTag)
            [view removeFromSuperview];
    }
    
//    Flipper *prevFlipper = [_flips objectAtIndex:(_digit == 0 ? 9 : _digit - 1)];
//    NSAssert(prevFlipper && ![prevFlipper isFrontShowing], @"invalid situation");
//    [prevFlipper flipBackward];
//    NSAssert(prevFlipper && [prevFlipper isFrontShowing], @"invalid situation");
}

- (void)flipBackwardTo:(NSUInteger)digit withAnimation:(BOOL)animated {
    if (!animated) {
        [self setDigit:digit];
        return;
    }
    
    NSUInteger nFlips = (digit <= _digit ? _digit - digit : _digit - digit + 10);
    NSTimeInterval duration = kAnimationDuration;
    if (nFlips > 1) {
        duration /= nFlips;
    }
    
    for (int i = 0; i < nFlips; i++) {
        [self flipBackwardWithAnimation:animated duration:duration];
    }
    
}

- (void)flipBackwardWithAnimation:(BOOL)animated {
    [self flipBackwardWithAnimation:animated duration:kAnimationDuration];
}

- (void)flipBackwardWithAnimation:(BOOL)animated duration:(NSTimeInterval)duration {
//    if (!animated || duration <= 0.0) {
//        [self decrementDigit];
//        
//        return;
//    }
//    
//    DLog(@"BACK flipping from %d to %d", _digit, (_digit == 0 ? 9 : _digit - 1));
//    
//    //show the top half image of the visible label
//    UIImageView *th = [_topHalves objectAtIndex:_digit];
//    [self addSubview:th];
//    
//    //get the right flipper
//    Flipper *flipView = [_flips objectAtIndex:_digit];
//    
//    //make sure that the back is showing on the flipper
//    if (flipView.isFrontShowing) {
//        [flipView flipForward];
//    }
//    
//    //show the top half flipper
//    [self addSubview:flipView];
//    
//    //decrement the visible label (it's behind the others)
//    [self decrementDigit];
//    
//    //flip the flipper
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(flipBackwardAnimationDidStop:finished:context:)];
//    [UIView setAnimationDuration:duration];
//    
//    [flipView flipBackward];
//    
//    [UIView commitAnimations];
//    
}

- (void)flipBackwardAnimationDidStop:(NSString *)animationID 
                           finished:(NSNumber *)finished 
                            context:(void *)context {
    //remove the temp view
    //HACK: think this is safe...
    for (UIView *view in self.subviews) {
        if (view.tag == kFlipImagesTag)
            [view removeFromSuperview];
    }
    
    Flipper *prevFlipper = [_flips objectAtIndex:(_digit == 9 ? 0 : _digit + 1)];
    NSAssert(prevFlipper && [prevFlipper isFrontShowing], @"invalid situation");
    [prevFlipper flipForward];
    NSAssert(prevFlipper && ![prevFlipper isFrontShowing], @"invalid situation");
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
