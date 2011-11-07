//
//  Flipper.h
//  TH
//
//  Created by Mark Blackwell on 29/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Flipper : UIView

- (void)addFrontView:(UIView *)front;
- (void)addBackView:(UIView *)back;
- (void)flipForward;
- (void)flipBackward;
//- (void)showFront;
//- (void)showBack;

@property (nonatomic, readonly) BOOL isFrontShowing;

@end
