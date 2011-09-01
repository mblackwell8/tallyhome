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

//#define TH_MAXSPEED_FULLYDRAWINGCELLS           50.0
#define TH_DECELERATION_START_VERTSPEED_MIN     250.0
//#define TH_DECELERATION_MOVE_MIN                3.0
#define TH_DECELERATION_DAMP                    0.95
#define TH_DECELERATION_MOTION_MIN              0.1
#define TH_DECELERATION_STOP_VERTSPEED_MIN      20.0
#define TH_TALLYVIEWANIM_FRAMEINTERVAL          3

@interface TallyView ()

@property (retain, nonatomic) CADisplayLink *animationTimer;

@end

@implementation TallyView

@synthesize cells = _cells, delegate = _delegate, scrollPosition = _scrollPosition, animationTimer = _animationTimer;

- (void)doInit {
    UIGestureRecognizer *pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
    [super addGestureRecognizer:pang];
    [pang release];
    
    [super setBackgroundColor:[UIColor grayColor]];
    
    _panPointsSinceLastReshuffle = 0.0;
    _scrollPosition = 0;
    _shldReloadCells = YES;
    _shldRedrawBackground = YES;
    _prePanTouchDownPt = CGPointZero;
    
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

- (void)_slotViewsWithAnimation:(BOOL)animate {
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
        [v scaleFontsBy:scaleFactor];
        v.frame = CGRectMake(x, y, w, h);
        [v setNeedsDisplay];
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
        
        [self _slotViewsWithAnimation:NO];
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
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion {
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
            [_delegate tallyView:self didShuffleCell:tmp fromIndexPosition:0 toIndexPosition:6];
            
            _panPointsSinceLastReshuffle = fminf(_panPointsSinceLastReshuffle + cellHeight, 0.0);
            
        }
        
        
        return YES;
    }
    
    return NO;
}


- (void)_pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint panSpeed = [recognizer velocityInView:self];
    DLog(@"pan speed is %5.2f", panSpeed.y);
    
//    if (_isDecelerating && recognizer.state != UIGestureRecognizerStateEnded) {
//        // if the pan is in the same direction as current then ignore the pan until it ends
//        // where we will use the pan speed to reaccelerate (or slow down)
//        if ((panSpeed.y > 0 && _panDecelerationCurrentVerticalSpeed > 0) ||
//            (panSpeed.y < 0 && _panDecelerationCurrentVerticalSpeed < 0)) {
//            DLog(@"Ignoring pan for now");
//            return;
//        }
//        
//        _shldStopDecelerating = YES;
//    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint panStart = [recognizer locationInView:self];
        _prePanOffset = panStart.y - _prePanTouchDownPt.y;
        DLog(@"Pan gesture began at y=%5.2f. Prepan begain at y=%5.2f", 
             panStart.y, _prePanTouchDownPt.y);
        _prePanTouchDownPt = CGPointZero;
        [self _setCellsPanningFastTo:YES];
    }    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        DLog(@"Pan gesture changed");
        CGPoint translation = [recognizer translationInView:self];
        [self _scrollBy:translation.y + _prePanOffset];
        
        [recognizer setTranslation:CGPointZero inView:self];
        _prePanOffset = 0.0;
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {        
        DLog(@"Pan gesture ended");
        
        //gives effect of re-accelerating or slowing down
        _panDecelerationCurrentVerticalSpeed = [recognizer velocityInView:self].y;
        DLog(@"ending pan speed is %5.2f", _panDecelerationCurrentVerticalSpeed);
        
        if (!_isDecelerating && 
            fabsf(_panDecelerationCurrentVerticalSpeed) > TH_DECELERATION_START_VERTSPEED_MIN) {
            [self _startScrollingAnimation];
        }
        else {
            [self _reshuffleViewsBy:0.0 criticalPortionDone:0.6];
            [self _slotViewsWithAnimation:YES];
            [self _setCellsPanningFastTo:NO];
        }


    }
}

- (void)_startScrollingAnimation {
    DLog(@"Starting animation");
    _isDecelerating = YES;
    _shldStopDecelerating = NO;
    _lastDecelTimestamp = 0.0;

    CADisplayLink *animTimer = [self.window.screen displayLinkWithTarget:self 
                                                                selector:@selector(_updateScrollingAnimation:)];
    
    animTimer.frameInterval = TH_TALLYVIEWANIM_FRAMEINTERVAL;
    [animTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _lastDecelTimestamp = CFAbsoluteTimeGetCurrent();
    self.animationTimer = animTimer;
}

- (void)_stopScrollingAnimation {
    DLog(@"Ending scrolling");
    _isDecelerating = NO;
    
    [_animationTimer invalidate];
    self.animationTimer = nil;
    
    [self _reshuffleViewsBy:0.0 criticalPortionDone:0.6];
    [self _slotViewsWithAnimation:YES];
    [self _setCellsPanningFastTo:NO];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isDecelerating) {
        _shldStopDecelerating = YES;
    }
    else {
        _prePanTouchDownPt = [[touches anyObject] locationInView:self];
    }
}



- (void)_scrollBy:(CGFloat)move {
    if ([self _reshuffleViewsBy:move criticalPortionDone:1.0]) {
        [self _slotViewsWithAnimation:NO];
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
            NSAssert(v.isPanningFast, @"Cell should have been set to panning fast"); 
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
}

- (void)_updateScrollingAnimation:(CADisplayLink *)sender {
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    NSAssert(_lastDecelTimestamp, @"lastDecelTimestamp not set!");
    CFTimeInterval time = currentTime - _lastDecelTimestamp;
    DLog(@"Time since last = %5.5f, FPS = %5.2f", time, 1.0 / time);
    _lastDecelTimestamp = sender.timestamp;
    _panDecelerationCurrentVerticalSpeed *= pow(TH_DECELERATION_DAMP, time / sender.duration);
    DLog(@"vert speed: %5.2f", _panDecelerationCurrentVerticalSpeed);
    double move = _panDecelerationCurrentVerticalSpeed * time;
    //DLog(@"called with move = %5.2f", move);
    if (!_shldStopDecelerating && 
        fabsf(move) > TH_DECELERATION_MOTION_MIN && 
        fabsf(_panDecelerationCurrentVerticalSpeed) > TH_DECELERATION_STOP_VERTSPEED_MIN) {
        
        [self _scrollBy:move];
    }
    else {
        DLog(@"Ending scrolling: move=%5.2f, shouldStop=%d", move, _shldStopDecelerating);
        [self _stopScrollingAnimation];
    }

    _lastDecelTimestamp = currentTime;
    
}
- (void)_setCellsPanningFastTo:(BOOL)shldPanFast {
    for (TallyViewCell *v in _cells) {
        if (v.isPanningFast != shldPanFast) {
            v.isPanningFast = shldPanFast;
            [v setNeedsDisplay];
        }
    }
}



@end




