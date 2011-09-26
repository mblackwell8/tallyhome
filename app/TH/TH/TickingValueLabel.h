//
//  TickingValueLabel.h
//  TH
//
//  Created by Mark Blackwell on 21/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TickingValueLabel : UIView {
    UILabel *_bigFigure;
    UILabel *_smallFigureOne, *_smallFigureTwo;
    
    NSNumberFormatter *_valueFormatter;
    double _value;
    NSString *_valueStr;
}

@property (nonatomic, assign) double value;

@end
