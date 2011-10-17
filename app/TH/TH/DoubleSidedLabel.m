//
//  DoubleSidedLabel.m
//  TH
//
//  Created by Mark Blackwell on 6/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DoubleSidedLabel.h"

@interface DoubleSidedLabel ()

@property (nonatomic, retain, readwrite) UILabel *sideOne, *sideTwo;

@end

@implementation DoubleSidedLabel

@synthesize sideOne = _sideOne, sideTwo = _sideTwo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _sideOne = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _sideTwo = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        
        _sideOne.backgroundColor = [UIColor clearColor];
        _sideTwo.backgroundColor = [UIColor clearColor];
                
        _sideTwo.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
        _sideTwo.layer.zPosition = -0.01;
        
        [self addSubview:_sideOne];
        [self addSubview:_sideTwo];
        
        _isSideOneShowing = YES;
        
        CATransform3D perspectiveTransform = CATransform3DIdentity;
        perspectiveTransform.m34 = -1.0/800.0;
        self.layer.transform = perspectiveTransform;
    }
    return self;
}

+ (Class)layerClass {
    return [CATransformLayer class];
}

- (UIFont *)font {
    if (_isSideOneShowing)
        return _sideOne.font;
    
    return _sideTwo.font;
}

- (void)setFont:(UIFont *)font {
    _sideOne.font = font;
    _sideTwo.font = font;
}

- (UIColor *)textColor {
    if (_isSideOneShowing)
        return _sideOne.textColor;
    
    return _sideTwo.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    if (_isSideOneShowing)
        _sideOne.textColor = textColor;
    else
        _sideTwo.textColor = textColor;
}

- (UILabel *)visibleLabel {
    if (_isSideOneShowing)
        return _sideOne;
    
    return _sideTwo;
}
- (UILabel *)invisibleLabel {
    if (_isSideOneShowing)
        return _sideTwo;
    
    return _sideOne;
}
- (void)flipWithAnimation:(BOOL)animated {
    if (_isSideOneShowing) {
        _sideTwo.textColor = _sideOne.textColor;
        _sideOne.textColor = [UIColor clearColor];
    }
    else {
        _sideOne.textColor = _sideTwo.textColor;
        _sideTwo.textColor = [UIColor clearColor];
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.5];
    }
    
    if (_isSideOneShowing) {
        self.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
    }
    else {
        self.layer.transform = CATransform3DIdentity;
    }
    
    if (animated)
        [UIView commitAnimations];
    
    _isSideOneShowing = !_isSideOneShowing;
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
