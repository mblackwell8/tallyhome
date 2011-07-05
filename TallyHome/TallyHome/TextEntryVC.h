//
//  TextEntryVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextEntryVC : UIViewController {
    IBOutlet UITextField *_textField;
    NSString *_checkRegex;
    
    //some setting for the keyboard to show
    
}

@property (nonatomic, retain) NSString *enteredText;


@end
