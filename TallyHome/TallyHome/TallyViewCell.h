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
    NSString *_commentLabel;
    
    UIFont *_dateFont;  
    UIFont *_valueFont;
    UIFont *_commentFont;
    
    // this is just a convenience tag
    THDateVal *_data;
    
}

@property (retain, nonatomic) NSString *dateLabel;
@property (retain, nonatomic) NSString *valueLabel;
@property (retain, nonatomic) NSString *commentLabel;
@property (retain, nonatomic) THDateVal *data;

- (void)scaleFontsBy:(CGFloat)scaleFactor;

@end
