//
//  TableSelectorVC.h
//  TH
//
//  Created by Mark Blackwell on 13/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TableSelectorDelegate;

@interface TableSelectorVC : UITableViewController {
    NSArray *_options;
    NSMutableArray *_selectedOptions;
    BOOL _allowsMultipleSelections;
    BOOL _allowsNoSelection;
    
    id <TableSelectorDelegate> _delegate;
}

@property (retain, nonatomic) NSArray *options;
@property (retain, nonatomic) NSArray *selectedOptions;
@property (nonatomic, assign) BOOL allowsMultipleSelections;
@property (nonatomic, assign) BOOL allowsNoSelection;
@property (nonatomic, assign) id <TableSelectorDelegate> delegate;

- (void)setOptionsUsingCSV:(NSString *)csv;
- (void)setSelectedOptionsUsingCSV:(NSString *)csv;
- (NSString *)selectedOptionUsingCSV;

@end

@protocol TableSelectorDelegate <NSObject>

- (void)tableSelectorDidSelect:(TableSelectorVC *)tableSelector itemNumber:(NSUInteger)num;

@optional
- (void)tableSelectorDidUnselect:(TableSelectorVC *)tableSelector itemNumber:(NSUInteger)num;
- (void)tableSelectorWillFinishDone:(TableSelectorVC *)tableSelector;

@end