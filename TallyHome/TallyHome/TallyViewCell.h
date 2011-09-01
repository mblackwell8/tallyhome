//
//  TallyViewCell.h
//  TallyHome
//
//  Created by Mark Blackwell on 21/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDateVal.h"
#import "THDate.h"
#import "DebugMacros.h"
#import "TallyHomeConstants.h"


@interface TallyViewCell : UIView {
    NSString *_dateLabel;
    NSString *_valueLabel;
    
    UIFont *_dateFont;  
    UIFont *_summaryDisplayDateFont;
    UIFont *_valueFont;
    UIFont *_commentFont;
    
    // this is just a convenience tag
    THDateVal *_data;
    
    int _number;
    
    BOOL _isSummaryDisplayOnly;
    
}

@property (copy, nonatomic) THDateVal *data;
@property (assign, nonatomic) BOOL isSummaryDisplayOnly;
@property (nonatomic, assign) int number;


@end
