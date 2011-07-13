//
//  ScrollingTallyDetailVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyDetailVC.h"
#import "TouchedScrollView.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define LALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface ScrollingTallyDetailVC : TallyDetailVC <UIScrollViewDelegate> {
    
    UIImageView *_customizeAlertImage;
    TouchedScrollView *_scrollView;
    
    NSMutableArray *_labels;
    
    UILabel *_aLabel;
    UILabel *_bLabel;
    UILabel *_cLabel;
    UILabel *_dLabel;
    UILabel *_eLabel;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *customizeAlertImage;
@property (nonatomic, retain) IBOutlet TouchedScrollView *scrollView;


- (void)_scrollLabels:(CGFloat)points;

//determines whether a given drag has taken the labels
//more than a critical point (50%?) of the gap between them
//if so, then animate the last little bit
- (void)_reshuffle;

@end
