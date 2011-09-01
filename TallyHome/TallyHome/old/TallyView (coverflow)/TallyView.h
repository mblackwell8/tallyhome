//
//  TallyView.h
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
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
 */
#import <UIKit/UIKit.h>
#import "TallyViewCell.h"
#import <QuartzCore/QuartzCore.h>


@protocol TallyViewDataSource;
@protocol TallyViewDelegate;

@interface TallyView : UIView {
	id <TallyViewDataSource> _dataSource;
	id <TallyViewDelegate> _tallyViewDelegate;
	NSMutableSet *_offscreenCells;
	NSMutableDictionary *_onscreenCells;
    
	CGFloat	_defaultImageHeight;
    
	UIScrollView *_scrollView;
	int _lowerVisibleCell;
	int _upperVisibleCell;
	int _numberOfCells;
	int _beginningDragCell;
	
	TallyViewCell *_selectedCellView;
    
	CATransform3D _upperTransform, _lowerTransform;
	
	CGFloat _halfScreenHeight;
	CGFloat _halfScreenWidth;
    
    CGFloat _cellSpacing;
	
	BOOL _isSingleTap;
	BOOL _isDoubleTap;
	BOOL _isDraggingACell;
	CGFloat _startPositionY;
}

@property (nonatomic, assign) id <TallyViewDataSource> dataSource;
@property (nonatomic, assign) id <TallyViewDelegate> tallyViewDelegate;
@property (nonatomic, assign) int numberOfCells;

- (void)reloadData;
- (void)setSelectedCell:(int)newSelectedCellIx;
- (void)centerOnSelectedCellWithAnimation:(BOOL)animated;

@end

@protocol TallyViewDelegate <NSObject>
@optional

// event methods


- (void)tallyView:(TallyView *)tallyView selectionDidChange:(int)index;
@end

@protocol TallyViewDataSource <NSObject>

- (TallyViewCell *)tallyView:(TallyView *)tallyView cellForRowAtIndex:(NSInteger)ix;

- (void)tallyView:(TallyView *)tallyView dataForCell:(TallyViewCell *)cell;

@end