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


@interface TextEntryVC : UIViewController {
    UITextField *_textField;
    
    id <TextEntryVCDelegate> _delegate;
    
    
}

@property (nonatomic, readonly, retain) IBOutlet UITextField *textField;

@property (nonatomic, assign) id <TextEntryVCDelegate> delegate;


@end
