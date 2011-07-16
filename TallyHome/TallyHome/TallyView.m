//
//  TallyView.m
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyView.h"

#define TH_POSN_SCALES {0.5,0.65,0.9,0.65,0.5}

#define TH_POSN0_SCALE 0.5
#define TH_POSN1_SCALE 0.75
#define TH_POSN2_SCALE 1.0
#define TH_POSN3_SCALE 0.75
#define TH_POSN4_SCALE 0.5

@implementation TallyView

- (void)doInit {
    UIGestureRecognizer *pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [super addGestureRecognizer:pang];
    [pang release];
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInit];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


// arrange in 5 rows
- (void)setViews:(NSArray *)views {
    NSAssert(views.count == 5, @"Need five views in the array");
    CGFloat height = self.frame.size.height / 5.0;
    CGFloat currY = 0.0;
    CGFloat scales[5] = TH_POSN_SCALES;
    for (int i = 0; i < 5; i++) {
        UIView *v = [views objectAtIndex:i];
        v.frame = CGRectMake(0.0, currY, self.frame.size.width, height);
        currY += height;
        
        v.transform = CGAffineTransformScale(v.transform, scales[i], scales[i]);
        
        [self addSubview:v];
    }
    
    panPointsSinceLastShift = 0.0;
    
    _views = [NSMutableArray arrayWithArray:views];
    [_views retain];
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        
        if (translation.y > 0.0) {
            panPointsSinceLastShift += translation.y;
            
            //move and scale all the views
            int ix = 0;
            CGFloat scales[5] = TH_POSN_SCALES;
            CGFloat height = self.frame.size.height / 5.0;
            for (UIView *v in _views) {
                v.center = CGPointMake(v.center.x, v.center.y + translation.y);
                CGFloat scale = powf(scales[(ix + 1 == 5 ? 0 : ix + 1)] / scales[ix],panPointsSinceLastShift / height);
                NSLog(@"scaling %d by %5.4f", ix, scale);
                v.transform = CGAffineTransformScale(v.transform, scale, scale);
                
                ix += 1;
            }
            
            UIView *bottom = [_views objectAtIndex:4];
            if (bottom.center.y > self.frame.size.height) {
                NSLog(@"shuffling");
                bottom.center = CGPointMake(bottom.center.x, 0.0);
                [_views removeLastObject];
                [_views insertObject:bottom atIndex:0];
                panPointsSinceLastShift = 0.0;
            }
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}



@end
