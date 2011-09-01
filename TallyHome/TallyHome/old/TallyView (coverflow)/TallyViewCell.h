//
//  TallyViewCell.h
//  TallyHome
//
//  Created by Mark Blackwell on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDateVal.h"
#import <QuartzCore/QuartzCore.h>

@interface TallyViewCell : UIView {
    NSString *_dateLabel;
    NSString *_valueLabel;
    
    UIFont *_dateFont;  
    UIFont *_valueFont;
    UIFont *_commentFont;
    
    CALayer *_summary, *_detail;
    
    // this is just a convenience tag
    THDateVal *_data;
    
    int	_number;
//	CGFloat	_horizontalPosition;
//	CGFloat	_verticalPosition;
    
}

@property (copy, nonatomic) THDateVal *data;
@property (nonatomic, retain) CALayer *summary, *detail;

@property (nonatomic, assign) int number;
//@property (nonatomic, readonly) CGFloat horizontalPosition;
//@property (nonatomic, readonly) CGFloat verticalPosition;

- (CALayer *)createSummaryLayer;
- (CALayer *)createDetailLayer;


@end

