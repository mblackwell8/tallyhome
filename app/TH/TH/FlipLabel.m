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

@property (nonatomic, retain) NSMutableArray *bottomHalves, *topHalves;
@property (nonatomic, retain) NSArray *flips;

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

@synthesize font = _font, textColor = _textColor;
@synthesize bottomHalves = _bottomHalves, topHalves = _topHalves, flips = _flips;
@synthesize digit = _digit;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shouldReload = YES;
    }
    return self;
}

- (void)dealloc {
    [_font release];
    [_textColor release];
    [_bottomHalves release];
    [_topHalves release];
    [_flips release];
}

- (void)reload {
    _shouldReload = YES;
    [self setNeedsDisplay];
}

- (void)setDigit:(NSUInteger)digit {
    [self flipForwardTo:digit withAnimation:NO];
    
    _digit = digit;
}

- (void)incrementDigit {
    _digit = (_digit == 9 ? 0 : _digit + 1);
}
- (void)decrementDigit {
    _digit = (_digit == 0 ? 9 : _digit - 1);
}

- (void)layoutSubviews {
    if (!_shouldReload)
        return;
    
    [self createFlipImages];
    
    _shouldReload = NO;
}

- (void)beginImageContextWithSize:(CGSize)sz {
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {        
        CGFloat scale = [[UIScreen mainScreen] scale];
        UIGraphicsBeginImageContextWithOptions(sz, NO, scale);
    }
    else {
        UIGraphicsBeginImageContext(sz);
    }

}

- (void)createFlipImages {
    CGRect frame = self.frame;
    CGSize flipSz = CGSizeMake(frame.size.width, frame.size.height / 2.0);
    UILabel *sample = [[UILabel alloc] initWithFrame:frame];
    sample.font = _font;
    sample.numberOfLines = 1;
    sample.minimumFontSize = _font.pointSize;
    sample.textColor = _textColor;
    sample.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *bottoms = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *tops = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (int i = 0; i < 10; i++) {
        sample.text = [NSString stringWithFormat:@"%d", i];
                
        //take an image of the top half of the visible label
        [self beginImageContextWithSize:flipSz];
        CGContextRef cref = UIGraphicsGetCurrentContext();
        [sample.layer renderInContext:cref];
        UIImage *topFront = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [tops addObject:topFront];
        
        //take an image of the bottom half of the visible label
        [self beginImageContextWithSize:flipSz];
        cref = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(cref, 0.0, -flipSz.height);
        [sample.layer renderInContext:cref];
        UIImage *bottomFront = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [bottoms addObject:bottomFront];
    }
    
    NSMutableArray *flips = [[NSMutableArray alloc] initWithCapacity:10];    
    
    for (int f = 0; f < 10; f++) {
        //create a flipper using the top half of one image and the bottom half of the next
        Flipper *flipper = [[Flipper alloc] initWithFrame:CGRectMake(0.0, 0.0, flipSz.width, flipSz.height)];
        
        UIImage *fv = [tops objectAtIndex:f];
        UIImage *bv = [bottoms objectAtIndex:(f == 9 ? 0 : f + 1)];
        
        UIImageView *frontView = [[UIImageView alloc] initWithImage:fv];
        frontView.backgroundColor = self.backgroundColor;
        UIImageView *backView = [[UIImageView alloc] initWithImage:bv];
        backView.backgroundColor =  self.backgroundColor;
        
        [flipper addFrontView:frontView];
        [flipper addBackView:backView];
        [self setAnchorPoint:CGPointMake(0.5, 1.0) forView:flipper];
        
        [flips insertObject:flipper atIndex:f];
        [self addSubview:flipper];
        
        [frontView release];
        [backView release];
        [flipper release];
    }
    
    NSArray *topFlips = [flips objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
    self.topHalves = [[[NSMutableArray alloc] initWithArray:topFlips] autorelease]; 
    for (UIView *view in _topHalves) {
        [self sendSubviewToBack:view];
    }
    
    NSArray *bottomFlips = [flips objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(5, 5)]];
    self.bottomHalves = [[[NSMutableArray alloc] initWithArray:bottomFlips] autorelease];

    [_bottomHalves makeObjectsPerformSelector:@selector(flipForward)];
        
    self.flips = [NSArray arrayWithArray:flips];
    _digit = 0;
    
    [bottoms release];
    [tops release];
    [flips release];
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
    DLog(@"FWD flipping from %d to %d", _digit, (_digit == 9 ? 0 : _digit + 1));
    
    //take the front most of the topHalves
    Flipper *flipView = [_topHalves objectAtIndex:0];
    [self bringSubviewToFront:flipView];
    
    [self incrementDigit];
    
    //flip the flipper
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:duration];
    
    [flipView flipForward];
    
    [UIView commitAnimations];
    
    [_bottomHalves addObject:flipView];
    [_topHalves removeObject:flipView];
    
    Flipper *backFlipView = [_bottomHalves objectAtIndex:0];
    [self sendSubviewToBack:backFlipView];
    [backFlipView flipBackward];
    [_topHalves addObject:backFlipView];
    [_bottomHalves removeObject:backFlipView];

}
         
- (void)flipBackwardTo:(NSUInteger)digit withAnimation:(BOOL)animated {
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
    DLog(@"BACK flipping from %d to %d", _digit, (_digit == 0 ? 9 : _digit - 1));
    
    //take the back most of the bottomHalves
    Flipper *flipView = [_bottomHalves lastObject];
    
    [self decrementDigit];
    
    //flip the flipper
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:duration];
    
    [flipView flipBackward];
    
    [UIView commitAnimations];

    [self insertSubview:flipView aboveSubview:[_topHalves objectAtIndex:0]];
    
    [_topHalves insertObject:flipView atIndex:0];
    [_bottomHalves removeObject:flipView];
    
    Flipper *backFlipView = [_topHalves lastObject];
    [backFlipView flipForward];
    [self insertSubview:backFlipView belowSubview:[_bottomHalves objectAtIndex:0]];
    [_bottomHalves insertObject:backFlipView atIndex:0];
    [_topHalves removeObject:backFlipView];
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
