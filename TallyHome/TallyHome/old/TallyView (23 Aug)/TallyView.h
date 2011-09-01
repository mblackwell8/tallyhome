//
//  TallyView.h
//  TallyHome
//
//  Created by Mark Blackwell on 21/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyViewCell.h"
#import "TallyHomeConstants.h"
#import "DebugMacros.h"

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

- (void)tallyView:(TallyView *)tallyView willShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx;

- (void)tallyView:(TallyView *)tallyView didShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx;



@end


@interface TallyView : UIView {
    id<TallyViewDelegate> _delegate;
    TallyViewCell *_selectedCell;
    
    CGFloat _panPointsSinceLastReshuffle;
    
    NSMutableArray *_cells;
    
    //NSInteger _nCells;
    
    //number of slots forward or backward
    //(up = forward = positive)
    NSInteger _scrollPosition;
    CGPoint _lastTouchPoint;
    CGFloat _lastMoveY;
    TallyViewCell *_lastTouchedCell; //this will mostly be current
    BOOL _isSingleTap, _isDoubleTap, _isDraggingACell;
    
    BOOL _shldReloadCells;
}

@property (retain, nonatomic) NSArray *cells;

//not retained
@property (assign, nonatomic) id<TallyViewDelegate> delegate;

@property NSInteger scrollPosition;

- (void)_slotViewsWithAnimation:(BOOL)animated;
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion; 
- (void)_scrollBy:(CGFloat)move withAnimation:(BOOL)animated;

- (void)reloadData;

@end
