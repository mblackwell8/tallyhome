//
//  RootViewController.h
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TallyVCArray.h"

@class  TallyDetailVC;

@interface RootViewController : UITableViewController {    
    TallyVCArray *_tallies;
    TallyDetailVC *_activeTally;
}

@property (nonatomic, retain) TallyVCArray *detailControllers;
@property (nonatomic, readonly, retain) TallyDetailVC *activeTally;

- (void)navigateToTallyViewAtIndex:(NSUInteger)index animated:(BOOL)anim;
- (void)addButtonPressed:(id)sender;
- (void)addNewScrollingTallyDetailVC;

@end
