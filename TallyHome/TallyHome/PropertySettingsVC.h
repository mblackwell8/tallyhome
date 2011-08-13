//
//  PropertySettingsVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDateVal.h"

@class PropertySettingsVC;

@protocol PropertySettingsDelegate <NSObject>

@optional

- (void)propertySettingsWillFinishDone:(PropertySettingsVC *)propSettings;
- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings;

@end

@interface PropertySettingsVC : UITableViewController {
    id <PropertySettingsDelegate> _delegate;
    
    NSString *_location;
    NSString *_propertyName;
    THDateVal *_buyPrice;
}

@property (assign, nonatomic) id <PropertySettingsDelegate> delegate;

@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *propertyName;
@property (retain, nonatomic) THDateVal *buyPrice;

- (void)_done;
- (void)_cancel;


@end
