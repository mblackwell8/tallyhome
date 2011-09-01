//
//  TallyView.m
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyView.h"
#import "DebugMacros.h"

#define TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER  2.0
#define TH_TALLYVIEW_CELLSCALE   0.9

#define TH_NUMVISIBLECELLS 5.0

//#define TH_MAXSPEED_FULLYDRAWINGCELLS           50.0
#define TH_DECELERATION_START_VERTSPEED_MIN     250.0
//#define TH_DECELERATION_MOVE_MIN                3.0
#define TH_DECELERATION_DAMP                    0.95
#define TH_DECELERATION_MOTION_MIN              0.1
#define TH_DECELERATION_STOP_VERTSPEED_MIN      20.0
#define TH_TALLYVIEWANIM_FRAMEINTERVAL          1

@interface TallyView ()

@property (retain, nonatomic) CADisplayLink *animationTimer;

@end

@implementation TallyView

@synthesize cells = _cells, delegate = _delegate, scrollPosition = _scrollPosition, animationTimer = _animationTimer;

- (void)doInit {
    UIGestureRecognizer *pang = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
    [super addGestureRecognizer:pang];
    [pang release];
    
    [super setBackgroundColor:[UIColor whiteColor]];
    
    _panPointsSinceLastReshuffle = 0.0;
    _scrollPosition = 0;
    _shldReloadCells = YES;
    _shldRedrawBackground = YES;
    _prePanTouchDownPt = CGPointZero;
    _currentTouchPt = CGPointZero;
    _detailViewCellPosition = 3;
    
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
 

- (void)dealloc {
    [_cells release];
    [super dealloc];
}

- (void)_slotViewsWithAnimation:(BOOL)animate {
    NSAssert(_cells.count == 7, @"Need seven views in the array");
    DLog(@"positioning views...");
    CGFloat summaryCellHt = self.frame.size.height / (TH_NUMVISIBLECELLS + TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER - 1);
    //DLog(@"curr height: %5.2f", height);
    
    CGFloat currY = -summaryCellHt;
    int i = 0;
    for (TallyViewCell *v in _cells) {
        CGFloat thisCellHeight = summaryCellHt * (i == _detailViewCellPosition ? TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER : 1.0);
        CGFloat h = thisCellHeight * TH_TALLYVIEW_CELLSCALE;
        CGFloat w = self.frame.size.width * TH_TALLYVIEW_CELLSCALE;
        CGFloat x = (self.frame.size.width - v.frame.size.width) / 2.0;
        CGFloat y = currY + (thisCellHeight - v.frame.size.height) / 2.0;
        
        v.frame = CGRectMake(x, y, w, h);
        
        //HACK... trying to get something to work
        [v setNeedsDisplay];
        
        currY += thisCellHeight;
        i += 1;
    }
    
    // flip the detail view
    //[self _flipDetailViewWithAnimation:animate];
    
    _panPointsSinceLastReshuffle = 0.0;
}

- (void)_flipDetailViewWithAnimation:(BOOL)animated {
    TallyViewCell *detView = [_cells objectAtIndex:_detailViewCellPosition];
    
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.125;
        anim.repeatCount = 1;
        anim.autoreverses = NO;
        anim.removedOnCompletion = NO;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
        [detView.layer addAnimation:anim forKey:nil];
    }
    else { 
        detView.layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0);
    }
    
    
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
            
            //HACK... just trying to make somehting work
            [v setNeedsDisplay];
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
    
    CGFloat summaryCellHt = self.frame.size.height / (TH_NUMVISIBLECELLS + TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER - 1);
    CGFloat cellHeight = summaryCellHt;
    if (_currentTouchPt.y > summaryCellHt * _detailViewCellPosition &&
        _currentTouchPt.y <= summaryCellHt * _detailViewCellPosition + summaryCellHt * TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER) {
        cellHeight = summaryCellHt * TH_TALLYVIEW_DETAIL_HEIGHT_MULTIPLIER;
    }
    
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
        _currentTouchPt = panStart;
        _prePanOffset = panStart.y - _prePanTouchDownPt.y;
        DLog(@"Pan gesture began at y=%5.2f. Prepan begain at y=%5.2f", 
             panStart.y, _prePanTouchDownPt.y);
        _prePanTouchDownPt = CGPointZero;
    }    
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        DLog(@"Pan gesture changed");
        _currentTouchPt = [recognizer locationInView:self];
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
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isDecelerating) {
        _shldStopDecelerating = YES;
    }
    else {
        _prePanTouchDownPt = [[touches anyObject] locationInView:self];
        _currentTouchPt = _prePanTouchDownPt;
    }
}



- (void)_scrollBy:(CGFloat)move {
    if ([self _reshuffleViewsBy:move criticalPortionDone:1.0]) {
        [self _slotViewsWithAnimation:NO];
        move = _panPointsSinceLastReshuffle;
    }
    
    if (move != 0.0) {
        for (TallyViewCell *v in _cells) { 
            //HACK: does this work with transformed cells?
            v.center = CGPointMake(v.center.x, v.center.y + move);
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



@end




