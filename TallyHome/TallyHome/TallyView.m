//
//  TallyView.m
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyView.h"
#import "DebugMacros.h"

#define TH_POSN0_SCALE 0.55
#define TH_POSN1_SCALE TH_POSN0_SCALE
#define TH_POSN2_SCALE 0.75
#define TH_POSN3_SCALE 0.9
#define TH_POSN4_SCALE TH_POSN2_SCALE
#define TH_POSN5_SCALE TH_POSN0_SCALE
#define TH_POSN6_SCALE TH_POSN0_SCALE

#define TH_POSN_SCALES {TH_POSN0_SCALE,TH_POSN1_SCALE,TH_POSN2_SCALE,TH_POSN3_SCALE,TH_POSN4_SCALE,TH_POSN5_SCALE,TH_POSN6_SCALE}

#define TH_NUMVISIBLECELLS 5.0

#define TH_MAXSPEED_FULLYDRAWINGCELLS   350.0


@implementation TallyView

@synthesize cells = _cells, delegate = _delegate, scrollPosition = _scrollPosition;

- (void)doInit {
    UIGestureRecognizer *pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [super addGestureRecognizer:pang];
    [pang release];
    
    [super setBackgroundColor:[UIColor grayColor]];
    
    _panPointsSinceLastReshuffle = 0.0;
    _movePointsSinceLastMove = 0.0;
    _scrollPosition = 0;
    _shldReloadCells = YES;
    _shldRedrawBackground = YES;
    
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




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    DLog(@"called");
    
//    if (!_shldRedrawBackground)
//        return;
        
    UIBezierPath *bgrd = [UIBezierPath bezierPath];
    
    CGFloat ht = self.frame.size.height;
    CGFloat wd = self.frame.size.width;
    CGFloat offset = 10.0;
    CGPoint topLeft = CGPointMake(wd * (1- TH_POSN0_SCALE) / 2.0 - offset, 
                                  ht / TH_NUMVISIBLECELLS * (1 - TH_POSN0_SCALE) / 2.0 - offset);
    [bgrd moveToPoint:topLeft];
    
    CGPoint topright = CGPointMake(topLeft.x + wd * TH_POSN0_SCALE + offset * 2.0,
                                   topLeft.y);
    [bgrd addLineToPoint:topright];
    
    CGPoint midUpperRight = CGPointMake(wd - (wd * (1 - TH_POSN3_SCALE) / 2.0) + offset, 
                                        ht / TH_NUMVISIBLECELLS * 2.0);
    CGPoint midUpperRightCtrl = CGPointMake(midUpperRight.x, (topright.y + midUpperRight.y) / 2.0);
    [bgrd addQuadCurveToPoint:midUpperRight controlPoint:midUpperRightCtrl];
    
    CGPoint midLowerRight = CGPointMake(midUpperRight.x, ht / TH_NUMVISIBLECELLS * 3.0);
    [bgrd addLineToPoint:midLowerRight];
    
    CGPoint bottomRight = CGPointMake(topright.x, ht - topright.y);
    CGPoint midLowerRightCtrl = CGPointMake(midUpperRight.x, (midLowerRight.y + bottomRight.y) / 2.0);
    [bgrd addQuadCurveToPoint:bottomRight controlPoint:midLowerRightCtrl];
    
    CGPoint bottomLeft = CGPointMake(topLeft.x, bottomRight.y);
    [bgrd addLineToPoint:bottomLeft];
    
    CGPoint midLowerLeft = CGPointMake(wd * (1 - TH_POSN3_SCALE) / 2.0 - offset, midLowerRight.y);
    CGPoint midLowerLeftCtrl = CGPointMake(midLowerLeft.x, midLowerRightCtrl.y);
    [bgrd addQuadCurveToPoint:midLowerLeft controlPoint:midLowerLeftCtrl];
    
    CGPoint midUpperLeft = CGPointMake(midLowerLeft.x, midUpperRight.y);
    [bgrd addLineToPoint:midUpperLeft];
    
    CGPoint midUpperLeftCtrl = CGPointMake(midLowerLeftCtrl.x, midUpperRightCtrl.y);
    [bgrd addQuadCurveToPoint:topLeft controlPoint:midUpperLeftCtrl];

    [[UIColor whiteColor] setFill];
    [bgrd fill];
    
    _shldRedrawBackground = NO;
}

 

- (void)dealloc {
    [_cells release];
    [super dealloc];
}

- (void)_positionViews:(BOOL)animate {
    NSAssert(_cells.count == 7, @"Need seven views in the array");
    DLog(@"positioning views...");
    CGFloat height = self.frame.size.height / TH_NUMVISIBLECELLS;
    //DLog(@"curr height: %5.2f", height);
    CGFloat currY = -height;
    CGFloat scales[7] = TH_POSN_SCALES;
    int i = 0;
    if (animate)
        [UIView beginAnimations:nil context:nil];
    for (TallyViewCell *v in _cells) {
        if (animate)
            [UIView setAnimationsEnabled:(i > 0 && i < 6)];
        CGFloat h = height * scales[i];
        CGFloat w = self.frame.size.width * scales[i];
        CGFloat x = (self.frame.size.width - w) / 2.0;
        CGFloat y = currY + (height - h) / 2.0;
        
        CGFloat scaleFactor = h / v.frame.size.height;
        [_delegate tallyView:self willAdjustCellSize:v by:scaleFactor];
        v.frame = CGRectMake(x, y, w, h);
        [v scaleFontsBy:scaleFactor];
        [_delegate tallyView:self didAdjustCellSize:v by:scaleFactor];
        
        currY += height;
        i += 1;
    }
    if (animate)
        [UIView commitAnimations];
    
    _panPointsSinceLastReshuffle = 0.0;
}

- (void)_scaleView:(TallyViewCell *)view by:(CGFloat)scale {
    CGFloat oldHeight = view.frame.size.height;
    CGFloat oldWidth = view.frame.size.width;
    CGFloat h = oldHeight * scale;
    CGFloat w = oldWidth * scale;
    CGFloat x = view.frame.origin.x + (oldWidth - w) / 2.0;
    CGFloat y = view.frame.origin.y + (oldHeight - h) / 2.0;
    
    [_delegate tallyView:self willAdjustCellSize:view by:scale];
    view.frame = CGRectMake(x, y, w, h);
    [view scaleFontsBy:scale];
    [view setNeedsDisplay];
    [_delegate tallyView:self didAdjustCellSize:view by:scale];
}

- (void)layoutSubviews {
    if (_shldReloadCells) {
        NSMutableArray *cls = [[NSMutableArray alloc] initWithCapacity:TH_NUMVISIBLECELLS + 2];
        self.cells = cls;
        [cls release];
        for (NSInteger i = 0; i < TH_NUMVISIBLECELLS + 2; i++) {
            TallyViewCell *v = [_delegate tallyView:self cellForRowAtIndex:i];
            [_delegate tallyView:self dataForCell:v atIndexPosition:i];
            [self addSubview:v];
            [_cells addObject:v];
        }
        
        [self _positionViews:NO];
        _shldReloadCells = NO;
        
    }
    
    [super layoutSubviews];
}

- (void)reloadData {
    //not sure if this will be enough...
    NSInteger i = 0;
    for (TallyViewCell *v in _cells) {
        [_delegate tallyView:self dataForCell:v atIndexPosition:i];
        [v setNeedsDisplay];
        i += 1;
    } 
}


//returns YES if the views are shuffled forwards
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion animated:(BOOL)doAnim {
    _panPointsSinceLastReshuffle += move;
    //DLog(@"%5.2f", panPointsSinceLastReshuffle);
    
    if (portion < 0.0)
        return NO; 
    
    CGFloat cellHeight = self.frame.size.height / TH_NUMVISIBLECELLS;
    if (fabsf(_panPointsSinceLastReshuffle) / cellHeight > portion) {
        DLog(@"reshuffling...");
        NSAssert(_panPointsSinceLastReshuffle != 0.0, @"Error");
        if (_panPointsSinceLastReshuffle > 0.0) {
            TallyViewCell *tmp = [_cells lastObject];
            [_delegate tallyView:self willShuffleCell:tmp fromIndexPosition:6 toIndexPosition:0];
            [_cells removeLastObject];
            _scrollPosition += 1;
            [_delegate tallyView:self dataForCell:tmp atIndexPosition:0];
            [_cells insertObject:tmp atIndex:0];
            [self _positionViews:doAnim];
            [_delegate tallyView:self didShuffleCell:tmp fromIndexPosition:6 toIndexPosition:0];
            
            _panPointsSinceLastReshuffle = fmaxf(_panPointsSinceLastReshuffle - cellHeight, 0.0);
            
        }
        else if (_panPointsSinceLastReshuffle < 0.0) {
            TallyViewCell *tmp = [_cells objectAtIndex:0];
            [_delegate tallyView:self willShuffleCell:tmp fromIndexPosition:0 toIndexPosition:6];
            [_cells removeObjectAtIndex:0];
            _scrollPosition -= 1;
            [_delegate tallyView:self dataForCell:tmp atIndexPosition:6];
            [_cells addObject:tmp];
            [self _positionViews:doAnim];
            [_delegate tallyView:self didShuffleCell:tmp fromIndexPosition:0 toIndexPosition:6];
            
            _panPointsSinceLastReshuffle = fminf(_panPointsSinceLastReshuffle + cellHeight, 0.0);
            
        }
        
        
        return YES;
    }
    
    return NO;
}

#define TH_DECELERATION_START_VERTSPEED_MIN   250.0

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _shldStopDecelerating = YES;
    }    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint panSpeed = [recognizer velocityInView:self];
        DLog(@"changing pan speed is %5.2f", panSpeed.y);
        
        CGPoint translation = [recognizer translationInView:self];
        [self _scrollBy:translation.y panningFast:(fabsf(panSpeed.y) > TH_MAXSPEED_FULLYDRAWINGCELLS)];
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {        
        
        //gives effect of re-accelerating or slowing down
        _panDecelerationCurrentVerticalSpeed = [recognizer velocityInView:self].y;
        DLog(@"ending pan speed is %5.2f", _panDecelerationCurrentVerticalSpeed);
        
        if (!_isDecelerating && fabsf(_panDecelerationCurrentVerticalSpeed) > TH_DECELERATION_START_VERTSPEED_MIN) {
            _shldStopDecelerating = NO;
            _movePointsSinceLastMove = 0.0;
            _lastDecelTimestamp = 0;
            
            
            _displayLink = [[self.window.screen displayLinkWithTarget:self 
                                                             selector:@selector(_drawDecelaratingFrame:)] retain];
            DLog(@"Starting deceleration");
            [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else {
            [self _endPan];
        }


    }
}

- (void)_endPan {
    for (TallyViewCell *v in _cells) {
        if (v.isPanningFast) {
            v.isPanningFast = NO;
            [v setNeedsDisplay];
        }
    }
    
    if (![self _reshuffleViewsBy:0.0 criticalPortionDone:0.6 animated:YES])
        [self _positionViews:YES];
}

#define TH_MIN_DECELERATION_MOVE 3.0

- (void)_scrollBy:(CGFloat)moveRequested panningFast:(BOOL)isPanningFast {
    _movePointsSinceLastMove += moveRequested;
    if (_isDecelerating && fabsf(_movePointsSinceLastMove) < TH_MIN_DECELERATION_MOVE) {
        //DLog(@"caching req move %5.2f (cache %5.2f)", moveRequested, _movePointsSinceLastMove);
        return;
    }
    
    CGFloat move = floorf(_movePointsSinceLastMove);
    if ([self _reshuffleViewsBy:move criticalPortionDone:1.0 animated:NO]) {
        _movePointsSinceLastMove -= (move - _panPointsSinceLastReshuffle);
        move = _panPointsSinceLastReshuffle;
    }
    
    if (move != 0.0) {
        CGFloat scales[7] = TH_POSN_SCALES;
        CGFloat cellHeight = self.frame.size.height / TH_NUMVISIBLECELLS;
        int thisScaleIx = 1; //(move > 0.0 ? 1 : 2);
        int nextScaleIx = 2; //(move > 0.0 ? 2 : 1);
        int nScalesDone = 0;
        int ix = 0;
        for (TallyViewCell *v in _cells) {  
            v.isPanningFast = isPanningFast;
            v.center = CGPointMake(v.center.x, v.center.y + move);
            if (thisScaleIx == (move > 0.0 ? ix : ix - 1) && nScalesDone < 4) {
                CGFloat scale = powf((scales[nextScaleIx] / scales[thisScaleIx]), (move / cellHeight));
                [self _scaleView:v by:scale];
                thisScaleIx += 1;
                nextScaleIx += 1;
                nScalesDone += 1;
            }
            
            ix += 1;
        }
    }
    
    _movePointsSinceLastMove -= move;
}

#define TH_DECELERATION_DAMP            0.8
#define TH_DECELERATION_MOTION_MIN       0.1
#define TH_DECELERATION_STOP_VERTSPEED_MIN   20.0

- (void)_drawDecelaratingFrame:(CADisplayLink *)sender {
    //doco says to look at the timestamp??
    
    _isDecelerating = YES;
    //DLog(@"Sender timestamp %5.2f", sender.timestamp);
    if (_lastDecelTimestamp == 0) {
        _lastDecelTimestamp = sender.timestamp;
        return;
    }
    CFTimeInterval time = sender.timestamp - _lastDecelTimestamp;
    //DLog(@"Time since last = %5.2f", time);
    _lastDecelTimestamp = sender.timestamp;
    _panDecelerationCurrentVerticalSpeed *= TH_DECELERATION_DAMP;
    DLog(@"vert speed: %5.2f", _panDecelerationCurrentVerticalSpeed);
    double move = _panDecelerationCurrentVerticalSpeed * time;
    //DLog(@"called with move = %5.2f", move);
    if (!_shldStopDecelerating && 
        fabsf(move) > TH_DECELERATION_MOTION_MIN && 
        fabsf(_panDecelerationCurrentVerticalSpeed) > TH_DECELERATION_STOP_VERTSPEED_MIN) {
        
        [self _scrollBy:(move) panningFast:(fabsf(_panDecelerationCurrentVerticalSpeed) > TH_MAXSPEED_FULLYDRAWINGCELLS)];
    }
    else {
        DLog(@"Ending scrolling: move=%5.2f, shouldStop=%d", move, _shldStopDecelerating);
        [self _endPan];
        
        [_displayLink invalidate];
        [_displayLink release];
        _isDecelerating = NO;
    }

    
}



@end




