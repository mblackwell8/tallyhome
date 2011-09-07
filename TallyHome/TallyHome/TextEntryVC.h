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

@interface TextEntryVC : UIViewController <UITextFieldDelegate> {  
    UITextField *_textField;
    id <TextEntryVCDelegate> _delegate;
    
    NSString *_guidanceMsg, *_preData;
    UIKeyboardType _kbdType;
    
}

@property (nonatomic, assign) id <TextEntryVCDelegate> delegate;
@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic, copy) NSString *guidanceMessage, *previousData;
@property (nonatomic) UIKeyboardType keyboardType;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (void)textFieldEditingDidEnd:(id)sender;

@end
