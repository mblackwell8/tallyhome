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

#import "TallyView.h"
#import "TallyHomeConstants.h"
#import "DebugMacros.h"


@interface TallyView (hidden)

- (void)setUpInitialState;
- (TallyViewCell *)cellForIndex:(int)cellIndex;
- (void)updateCell:(TallyViewCell *)aCell;
- (TallyViewCell *)dequeueReusableCell;
- (void)layoutCells:(int)selected fromCell:(int)lowerBound toCell:(int)upperBound;
- (void)layoutCell:(TallyViewCell *)aCell selectedCell:(int)selectedIndex animated:(BOOL)animated;
- (TallyViewCell *)findCellOnscreen:(CALayer *)targetLayer;

@end

@implementation TallyView (hidden)

- (void)setUpInitialState {
    // Set up the default image for the cellflow.
    //self.defaultImage = [self.dataSource defaultImage];
    
    // Create data holders for onscreen & offscreen cells & UIImage objects.
    _offscreenCells = [[NSMutableSet alloc] init];
    _onscreenCells = [[NSMutableDictionary alloc] init];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scrollView.userInteractionEnabled = NO;
    _scrollView.multipleTouchEnabled = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
    
    self.multipleTouchEnabled = NO;
    self.userInteractionEnabled = YES;
    self.autoresizesSubviews = YES;
    self.layer.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    // Initialize the visible and selected cell range.
    _lowerVisibleCell = _upperVisibleCell = -1;
    _selectedCellView = nil;
    
    // Set up the cell's left & right transforms.
    _upperTransform = CATransform3DIdentity;
    _upperTransform = CATransform3DRotate(_upperTransform, TH_OFFSET_CELL_ANGLE, -1.0f, 0.0f, 0.0f);
    _lowerTransform = CATransform3DIdentity;
    _lowerTransform = CATransform3DRotate(_lowerTransform, TH_OFFSET_CELL_ANGLE, 1.0f, 0.0f, 0.0f);
    
    // Set some perspective
    // Applying the 3D perspective relies on a poorly-documented feature of Core Animationís CATransform3D structure, 
    // a 4-by-4 matrix used to perform matrix transformations. Apple's documentation says that changes to CATransform3D.m34 
    // affect the sharpness of the transform. For our purposes, this means ìmake things look 3Dî.
    
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = -0.01;
    [_scrollView.layer setSublayerTransform:sublayerTransform];
    
    [self setBounds:self.frame];
}

- (TallyViewCell *)cellForIndex:(int)cellIndex {
    TallyViewCell *cell = [self dequeueReusableCell];
    if (!cell)
        cell = [_dataSource tallyView:self cellForRowAtIndex:cellIndex];
    
    cell.number = cellIndex;
    
    return cell;
}

- (void)updateCell:(TallyViewCell *)aCell {
    [_dataSource tallyView:self dataForCell:aCell];
}

- (TallyViewCell *)dequeueReusableCell {
    TallyViewCell *aCell = [_offscreenCells anyObject];
    if (aCell) {
        [[aCell retain] autorelease];
        [_offscreenCells removeObject:aCell];
    }
    return aCell;
}

- (void)layoutCell:(TallyViewCell *)aCell selectedCell:(int)selectedIndex animated:(BOOL)animated  {
    int cellNumber = aCell.number;
    CATransform3D newTransform;
    CGFloat newZPosition = TH_OFFSET_CELL_ZPOSITION;
    CGPoint newPosition;
    
//    newFrame.size.width = self.frame.size.width * TH_CELL_DISPLAY_PROPORTION;
//    newFrame.size.height = _cellSpacing * TH_CELL_DISPLAY_PROPORTION;
//    newFrame.origin.x = (self.frame.size.width - newFrame.size.width) / 2.0;
//    newFrame.origin.y = aCell.number * _cellSpacing + (self.frame.size.height - newFrame.size.height) / 2.0;
    newPosition.x = _halfScreenWidth;
    newPosition.y = _halfScreenHeight + aCell.number * _cellSpacing;
    DLog(@"Laying out cellnum %d, selected is %d", aCell.number, selectedIndex);
    if (cellNumber < selectedIndex) {
        DLog(@"Cell above center");
        newTransform = _upperTransform;
    } else if (cellNumber > selectedIndex) {
        DLog(@"Cell below center");
        newTransform = _lowerTransform;
    } else {
        DLog(@"Cell at center");
        newZPosition = 0;
        newTransform = CATransform3DIdentity;
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    aCell.layer.transform = newTransform;
    aCell.layer.zPosition = newZPosition;
    aCell.layer.position = newPosition;
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)layoutCells:(int)selected fromCell:(int)lowerBound toCell:(int)upperBound {
    
    //HACK: frame or bounds???
    CGFloat ht = self.frame.size.height;
    _cellSpacing = ht / (TH_COVER_BUFFER * 2.0 + 1.0);
    
    _halfScreenWidth = self.bounds.size.width / 2;
    _halfScreenHeight = ht / 2;

    TallyViewCell *cell;
    NSNumber *cellNumber;
    DLog(@"Laying out cells %d to %d", lowerBound, upperBound);
    for (int i = lowerBound; i <= upperBound; i++) {
        cellNumber = [NSNumber numberWithInt:i];
        cell = [_onscreenCells objectForKey:cellNumber];
        [self layoutCell:cell selectedCell:selected animated:YES];
    }
}

- (TallyViewCell *)findCellOnscreen:(CALayer *)targetLayer {
    // See if this layer is one of our cells.
    NSEnumerator *cellEnumerator = [_onscreenCells objectEnumerator];
    TallyViewCell *aCell = nil;
    while ((aCell = (TallyViewCell *)[cellEnumerator nextObject]))
        if ([aCell.layer isEqual:targetLayer])
            break;
    
    return aCell;
}
@end


@implementation TallyView
@synthesize dataSource = _dataSource, tallyViewDelegate = _tallyViewDelegate, numberOfCells = _numberOfCells;



- (void)awakeFromNib {
    [self setUpInitialState];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setUpInitialState];
    }
    
    return self;
}

- (void)dealloc {
    [_scrollView release];
    
    [_offscreenCells removeAllObjects];
    [_offscreenCells release];
    
    [_onscreenCells removeAllObjects];
    [_onscreenCells release];
    
    [super dealloc];
}

- (void)setBounds:(CGRect)newSize {
    [super setBounds:newSize];
    
    
    int lowerBound = MAX(0, _selectedCellView.number - TH_COVER_BUFFER);
    int upperBound = MIN(self.numberOfCells - 1, _selectedCellView.number + TH_COVER_BUFFER);
    
    [self layoutCells:_selectedCellView.number fromCell:lowerBound toCell:upperBound];
    [self centerOnSelectedCellWithAnimation:NO];
}

//sets the total number of cells, not the visible number
- (void)setNumberOfCells:(int)newNumberOfCells {
    _numberOfCells = newNumberOfCells;
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width, newNumberOfCells * _cellSpacing + self.bounds.size.height);
    
    int lowerBound = MAX(0, _selectedCellView.number - TH_COVER_BUFFER);
    int upperBound = MIN(self.numberOfCells - 1, _selectedCellView.number + TH_COVER_BUFFER);
    
    if (_selectedCellView)
        [self layoutCells:_selectedCellView.number fromCell:lowerBound toCell:upperBound];
    else
        [self setSelectedCell:0];
    
    [self centerOnSelectedCellWithAnimation:NO];
}

- (void)reloadData {
    //not sure if this will be enough...
//    for (TallyViewCell *v in [_onscreenCells allValues]) {
//        [_dataSource tallyView:self dataForCell:v];
//        [self layoutCell:v selectedCell:_selectedCellView.number animated:NO];
//    } 
    
    int lowerBound = MAX(0, _selectedCellView.number - TH_COVER_BUFFER);
    int upperBound = MIN(self.numberOfCells - 1, _selectedCellView.number + TH_COVER_BUFFER);
    [self layoutCells:_selectedCellView.number fromCell:lowerBound toCell:upperBound];
    [self setSelectedCell:(int)(_numberOfCells / 2)];
    [self centerOnSelectedCellWithAnimation:NO];
}

//- (void)setDefaultImage:(UIImage *)newDefaultImage {
//    [defaultImage release];
//    defaultImageHeight = newDefaultImage.size.height;
//    defaultImage = [[newDefaultImage addImageReflection:kReflectionFraction] retain];
//}
//
//- (void)setImage:(UIImage *)image forIndex:(int)index {
//    // Create a reflection for this image.
//    UIImage *imageWithReflection = [image addImageReflection:kReflectionFraction];
//    NSNumber *cellNumber = [NSNumber numberWithInt:index];
//    [cellImages setObject:imageWithReflection forKey:cellNumber];
//    [cellImageHeights setObject:[NSNumber numberWithFloat:image.size.height] forKey:cellNumber];
//    
//    // If this cell is onscreen, set its image and call layoutCell.
//    TallyViewCell *aCell = (TallyViewCell *)[onscreenCells objectForKey:[NSNumber numberWithInt:index]];
//    if (aCell) {
//        [aCell setImage:imageWithReflection originalImageHeight:image.size.height reflectionFraction:kReflectionFraction];
//        [self layoutCell:aCell selectedCell:selectedCellView.number animated:NO];
//    }
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint startPoint = [[touches anyObject] locationInView:self];
    _isDraggingACell = NO;
    
    // Which cell did the user tap?
    CALayer *targetLayer = (CALayer *)[_scrollView.layer hitTest:startPoint];
    TallyViewCell *targetCell = [self findCellOnscreen:targetLayer];
    _isDraggingACell = (targetCell != nil);
    
    _beginningDragCell = _selectedCellView.number;
    
    // Make sure the user is tapping on a cell.
    //HACK: NOT SURE WHY DIVIDING BY 1.5??
    _startPositionY = (startPoint.y / 1.5) + _scrollView.contentOffset.y;
    
    //if we already have a tap before a move, then it's a doubletap
    if (_isSingleTap)
        _isDoubleTap = YES;
    
    _isSingleTap = ([touches count] == 1);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _isSingleTap = NO;
    _isDoubleTap = NO;
    
    // Only scroll if the user started on a cell.
    if (!_isDraggingACell)
        return;
    
    CGPoint movedPoint = [[touches anyObject] locationInView:self];
    
    //HACK: NOT SURE WHY DIVIDING BY 1.5??
    CGFloat offset = _startPositionY - (movedPoint.y / 1.5);
    CGPoint newPoint = CGPointMake(0, offset);
    _scrollView.contentOffset = newPoint;
    int newCell = offset / _cellSpacing;
    if (newCell != _selectedCellView.number) {
        if (newCell < 0)
            [self setSelectedCell:0];
        else if (newCell >= self.numberOfCells)
            [self setSelectedCell:self.numberOfCells - 1];
        else
            [self setSelectedCell:newCell];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isSingleTap) {
        // Which cell did the user tap?
        CGPoint targetPoint = [[touches anyObject] locationInView:self];
        CALayer *targetLayer = (CALayer *)[_scrollView.layer hitTest:targetPoint];
        TallyViewCell *targetCell = [self findCellOnscreen:targetLayer];
        if (targetCell && (targetCell.number != _selectedCellView.number))
            [self setSelectedCell:targetCell.number];
    }
    [self centerOnSelectedCellWithAnimation:YES];
    
    // And send the delegate the newly selected cell message.
    if (_beginningDragCell != _selectedCellView.number &&
        [self.tallyViewDelegate respondsToSelector:@selector(tallyView:selectionDidChange:)])
        [self.tallyViewDelegate tallyView:self selectionDidChange:_selectedCellView.number];
}

- (void)centerOnSelectedCellWithAnimation:(BOOL)animated {
    CGPoint selectedOffset = CGPointMake(0, _cellSpacing * (_selectedCellView.number + 1));
    [_scrollView setContentOffset:selectedOffset animated:animated];
    //[_scrollView setContentOffset:_selectedCellView.center];
}

- (void)setSelectedCell:(int)newSelectedCell {
    if (_selectedCellView && (newSelectedCell == _selectedCellView.number))
        return;
    
    DLog(@"... newSelectedCell = %d", newSelectedCell);
    TallyViewCell *cell;
    int newLowerBound = MAX(0, newSelectedCell - TH_COVER_BUFFER);
    int newUpperBound = MIN(self.numberOfCells - 1, newSelectedCell + TH_COVER_BUFFER);
    if (!_selectedCellView) {
        // Allocate and display cells from newLower to newUpper bounds.
        for (int i = newLowerBound; i <= newUpperBound; i++) {
            cell = [self cellForIndex:i];
            [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:i]];
            [self updateCell:cell];
            [_scrollView.layer addSublayer:cell.layer];
            //[scrollView addSubview:cell];
            [self layoutCell:cell selectedCell:newSelectedCell animated:NO];
        }
        
        _lowerVisibleCell = newLowerBound;
        _upperVisibleCell = newUpperBound;
        _selectedCellView = [_onscreenCells objectForKey:[NSNumber numberWithInt:newSelectedCell]];
        
        return;
    }
    
    // Check to see if the new & current ranges overlap.
    if ((newLowerBound > _upperVisibleCell) || (newUpperBound < _lowerVisibleCell)) {
        // They do not overlap at all.
        // This does not animate--assuming it's programmatically set from view controller.
        // Recycle all onscreen cells.
        TallyViewCell *cell;
        for (int i = _lowerVisibleCell; i <= _upperVisibleCell; i++) {
            cell = [_onscreenCells objectForKey:[NSNumber numberWithInt:i]];
            [_offscreenCells addObject:cell];
            [cell removeFromSuperview];
            [_onscreenCells removeObjectForKey:[NSNumber numberWithInt:cell.number]];
        }
        
        // Move all available cells to new location.
        for (int i = newLowerBound; i <= newUpperBound; i++) {
            cell = [self cellForIndex:i];
            [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:i]];
            [self updateCell:cell];
            [_scrollView.layer addSublayer:cell.layer];
        }
        
        _lowerVisibleCell = newLowerBound;
        _upperVisibleCell = newUpperBound;
        _selectedCellView = [_onscreenCells objectForKey:[NSNumber numberWithInt:newSelectedCell]];
        [self layoutCells:newSelectedCell fromCell:newLowerBound toCell:newUpperBound];
        
        return;
    } else if (newSelectedCell > _selectedCellView.number) {
        // Move cells that are now out of range on the left to the right side,
        // but only if appropriate (within the range set by newUpperBound).
        for (int i = _lowerVisibleCell; i < newLowerBound; i++) {
            cell = [_onscreenCells objectForKey:[NSNumber numberWithInt:i]];
            if (_upperVisibleCell < newUpperBound) {
                // Tack it on the right side.
                _upperVisibleCell += 1;
                cell.number = _upperVisibleCell;
                [self updateCell:cell];
                [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:cell.number]];
                [self layoutCell:cell selectedCell:newSelectedCell animated:NO];
            } else {
                // Recycle this cell.
                [_offscreenCells addObject:cell];
                [cell removeFromSuperview];
            }
            [_onscreenCells removeObjectForKey:[NSNumber numberWithInt:i]];
        }
        _lowerVisibleCell = newLowerBound;
        
        // Add in any missing cells on the right up to the newUpperBound.
        for (int i = _upperVisibleCell + 1; i <= newUpperBound; i++) {
            cell = [self cellForIndex:i];
            [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:i]];
            [self updateCell:cell];
            [_scrollView.layer addSublayer:cell.layer];
            [self layoutCell:cell selectedCell:newSelectedCell animated:NO];
        }
        _upperVisibleCell = newUpperBound;
    } else {
        // Move cells that are now out of range on the right to the left side,
        // but only if appropriate (within the range set by newLowerBound).
        for (int i = _upperVisibleCell; i > newUpperBound; i--) {
            cell = [_onscreenCells objectForKey:[NSNumber numberWithInt:i]];
            if (_lowerVisibleCell > newLowerBound) {
                // Tack it on the left side.
                _lowerVisibleCell --;
                cell.number = _lowerVisibleCell;
                [self updateCell:cell];
                [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:_lowerVisibleCell]];
                [self layoutCell:cell selectedCell:newSelectedCell animated:NO];
            } else {
                // Recycle this cell.
                [_offscreenCells addObject:cell];
                [cell removeFromSuperview];
            }
            [_onscreenCells removeObjectForKey:[NSNumber numberWithInt:i]];
        }
        _upperVisibleCell = newUpperBound;
        
        // Add in any missing cells on the left down to the newLowerBound.
        for (int i = _lowerVisibleCell - 1; i >= newLowerBound; i--) {
            cell = [self cellForIndex:i];
            [_onscreenCells setObject:cell forKey:[NSNumber numberWithInt:i]];
            [self updateCell:cell];
            [_scrollView.layer addSublayer:cell.layer];
            //[scrollView addSubview:cell];
            [self layoutCell:cell selectedCell:newSelectedCell animated:NO];
        }
        _lowerVisibleCell = newLowerBound;
    }
    
    if (_selectedCellView.number > newSelectedCell)
        [self layoutCells:newSelectedCell fromCell:newSelectedCell toCell:_selectedCellView.number];
    else if (newSelectedCell > _selectedCellView.number)
        [self layoutCells:newSelectedCell fromCell:_selectedCellView.number toCell:newSelectedCell];
    
    _selectedCellView = (TallyViewCell *)[_onscreenCells objectForKey:[NSNumber numberWithInt:newSelectedCell]];
}

@end