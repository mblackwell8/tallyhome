//
//  PropertySettingsVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDateVal.h"
#import "TextEntryVC.h"
#import "DateSelectorVC.h"
#import "TableSelectorVC.h"
#import "THHomePriceIndex.h"

@class PropertySettingsVC;

@protocol PropertySettingsDelegate <NSObject>

@optional

- (void)propertySettingsWillFinishDone:(PropertySettingsVC *)propSettings;
- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings;

@end

@interface PropertySettingsVC : UITableViewController <TextEntryVCDelegate, DateSelectorDelegate, TableSelectorDelegate> {
    id <PropertySettingsDelegate> _delegate;
    
    NSString *_location;
    NSString *_propertyName;
    THDateVal *_buyPrice;
    
    //NSUInteger 
    NSString *_proximitiesIncluded;
    NSString *_sourcesIncluded;
    NSString *_forecastingTimeScale;
}

@property (assign, nonatomic) id <PropertySettingsDelegate> delegate;
@property (copy, nonatomic) NSString *location, *propertyName;
@property (copy, nonatomic) NSString *proximitiesIncluded, *sourcesIncluded, *forecastingTimeScale;
@property (nonatomic, assign) THHomePriceIndexSource sources;
@property (nonatomic, assign) THHomePriceIndexProximity proximities;
@property (nonatomic, assign) NSTimeInterval trendExtrapolationInterval;
@property (retain, nonatomic) THDateVal *buyPrice;

- (void)_done;
- (void)_cancel;


@end
