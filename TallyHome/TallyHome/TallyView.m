//
//  TallyView.m
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyView.h"
#import "DebugMacros.h"

#define TH_POSN0_SCALE 0.5
#define TH_POSN1_SCALE 0.5
#define TH_POSN2_SCALE 0.7
#define TH_POSN3_SCALE 0.9
#define TH_POSN4_SCALE 0.7
#define TH_POSN5_SCALE 0.5
#define TH_POSN6_SCALE 0.5

#define TH_POSN_SCALES {TH_POSN0_SCALE,TH_POSN1_SCALE,TH_POSN2_SCALE,TH_POSN3_SCALE,TH_POSN4_SCALE,TH_POSN5_SCALE,TH_POSN6_SCALE}

#define TH_NUMVISIBLECELLS 5.0

@implementation TallyView

- (void)doInit {
    UIGestureRecognizer *pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [super addGestureRecognizer:pang];
    [pang release];
    
    panPointsSinceLastReshuffle = 0.0;
    
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

- (void)_positionViews {
    NSAssert(_views.count == 7, @"Need seven views in the array");
    DLog(@"positioning views...");
    CGFloat height = self.frame.size.height / TH_NUMVISIBLECELLS;
    DLog(@"curr height: %5.2f", height);
    CGFloat currY = -height;
    CGFloat scales[7] = TH_POSN_SCALES;
    int i = 0;
    [UIView beginAnimations:nil context:nil];
    for (UIView *v in _views) {
        [UIView setAnimationsEnabled:(i > 0 && i < 6)];
        CGFloat h = height * scales[i];
        CGFloat w = self.frame.size.width * scales[i];
        CGFloat x = (self.frame.size.width - w) / 2.0;
        CGFloat y = currY + (height - h) / 2.0;
        
        v.frame = CGRectMake(x, y, w, h);
        
        currY += height;
        i += 1;
    }
    [UIView commitAnimations];
    
    panPointsSinceLastReshuffle = 0.0;
}

+ (void)_scaleView:(UIView *)view by:(CGFloat)scale {
    CGFloat oldHeight = view.frame.size.height;
    CGFloat oldWidth = view.frame.size.width;
    CGFloat h = oldHeight * scale;
    CGFloat w = oldWidth * scale;
    CGFloat x = view.frame.origin.x + (oldWidth - w) / 2.0;
    CGFloat y = view.frame.origin.y + (oldHeight - h) / 2.0;
    
    view.frame = CGRectMake(x, y, w, h);
}


// arrange in 5 rows
- (void)setViews:(NSArray *)views {
    _views = [NSMutableArray arrayWithArray:views];
    NSAssert(_views.count == 7, @"Need seven views in the array");
    [self _positionViews];
    for (UIView *v in _views) {
        [self addSubview:v];
    }
    
    [_views retain];
}

//returns YES if the views are shuffled forwards
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion {
    panPointsSinceLastReshuffle += move;
    //DLog(@"%5.2f", panPointsSinceLastReshuffle);
    
    if (portion < 0.0)
        return NO; 
    
    CGFloat cellHeight = self.frame.size.height / TH_NUMVISIBLECELLS;
    if (fabsf(panPointsSinceLastReshuffle) / cellHeight > portion) {
        DLog(@"reshuffling...");
        NSAssert(panPointsSinceLastReshuffle != 0.0, @"Error");
        if (panPointsSinceLastReshuffle > 0.0) {
            UIView *tmp = [_views lastObject];
            [_views removeLastObject];
            [_views insertObject:tmp atIndex:0];
            [self _positionViews];
            
            panPointsSinceLastReshuffle = fmaxf(panPointsSinceLastReshuffle - cellHeight, 0.0);
        }
        else if (panPointsSinceLastReshuffle < 0.0) {
            UIView *tmp = [_views objectAtIndex:0];
            [_views removeObjectAtIndex:0];
            [_views addObject:tmp];
            [self _positionViews];
            
            panPointsSinceLastReshuffle = fminf(panPointsSinceLastReshuffle + cellHeight, 0.0);
        }
        
        
        return YES;
    }
    
    return NO;
}


- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self];
        
        CGFloat move = translation.y;
        if ([self _reshuffleViewsBy:move criticalPortionDone:1.0]) {
            move = panPointsSinceLastReshuffle;
        }
        
        if (move != 0.0) {
            CGFloat scales[7] = TH_POSN_SCALES;
            CGFloat cellHeight = self.frame.size.height / TH_NUMVISIBLECELLS;
            int thisScaleIx = 1; //(move > 0.0 ? 1 : 2);
            int nextScaleIx = 2; //(move > 0.0 ? 2 : 1);
            int nScalesDone = 0;
            int ix = 0;
            for (UIView *v in _views) {
                v.center = CGPointMake(v.center.x, v.center.y + move);
                if (thisScaleIx == (move > 0.0 ? ix : ix - 1) && nScalesDone < 4) {
                    CGFloat scale = powf((scales[nextScaleIx] / scales[thisScaleIx]), (move / cellHeight));
                    [TallyView _scaleView:v by:scale];
                    thisScaleIx += 1;
                    nextScaleIx += 1;
                    nScalesDone += 1;
                }
                
                ix += 1;
            }
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (![self _reshuffleViewsBy:0.0 criticalPortionDone:0.6])
            [self _positionViews];
    }
}



@end




