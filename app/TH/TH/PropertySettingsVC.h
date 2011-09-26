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
#import "SearchSelectorVC.h"
#import "THHomePriceIndex.h"
#import "THPlaceName.h"

@class PropertySettingsVC;

@protocol PropertySettingsDelegate <NSObject>

@optional

- (void)propertySettingsWillFinishDone:(PropertySettingsVC *)propSettings;
- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings;

@end

@interface PropertySettingsVC : UITableViewController <TextEntryVCDelegate, DateSelectorDelegate, TableSelectorDelegate, SearchBarSelectorDelegate> {
    id <PropertySettingsDelegate> _delegate;
    
    THPlaceName *_location;
    NSString *_propertyName;
    THDateVal *_buyPrice;
    
    //NSUInteger 
    NSString *_proximitiesIncluded;
    NSString *_sourcesIncluded;
    NSString *_forecastingTimeScale;
    
    NSIndexPath *_selectedIndexPath;
}

@property (assign, nonatomic) id <PropertySettingsDelegate> delegate;
@property (copy, nonatomic) NSString *propertyName;
@property (nonatomic, retain) THPlaceName *location;
@property (copy, nonatomic) NSString *proximitiesIncluded, *sourcesIncluded, *forecastingTimeScale;
@property (nonatomic, assign) THHomePriceIndexSource sources;
@property (nonatomic, assign) THHomePriceIndexProximity proximities;
@property (nonatomic, assign) NSTimeInterval trendExtrapolationInterval;
@property (retain, nonatomic) THDateVal *buyPrice;
@property (retain, nonatomic) NSIndexPath *selectedIndexPath;

- (void)_done;
- (void)_cancel;


@end
