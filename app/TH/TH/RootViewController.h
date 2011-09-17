//
//  RootViewController.h
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyVCArray.h"

@interface RootViewController : UITableViewController {    
    TallyVCArray *_tallyViewDetailControllers;
}

@property (nonatomic, retain) TallyVCArray *detailControllers;

- (void)navigateToTallyViewAtIndex:(NSUInteger)index animated:(BOOL)anim;
- (void)addButtonPressed:(id)sender;
- (void)addNewScrollingTallyDetailVC;

@end
