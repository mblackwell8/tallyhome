//
//  Flipper.m
//  TH
//
//  Created by Mark Blackwell on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Flipper.h"
#import "DebugMacros.h"

@implementation Flipper

@synthesize isFrontShowing = _isFrontShowing;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isFrontShowing = YES;
        
//        CATransform3D perspectiveTransform = CATransform3DIdentity;
//        perspectiveTransform.m34 = -1.0/20.0;
//        self.layer.transform = perspectiveTransform;
    }
    return self;
}

+ (Class)layerClass {
    return [CATransformLayer class];
}

- (void)addFrontView:(UIView *)front {
    [self addSubview:front];
}
- (void)addBackView:(UIView *)back {
    back.layer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
    back.layer.zPosition = -0.01;
    
    [self addSubview:back];
}

- (void)flipForward {
//    DLog(@"preflip: %@", NSStringFromCGRect(self.frame));
    CATransform3D tf = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
    
    //can't make this work
    //tf.m34 = -1.0/500.0;
    
    self.layer.transform = tf;
//    DLog(@"postflip: %@", NSStringFromCGRect(self.frame));
    [self setNeedsLayout];
    
    _isFrontShowing = NO;
}

- (void)flipBackward {
//    DLog(@"preflipback: %@", NSStringFromCGRect(self.frame));
    self.layer.transform = CATransform3DIdentity;
//    DLog(@"postflipback: %@", NSStringFromCGRect(self.frame));
    
    [self setNeedsLayout];
    
    _isFrontShowing = YES;
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
