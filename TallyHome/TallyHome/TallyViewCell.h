//
//  TallyViewCell.h
//  TallyHome
//
//  Created by Mark Blackwell on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDateVal.h"

@interface TallyViewCell : UIView {
    NSString *_dateLabel;
    NSString *_valueLabel;
    
    UIFont *_dateFont;  
    UIFont *_panningFastDateFont;
    UIFont *_valueFont;
    UIFont *_commentFont;
    
    // this is just a convenience tag
    THDateVal *_data;
    
    BOOL _isPanningFast;
    
}

@property (copy, nonatomic) THDateVal *data;
@property (assign, nonatomic) BOOL isPanningFast;

- (void)scaleFontsBy:(CGFloat)scaleFactor;

@end
