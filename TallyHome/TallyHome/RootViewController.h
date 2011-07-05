//
//  RootViewController.h
//  TallyHome
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//put in a . directory in the documents folder
#define kTallyHomeArchivePath       @".tallyhome/tallyhome.archive"
#define kTallyHOmeSettingsPath      @".tallyhome/settings.plist"


@interface RootViewController : UITableViewController /*<UITableViewDelegate, UITableViewDataSource>*/ {
    NSArray *_detailControllers;
}

@property (nonatomic, retain) NSArray *detailControllers;


@end
