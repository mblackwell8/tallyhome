//
//  THDateSelectorVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  adapted from http://iphonedevelopment.blogspot.com/2009/01/better-generic-date-picker.html

#import <UIKit/UIKit.h>

@protocol DateSelectorDelegate <NSObject>
@required
- (void)setDate:(NSDate *)newDate;
//- (UINavigationController *)navController;          // Return the navigation controller
@end

@interface DateSelectorVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UITableView  *dateTableView;
    NSDate *_date;
    
    id <DateSelectorDelegate> _delegate;   // weak ref
}

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UITableView *dateTableView;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign)  id <DateSelectorDelegate> delegate;
-(IBAction)dateChanged;

@end