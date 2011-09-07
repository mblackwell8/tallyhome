//
//  ScrollingTallyDetailVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyDetailVC.h"
#import "THHomePricePath.h"
#import "THTimeSeries.h"
#import "THURLCreator.h"
#import "PropertySettingsVC.h"
#import "TallyHomeConstants.h"
#import "ScrollWheel.h"
#import <QuartzCore/QuartzCore.h>

//#define TH_FIRST_RGB_STEP_IX 0
//#define TH_MIDDLE_RGB_STEP_IX 10
//#define TH_LAST_RGB_STEP_IX 20


@interface ScrollingTallyDetailVC : TallyDetailVC <ScrollWheelDelegate, PropertySettingsDelegate, NSCoding> {
    
    UIImageView *_customizeAlertImage;
    UIActivityIndicatorView *_waitingForDataIndicator;
    
    UILabel *_currentValueLbl;
    UILabel *_currentDateLbl;
    UILabel *_commentLbl;
    THDateVal *_displayedValue;
    THDateVal *_nowValue;
    THDateVal *_nowValueToEncode;
    THDateVal *_lastNowValue;
    UIView *_backgroundRect;
    NSNumberFormatter *_valueFormatter;
    NSNumberFormatter *_commentValueFormatter;
    ScrollWheel *_scroller;
    
    UIActivityIndicatorView *_activityIndicator;
        
    //NSMutableArray *_displayedDateVals;
    
    NSString *_location;
    NSString *_propertyName;
    THHomePricePath *_pricePath;
    THTimeSeries *_displayedData;
    
    NSTimer *_autoUpdateTimer;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *customizeAlertImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingForDataIndicator;

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, retain) THHomePricePath *pricePath;
@property (nonatomic, retain, readonly) THTimeSeries *displayedData;
@property (nonatomic, retain) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;
@property (nonatomic, retain) IBOutlet UIView *backgroundRect;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet ScrollWheel *scroller;
@property (nonatomic, retain) THDateVal *currentValue;

- (void)_initPricePath;
//- (void)_applyData:(THDateVal *)data toTallyViewCell:(UIView *)cell atIndex:(NSInteger)ix;
- (void)_editProperty;


@end
