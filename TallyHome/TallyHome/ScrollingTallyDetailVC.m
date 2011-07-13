//
//  ScrollingTallyDetailVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollingTallyDetailVC.h"

#define TH_XGAP 32.0
#define TH_YGAP 5.0
#define TH_OFFSET 60.0

#define TH_L0_X 100.0
#define TH_L0_Y 620.0
#define TH_L0_W 118.0
#define TH_L0_H 30.0

@implementation ScrollingTallyDetailVC
@synthesize customizeAlertImage = _customizeAlertImage;
@synthesize scrollView = _scrollView;

- (id)init {
    if ((self = [self initWithNibName:@"ScrollingTallyDetailVC" bundle:nil])) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        

    }
    return self;
}

#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    return @"???";
}
- (NSString *)rowTitle {
    return @"hello world";
}

- (void)dealloc
{
    [_customizeAlertImage release];
    [_scrollView release];
    [_labels release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _scrollView.contentSize = CGSizeMake(320.0, 1600.0);
    [_scrollView setContentOffset:CGPointMake(0, 600.0)];
    
    // make the five labels, with starting locations
    _aLabel = [[UILabel alloc] initWithFrame:CGRectMake(TH_L0_X, TH_L0_Y, TH_L0_W, TH_L0_H)];
    
    _bLabel = [[UILabel alloc] initWithFrame:CGRectMake(TH_L0_X - TH_XGAP, 
                                                        TH_L0_Y + TH_OFFSET - TH_YGAP, 
                                                        TH_L0_W + TH_XGAP * 2.0, 
                                                        TH_L0_H + TH_YGAP * 2.0)];
    
    _cLabel = [[UILabel alloc] initWithFrame:CGRectMake(TH_L0_X - TH_XGAP * 2.0, 
                                                        TH_L0_Y + (TH_OFFSET - TH_YGAP) * 2.0, 
                                                        TH_L0_W + (TH_XGAP * 2.0) * 2.0, 
                                                        TH_L0_H + (TH_YGAP * 2.0) * 2.0)];
    
    _dLabel = [[UILabel alloc] initWithFrame:CGRectMake(TH_L0_X - TH_XGAP, 
                                                        TH_L0_Y + TH_OFFSET * 3.0 - TH_YGAP, 
                                                        TH_L0_W + TH_XGAP * 2.0, 
                                                        TH_L0_H + TH_YGAP * 2.0)];
    
    _eLabel = [[UILabel alloc] initWithFrame:CGRectMake(TH_L0_X, 
                                                        TH_L0_Y + TH_OFFSET * 4.0, 
                                                        TH_L0_W, 
                                                        TH_L0_H)];
    
    _labels = [[NSArray alloc] initWithObjects:_aLabel, _bLabel, _cLabel, _dLabel, _eLabel, nil];
    
    for (UILabel *l in _labels) {
        l.backgroundColor = [UIColor blackColor];
        l.text = @"label";
    }
        
    [_scrollView addSubview:_aLabel];
    [_aLabel release];
    [_scrollView addSubview:_bLabel];
    [_bLabel release];
    [_scrollView addSubview:_cLabel];
    [_cLabel release];
    [_scrollView addSubview:_dLabel];
    [_dLabel release];
    [_scrollView addSubview:_eLabel];
    [_eLabel release];

}

- (void)viewDidUnload
{
    [self setCustomizeAlertImage:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma UIScrollViewDelegate




// The UIScrollView class can have a delegate that must adopt the UIScrollViewDelegate protocol. For zooming and panning to work, the delegate must implement both viewForZoomingInScrollView: and scrollViewDidEndZooming:withView:atScale:; in addition, the maximum (maximumZoomScale) and minimum ( minimumZoomScale) zoom scale must be different. 




- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	DLog();
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	DLog();
    
    
//    
//	//update positions of views
//    if (!_lastTouch) {
//        if (!_scrollView.touchesBeganAt) {
//            DLog(@"Touches began at is nil");
//            return;
//        }
//        
//        _lastTouch = [[[_scrollView.touchesBeganAt allObjects] objectAtIndex:0] retain];
//        DLog(@"last touch set %@", _lastTouch);
//        return;
//    }
    
    UITouch *thisTouch = [[_scrollView.touchesMovedTo allObjects] objectAtIndex:0];
    DLog(@"this touch is %@", thisTouch);
    if (!thisTouch)
        return;
    
    if (thisTouch.phase != UITouchPhaseMoved)
        return;
    
    float yDist = [thisTouch locationInView:_scrollView].y - 
                  [thisTouch previousLocationInView:_scrollView].y;
    DLog(@"moved %7.5f", yDist);

    [self _scrollLabels:yDist];
    
	//increase size of total canvas so that scroll view thinks more to go
	//http://stackoverflow.com/questions/1493950
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	DLog();
    
	if (!decelerate)
		[self _reshuffle];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    DLog();
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    DLog();
    
    [self _reshuffle];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    DLog();
}

- (void)_scrollLabels:(CGFloat)points {
    if (points == 0.0)
        return;
    
    NSAssert(fabsf(points) < TH_OFFSET, @"reqd points more than offset");
    CGFloat scale = fabsf(points) / TH_OFFSET;
    int ix = 0;
    for (UIView *lbl in (points > 0.0 ? _labels : [[_labels reverseObjectEnumerator] allObjects])) {
        CGRect f = lbl.frame;
        //lbls 1 and 2 get bigger
        if (ix < 2) {
            f.origin.x -= TH_XGAP * scale;
            f.origin.y -= TH_YGAP * scale;
            f.size.width += (TH_XGAP * scale) * 2.0;
            f.size.height += (TH_YGAP * scale) * 2.0;
        }
        //lbls 3, 4 and 5 get smaller
        else {
            f.origin.x += TH_XGAP * scale;
            f.origin.y += TH_YGAP * scale;
            f.size.width -= (TH_XGAP * scale) * 2.0;
            f.size.height -= (TH_YGAP * scale) * 2.0;
        }
        lbl.frame = f;
        
        ix += 1;
    }
    
    //lbl 1 may need to fall off screen and reappear at posn 5 (or reverse)
    UIView *firstLbl = [_labels objectAtIndex:0];
    if (firstLbl.frame.origin.y >= TH_L0_Y + TH_OFFSET - TH_YGAP) {
        DLog(@"First label at %5.2f, shuffling", firstLbl.frame.origin.y);
        UIView *lastLbl = [_labels lastObject];
        [_labels removeLastObject];
        [_labels insertObject:lastLbl atIndex:0];
    }
}

- (void)_reshuffle {
    DLog();
    
    //calc if the drag was far enough to make an animated transition to next slot
    [_scrollView setContentOffset:CGPointMake(0, 600.0)];
}






- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    DLog();
    
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    DLog();
}





// **********  ZOOMING ********

//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
//    DLog();
//}
//
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    DLog();
//}
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    DLog();
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
//    DLog();
//}




//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    DLog();
//    //store location of touch
//	
//    [super touchesBegan:touches withEvent:event];
//}
//     
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    DLog();
//    
//    [super touchesCancelled:touches withEvent:event];
//}
//     
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    DLog();
//    
//    [super touchesEnded:touches withEvent:event];
//}
//     
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    DLog();
//    
//    [super touchesMoved:touches withEvent:event];
//}
//     
     
     

@end
