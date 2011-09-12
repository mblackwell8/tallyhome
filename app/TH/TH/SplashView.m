/**
 * SplashView.m modified by Giraldo Rosales.
 * Based on the SplashView code by Shannon Appelcline.
 * Visit www.liquidgear.net for documentation and updates.
 *
 * Copyright (c) 2009 Nitrogen Design, Inc. All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

#import "SplashView.h"

@implementation SplashView
@synthesize delegate, delay, touchAllowed, animation, isFinishing, animationDelay;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delay                                      = 2;
        self.touchAllowed               = NO;
        self.animation                  = SplashViewAnimationNone;
        self.animationDelay     = .5;
        self.isFinishing                = NO;
    }
    
    return self;
}

- (void)startSplash {
    UIImage* image  = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]];
    
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:self];
    splashImage = [[UIImageView alloc] initWithImage:image];
    [image release];
    
    [self addSubview:splashImage];
    [splashImage release];
    
    if(!self.touchAllowed) {
        [self performSelector:@selector(dismissSplash) withObject:self afterDelay:self.delay];
    }
}

- (void)dismissSplash {
    NSLog(@"dismissSplash");
    
    if (self.isFinishing || self.animation == SplashViewAnimationNone) {
        [self dismissSplashFinish];
    } else if (self.animation == SplashViewAnimationSlideLeft) {
        CABasicAnimation *animSplash            = [CABasicAnimation animationWithKeyPath:@"transform"];
        animSplash.duration                                                     = self.animationDelay;
        animSplash.removedOnCompletion  = NO;
        animSplash.fillMode                                                     = kCAFillModeForwards;
        animSplash.toValue                                                      = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeTranslation(-320, 0))];
        animSplash.delegate                                                     = self;
        [self.layer addAnimation:animSplash forKey:@"animateTransform"];
    } else if (self.animation == SplashViewAnimationFade) {
        CABasicAnimation *animSplash            = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animSplash.duration                                                     = self.animationDelay;
        animSplash.removedOnCompletion  = NO;
        animSplash.fillMode                                                     = kCAFillModeForwards;
        animSplash.toValue                                                      = [NSNumber numberWithFloat:0];
        animSplash.delegate                                                     = self;
        [self.layer addAnimation:animSplash forKey:@"animateOpacity"];
    }
    
    self.isFinishing = YES;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self dismissSplashFinish];
}

- (void)dismissSplashFinish {
    if(splashImage) {
        [splashImage removeFromSuperview];
        [self removeFromSuperview];
    }
    
    if(self.delegate != NULL && [self.delegate respondsToSelector:@selector(splashIsDone)]) {
        [delegate splashIsDone];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.touchAllowed) {
        [self dismissSplash];
    }
}

- (void)dealloc {
    [super dealloc];
}

@end