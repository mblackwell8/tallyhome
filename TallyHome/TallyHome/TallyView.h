//
//  TallyView.h
//  TallyHome
//
//  Created by Mark Blackwell on 16/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TallyView;

@protocol TallyViewDataSource<NSObject>

@required

- (double)tallyView:(TallyView *)tv valueForDate:(NSDate *)dt;

@end


@interface TallyView : UIView {
    id <TallyViewDataSource> *delegate;
    
    UIView *_aV;
    UIView *_bV;
    UIView *_cV;
    UIView *_dV;
    UIView *_eV;
    
    NSMutableArray *_views;
    
    CGFloat panPointsSinceLastShift;
    
}

//@property (retain, nonatomic) NSArray *views;

- (void)setViews:(NSArray *)views;

@end
