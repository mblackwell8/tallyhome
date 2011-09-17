//
//  THAppDelegate.h
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;

@interface THAppDelegate : NSObject <UIApplicationDelegate> {
    Reachability* _hostReach;
    NSDictionary *_appDefaults;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain, readonly) Reachability *serverReachability;
@property (nonatomic, retain, readonly) NSDictionary *appDefaults;

- (NSString *)getUUID;

@end
