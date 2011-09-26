//
//  TextEntryVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextEntryVC;

@protocol TextEntryVCDelegate <NSObject>

- (BOOL)textEntryShouldReturn:(TextEntryVC *)textEntry;

@end

@interface TextEntryVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {  
    UITableView *_textTableView;
    UITextField *_textField;
    id <TextEntryVCDelegate> _delegate;
    
    NSString *_headerText;
    NSString *_commentText;
    UIKeyboardType _kbdType;
    
}

@property (nonatomic, assign) id <TextEntryVCDelegate> delegate;
@property (nonatomic, readonly, retain) UITextField *textField;
@property (nonatomic, copy) NSString *guidanceMessage, *previousData;
@property (nonatomic, assign) UIKeyboardType keyboardType;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (void)textFieldEditingDidEnd:(id)sender;

@end
