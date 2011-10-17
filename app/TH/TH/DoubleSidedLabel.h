//
//  DoubleSidedLabel.h
//  TH
//
//  Created by Mark Blackwell on 6/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DoubleSidedLabel : UIView {
    UILabel *_sideOne, *_sideTwo;
    BOOL _isSideOneShowing;
}

//@property (nonatomic, retain, readonly) UILabel *sideOne, *sideTwo;

@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) UIColor *textColor;


- (UILabel *)visibleLabel;
- (UILabel *)invisibleLabel;
- (void)flipWithAnimation:(BOOL)animated;

@end
