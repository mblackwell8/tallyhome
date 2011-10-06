//
//  TickingValueLabel.h
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TickingValueLabel : UIView {
    NSNumberFormatter *_valueFormatter;
    double _value;
    NSString *_valueStr;
    UIFont *_font;
    UIColor *_textColor;
    
    NSMutableArray *_centLabels, *_tenCentLabels;
}

@property (nonatomic, assign) double value;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) UIColor *textColor;

@end
