//
//  ScrollingTallyDetailVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyDetailVC.h"
#import "TallyView.h"
#import "TallyViewCell.h"
#import "THHomePricePath.h"
#import "THTimeSeries.h"
#import "THURLCreator.h"
#import "PropertySettingsVC.h"
#import <QuartzCore/QuartzCore.h>

#define TH_FIRST_RGB_STEP_IX 0
#define TH_MIDDLE_RGB_STEP_IX 10
#define TH_LAST_RGB_STEP_IX 20


@interface ScrollingTallyDetailVC : TallyDetailVC <TallyViewDelegate, PropertySettingsDelegate, NSCoding> {
    
    UIImageView *_customizeAlertImage;
    TallyView *_scrollView;
    UIActivityIndicatorView *_waitingForDataIndicator;
        
    //NSMutableArray *_displayedDateVals;
    
    NSString *_location;
    NSString *_propertyName;
    THHomePricePath *_pricePath;
    THTimeSeries *_displayedData;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *customizeAlertImage;
@property (nonatomic, retain) IBOutlet TallyView *scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingForDataIndicator;

@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *propertyName;
@property (nonatomic, retain) THHomePricePath *pricePath;
@property (nonatomic, retain, readonly) THTimeSeries *displayedData;

- (void)_initPricePath;
- (void)_applyData:(THDateVal *)data toTallyViewCell:(UIView *)cell atIndex:(NSInteger)ix;
- (void)_editProperty;


@end
