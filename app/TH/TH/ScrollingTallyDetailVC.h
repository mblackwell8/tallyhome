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
#import "THPlaceName.h"
#import "PropertySettingsVC.h"
#import "TallyHomeConstants.h"
#import "ScrollWheel.h"
#import "InfoViewController.h"
#import <QuartzCore/QuartzCore.h>

//#define TH_FIRST_RGB_STEP_IX 0
//#define TH_MIDDLE_RGB_STEP_IX 10
//#define TH_LAST_RGB_STEP_IX 20


@interface ScrollingTallyDetailVC : TallyDetailVC <ScrollWheelDelegate, PropertySettingsDelegate, InfoViewControllerDelegate, NSCoding> {
    
    UIImageView *_helpStepOneView, *_helpStepTwoView, *_helpStepThreeView;
    
    UIView *_backgroundRect;
    UILabel *_currentDateLbl;
    UILabel *_currentValueLbl;
    UILabel *_commentLbl;
    ScrollWheel *_scroller;
    UIToolbar *_bottomToolbar;                                               
    UIBarButtonItem *_infoButton;
    UILabel *_statusLabel;
    UIBarButtonItem *_refreshButton;
    UIActivityIndicatorView *_waitingForDataIndicator;

    NSTimer *_autoUpdateTimer;
    
    NSNumberFormatter *_valueFormatter;
    NSNumberFormatter *_commentValueFormatter;
        
    THDateVal *_displayedValue;
    THDateVal *_nowValue;
    THDateVal *_nowValueToEncode;
    THDateVal *_lastNowValue;
    
    //NSString *_city, *_country;
    THPlaceName *_location;
    NSString *_propertyName;
    THHomePricePath *_pricePath;
    THTimeSeries *_displayedData;
    NSTimeInterval _decodedOrDefaultTrendInterval;

    BOOL _isUpdatingPricePath;
    //BOOL _forceInitPricePath;
    BOOL _isHelpStepOneDone, _isHelpStepTwoDone, _isHelpStepThreeDone;
    
    NSString *_updateWorkerErrorMessage;
}

@property (nonatomic, retain) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;
@property (nonatomic, retain) IBOutlet UIView *backgroundRect;
@property (nonatomic, retain) IBOutlet ScrollWheel *scroller;
@property (nonatomic, retain) IBOutlet UIImageView *helpStepOneView;
@property (nonatomic, retain) IBOutlet UIImageView *helpStepTwoView;
@property (nonatomic, retain) IBOutlet UIImageView *helpStepThreeView;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIBarButtonItem *infoButton, *refreshButton;
@property (nonatomic, retain) UIActivityIndicatorView *waitingForDataIndicator;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;

//@property (nonatomic, copy) NSString *city, *country;
@property (nonatomic, retain) THPlaceName *location;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, retain) THHomePricePath *pricePath;
@property (nonatomic, retain, readonly) THTimeSeries *displayedData;
@property (nonatomic, retain) THDateVal *displayedValue;
@property (nonatomic, retain) THDateVal *nowValue, *nowValueToEncode;


@end
