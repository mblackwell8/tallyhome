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
#import "InfoViewController.h"
#import <QuartzCore/QuartzCore.h>

//#define TH_FIRST_RGB_STEP_IX 0
//#define TH_MIDDLE_RGB_STEP_IX 10
//#define TH_LAST_RGB_STEP_IX 20


@interface ScrollingTallyDetailVC : TallyDetailVC <ScrollWheelDelegate, PropertySettingsDelegate, InfoViewControllerDelegate, NSCoding> {
    
    UIImageView *_settingsNotSetAlertView;   
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
//    THDateVal *_nowValueToEncode;
    THDateVal *_lastNowValue;
    
    NSString *_city, *_country;
    NSString *_propertyName;
    THHomePricePath *_pricePath;
    THTimeSeries *_displayedData;

    BOOL _isInitingPricePath;
    BOOL _forceInitPricePath;
    BOOL _isSettingsSet;
}

@property (nonatomic, retain) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentLabel;
@property (nonatomic, retain) IBOutlet UIView *backgroundRect;
@property (nonatomic, retain) IBOutlet ScrollWheel *scroller;
@property (nonatomic, retain) IBOutlet UIImageView *settingsNotSetAlertView;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIBarButtonItem *infoButton, *refreshButton;
@property (nonatomic, retain) UIActivityIndicatorView *waitingForDataIndicator;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;

@property (nonatomic, copy) NSString *city, *country;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, retain) THHomePricePath *pricePath;
@property (nonatomic, retain, readonly) THTimeSeries *displayedData;
@property (nonatomic, retain) THDateVal *displayedValue;
@property (nonatomic, retain) THDateVal *nowValue;




@end
