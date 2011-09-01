//
//  TallyView.m
//  TallyHome
//
//  Created by Mark Blackwell on 21/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TallyView.h"


@implementation TallyView

@synthesize cells = _cells, delegate = _delegate, scrollPosition = _scrollPosition;

- (void)doInit {
    [super setBackgroundColor:TH_TALLYVIEW_BACK_COLOR];
    
    _panPointsSinceLastReshuffle = 0.0;
    _scrollPosition = 0;
    _shldReloadCells = YES;
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

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)layoutSubviews {
    if (_shldReloadCells) {
        NSMutableArray *cls = [[NSMutableArray alloc] initWithCapacity:TH_NUMVISIBLECELLS + 4];
        self.cells = cls;
        [cls release];
        
        CGFloat summaryCellHt = self.frame.size.height / (TH_NUMVISIBLECELLS + TH_CENTRECELL_HEIGHT_MULTIPLIER - 1);
        CGFloat currY = -summaryCellHt * 2.0;
        for (NSInteger i = 0; i < TH_NUMVISIBLECELLS + 4; i++) {
            TallyViewCell *v = [_delegate tallyView:self cellForRowAtIndex:i];
            
            CGFloat w = self.frame.size.width * TH_CELL_DISPLAY_PROPORTION;
            
            CGFloat thisCellHeight = summaryCellHt * (i == TH_CENTRECELL_IX ? TH_CENTRECELL_HEIGHT_MULTIPLIER : 1.0);
            
            CGFloat h = thisCellHeight * TH_CELL_DISPLAY_PROPORTION;
            CGFloat x = (self.frame.size.width - w) / 2.0;
            CGFloat y = currY + (thisCellHeight - h) / 2.0;
            
            v.frame = CGRectMake(x, y, w, h);
                    
            currY += thisCellHeight;

            
            [_delegate tallyView:self dataForCell:v atIndexPosition:i];
            [self addSubview:v];
            [_cells addObject:v];
        }
        
//        _selectedCell = [_cells objectAtIndex:4];
//        _selectedCell.isSummaryDisplayOnly = NO;
        
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouchPoint = [[touches anyObject] locationInView:self];
    
    _isDraggingACell = NO;
	
	// Which cell did the user tap?
    UIView *cell = [self hitTest:_lastTouchPoint withEvent:nil];
    if (![cell isEqual:self]) {
        _isDraggingACell = YES;
        _lastTouchedCell = (TallyViewCell *)cell;
    }
    
    //if we already have a tap before a move, then it's a doubletap
    if (_isSingleTap)
        _isDoubleTap = YES;
    
    _isSingleTap = ([touches count] == 1);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSingleTap = NO;
    _isDoubleTap = NO;
        
    CGPoint movedPoint = [[touches anyObject] locationInView:self];
    // Only scroll if the user started on a cover.
	if (_isDraggingACell)
        [self _scrollBy:movedPoint.y - _lastTouchPoint.y withAnimation:NO];
    _lastTouchPoint = movedPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap && _lastTouchedCell) {
        //make this cell the active cell
        CGFloat scrollY = self.center.y - self.frame.origin.y - _lastTouchedCell.center.y;
        [self _scrollBy:scrollY withAnimation:YES];
    }
    
    if (_isDraggingACell) {
        [self _reshuffleViewsBy:0.0 criticalPortionDone:0.6];
        [self _slotViewsWithAnimation:YES];
    }
}



- (void)_slotViewsWithAnimation:(BOOL)animate {
    NSAssert(_cells.count == 9, @"Need nine views in the array");
    DLog(@"positioning views...");

    CGFloat summaryCellHt = self.frame.size.height / (TH_NUMVISIBLECELLS + TH_CENTRECELL_HEIGHT_MULTIPLIER - 1);
    //DLog(@"curr height: %5.2f", height);
    CGFloat currY = -summaryCellHt * 1.5;
    
    if (animate) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:5.0];
    }
    
    TallyViewCell *newSelectedCell = [_cells objectAtIndex:TH_CENTRECELL_IX];
    if (_selectedCell && _selectedCell != newSelectedCell) {
        
        //resize the old selected cell
        CGRect oldFrame = _selectedCell.frame;
        CGFloat newY = oldFrame.origin.y + summaryCellHt *  (1 - TH_CENTRECELL_HEIGHT_MULTIPLIER) * (1 - TH_CELL_DISPLAY_PROPORTION) / 2.0;
        _selectedCell.frame = CGRectMake(oldFrame.origin.x, 
                                           newY, 
                                           oldFrame.size.width, 
                                           summaryCellHt);
        _selectedCell.isSummaryDisplayOnly = YES;
    }
    
    int i = 0;
    for (TallyViewCell *v in _cells) {
        if (animate)
            [UIView setAnimationsEnabled:(i >= 2 && i <= 6)];
        v.center = CGPointMake(v.center.x, currY);
        DLog(@"slotting tallyviewcell to rect: %@", NSStringFromCGRect(v.frame));
        [v setNeedsDisplay];

        CGFloat nextCellHeight = summaryCellHt * (i + 1 == TH_CENTRECELL_IX ? TH_CENTRECELL_HEIGHT_MULTIPLIER : 1.0);
        currY += nextCellHeight;
        i += 1;
    }
    
    _selectedCell = newSelectedCell;
    _selectedCell.isSummaryDisplayOnly = NO;
    
    //now resize the centre cell
    CGFloat w = self.frame.size.width * TH_CELL_DISPLAY_PROPORTION;
    CGFloat cellHeight = summaryCellHt  * TH_CENTRECELL_HEIGHT_MULTIPLIER;
    CGFloat h = cellHeight  * TH_CELL_DISPLAY_PROPORTION;
    CGFloat x = (self.frame.size.width - w) / 2.0;
    //y location is 2 cells down
    CGFloat y = summaryCellHt * 2.0 + (cellHeight - h) / 2.0;
    _selectedCell.frame = CGRectMake(x, y, w, h);

    
    if (animate) {
        [UIView commitAnimations]; 
    }
    
    //once views are slotted, reset the pan points
    _panPointsSinceLastReshuffle = 0.0;
}

//returns YES if the views are shuffled forwards
- (BOOL)_reshuffleViewsBy:(CGFloat)move criticalPortionDone:(CGFloat)portion {
    _panPointsSinceLastReshuffle += move;
    //DLog(@"%5.2f", panPointsSinceLastReshuffle);
    
    if (portion < 0.0)
        return NO; 
    
    CGFloat cellHeight = self.frame.size.height / TH_NUMVISIBLECELLS;
    if (_isDraggingACell)
        cellHeight = _lastTouchedCell.frame.size.height;
    BOOL didReshuffle = NO;
    while (fabsf(_panPointsSinceLastReshuffle) / cellHeight > portion) {
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
        
        didReshuffle = YES;
        
    }
    
    return didReshuffle;
}

- (void)_scrollBy:(CGFloat)move withAnimation:(BOOL)animated {
    _lastMoveY = move;
    if ([self _reshuffleViewsBy:move criticalPortionDone:1.0]) {
        [self _slotViewsWithAnimation:animated];
        move = _panPointsSinceLastReshuffle;
    }
    
    if (move != 0.0) {
        for (TallyViewCell *v in _cells) { 
            v.center = CGPointMake(v.center.x, v.center.y + move);
        }
    }
}



@end