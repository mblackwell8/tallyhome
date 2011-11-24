//
//  TickingValueLabel.h
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlipLabel.h"

@interface TickingValueLabel : UIView {
    NSNumberFormatter *_valueFormatter;
    double _value;
//    NSString *_valueStr;
    UILabel *_dollarLabel;
    UIFont *_font;
    UIColor *_textColor;
    
    FlipLabel *_tenCentLabel, *_centLabel;
}

@property (nonatomic, retain) UILabel *dollarLabel;
@property (nonatomic, assign) double value;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor, *highlightColor;

@end
