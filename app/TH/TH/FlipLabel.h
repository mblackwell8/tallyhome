//
//  FlipLabel.h
//  TH
//
//  Created by Mark Blackwell on 26/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FlipLabel : UIView {
    BOOL _shouldReload;
}

@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) UIColor *textColor;
//@property (nonatomic, retain, readonly) UILabel *visibleLabel, *nextLabel;
@property (nonatomic, assign) NSUInteger digit;

- (void)flipForwardTo:(NSUInteger)digit withAnimation:(BOOL)animated;
- (void)flipForwardWithAnimation:(BOOL)animated;

- (void)flipBackwardTo:(NSUInteger)digit withAnimation:(BOOL)animated;
- (void)flipBackwardWithAnimation:(BOOL)animated;

- (void)reload;

@end
