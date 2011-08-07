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
    UILabel *_dateLabel;
    UILabel *_valueLabel;
    UILabel *_commentLabel;
    
    THDateVal *_data;
    
}

@property (retain, nonatomic) UILabel *dateLabel;
@property (retain, nonatomic) UILabel *valueLabel;
@property (retain, nonatomic) UILabel *commentLabel;
@property (retain, nonatomic) THDateVal *data;

@end
