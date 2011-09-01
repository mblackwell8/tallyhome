//
//  TallyView.h
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyViewCell.h"
#import "FlickDynamics.h"
#import <QuartzCore/CADisplayLink.h>

@class TallyView;

@protocol TallyViewDelegate<NSObject>

// data methods

@required

//- (NSInteger)numberOfVisibleRows;

@optional
// initialise the cells (numberOfVisibleRows + 2)
- (TallyViewCell *)tallyView:(TallyView *)tallyView cellForRowAtIndex:(NSInteger)ix;

// 
- (void)tallyView:(TallyView *)tallyView dataForCell:(TallyViewCell *)cell atIndexPosition:(NSInteger)ix;



// event methods

- (void)tallyView:(TallyView *)tallyView willAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor;

- (void)tallyView:(TallyView *)tallyView didAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor;

- (void)tallyView:(TallyView *)tallyView willShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx;

- (void)tallyView:(TallyView *)tallyView didShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx;



@end


@interface TallyView : UIView {
    id<TallyViewDelegate> _delegate;
            
    CGFloat _panPointsSinceLastReshuffle;
    CGFloat _movePointsSinceLastMove;
    
    NSMutableArray *_cells;
    
    //NSInteger _nCells;
    
    //number of slots forward or backward
    //(up = forward = positive)
    NSInteger _scrollPosition;
    
    BOOL _shldReloadCells;
    BOOL _shldRedrawBackground;
    
    CGFloat _panDecelerationCurrentVerticalSpeed;
    CADisplayLink *_animationTimer;
    CGPoint _touchDown, _lastTouchDown, _currentTouchDown;
    BOOL _isTouchedDown;
    CGFloat _currentSpeedY;
    CGFloat _decelerationRate;
        
}

@property (retain, nonatomic) NSArray *cells;

//not retained
@property (assign, nonatomic) id<TallyViewDelegate> delegate;

@property NSInteger scrollPosition;


- (void)reloadData;

- (void)_scaleView:(TallyViewCell *)view by:(CGFloat)scale;
- (void)_slotViewsWithAnimation:(BOOL)animated;
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion; 

- (void)_scrollBy:(CGFloat)move;
- (void)_startScrollingAnimation;
- (void)_updateScrollingAnimation:(CADisplayLink *)sender;
- (void)_stopScrollingAnimation;

@end