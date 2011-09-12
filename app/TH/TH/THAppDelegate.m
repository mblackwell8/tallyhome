//
//  THAppDelegate.m
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "THAppDelegate.h"
#import "DebugMacros.h"
#import "RootViewController.h"
#import "TallyVCArray.h"

//put in a . directory in the documents folder
#define kUseArchive                 NO
#define kTallyHomeArchivePath       @".tallyhome.archive"
#define kTallyHomeSettingsPath      @".settings.plist"


@implementation THAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

+ (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDirectory = [paths objectAtIndex:0];
	return [docsDirectory stringByAppendingPathComponent:kTallyHomeArchivePath];
}

+ (NSString *)settingsFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDirectory = [paths objectAtIndex:0];
	return [docsDirectory stringByAppendingPathComponent:kTallyHomeSettingsPath];
}

- (void)unArchive {
    NSString *archivePath = [THAppDelegate dataFilePath];
    if (kUseArchive && [[NSFileManager defaultManager] isReadableFileAtPath:archivePath]) {
        DLog(@"Recovering last use from %@...", archivePath);
        
        @try {
            TallyVCArray *detailControllers = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
            RootViewController *rvc = (RootViewController *)self.navigationController.topViewController;
            rvc.detailControllers = detailControllers;
        } 
        @catch ( NSException *e ) {
            DLog(@"Exception on archive load %@", e);
        }
    }
    
}



- (void)doArchive {
	
	DLog(@"Archiving...");
	
    TallyVCArray *rvc = (TallyVCArray *)self.navigationController.topViewController;
	NSString *archivePath = [THAppDelegate dataFilePath];
	NSString *archivePath_TMP = [archivePath stringByAppendingString:@".tmp"];
	BOOL wasSuccess = [NSKeyedArchiver archiveRootObject:rvc.detailControllers toFile:archivePath_TMP];
	NSFileManager *dfltMgr = [NSFileManager defaultManager];
	if (wasSuccess) {
		//check that a file exists at the path first, because on the first run it won't, so no need to remove
		BOOL shouldMove = (![dfltMgr fileExistsAtPath:archivePath]) ||
        ([dfltMgr fileExistsAtPath:archivePath] && [dfltMgr removeItemAtPath:archivePath error:NULL]);
		if (shouldMove) {
			[dfltMgr moveItemAtPath:archivePath_TMP
							 toPath:archivePath
							  error:NULL];
		}
	}
	
	DLog(@"Finished archiving... %d", wasSuccess);
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

@end
