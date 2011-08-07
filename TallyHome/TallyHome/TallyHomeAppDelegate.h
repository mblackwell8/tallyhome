//
//  TallyHomeAppDelegate.h
//  TallyHome
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//put in a . directory in the documents folder
#define kUseArchive                 NO
#define kTallyHomeArchivePath       @".tallyhome.archive"
#define kTallyHomeSettingsPath      @".settings.plist"

@interface TallyHomeAppDelegate : NSObject <UIApplicationDelegate> {
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end