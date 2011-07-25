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



@interface ScrollingTallyDetailVC : TallyDetailVC {
    
    UIImageView *_customizeAlertImage;
    TallyView *_scrollView;
    
    NSMutableArray *_labels;
    
    UILabel *_aLabel;
    UILabel *_bLabel;
    UILabel *_cLabel;
    UILabel *_dLabel;
    UILabel *_eLabel;
    UILabel *_fLabel;
    UILabel *_gLabel;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *customizeAlertImage;
@property (nonatomic, retain) IBOutlet TallyView *scrollView;

@end
