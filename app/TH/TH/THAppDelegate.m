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
#import "Reachability.h"
#import "SplashView.h"

//put in a . directory in the documents folder
#define kUseArchive                 YES
#define kTallyHomeArchivePath       @".tallyhome.archive"
#define kTallyHomeSettingsPath      @".settings.plist"

@interface THAppDelegate ()

@property (nonatomic, retain, readwrite) Reachability *serverReachability;
@property (nonatomic, retain, readwrite) NSDictionary *appDefaults;

- (void)unArchive;
- (void)doArchive;
- (RootViewController *)getRVC;

@end

@implementation THAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize serverReachability = _hostReach;
@synthesize appDefaults = _appDefaults;

- (RootViewController *)getRVC {
    return [self.navigationController.viewControllers objectAtIndex:0];
}

- (NSString *)getUUID {
    return [TallyVCArray uniqueUserId];
}

#pragma Archiving

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
            RootViewController *rvc = [self getRVC];
            rvc.detailControllers = detailControllers;
        } 
        @catch ( NSException *e ) {
            DLog(@"Exception on archive load %@", e);
        }
    }
    
}



- (void)doArchive {
	
	DLog(@"Archiving...");
	
    RootViewController *rvc = [self getRVC];
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

#pragma Reachability

- (void)startReachability {
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    NSString *serverURLstr = [_appDefaults objectForKey:@"serverHostname"];
	_hostReach = [[Reachability reachabilityWithHostName:serverURLstr] retain];
	[_hostReach startNotifier];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    // Reachability seems to be either a hostname (www.xyz.com), an IP or
    // one of two static strings (kInternetConnection or kLocalWiFiConnection)
    self.serverReachability = curReach;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AppDefaults" ofType:@"plist"];
    NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.appDefaults = defaults;
    [defaults release];
    
    [self startReachability];
    
    [self unArchive];
    
    SplashView *splash = [[SplashView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [splash startSplash];
        
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //not called on first load...
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    //[self unArchive];
    
    RootViewController *rvc = [self getRVC];
    if (rvc.activeTally)
        [rvc.activeTally applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [_hostReach startNotifier];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [_hostReach stopNotifier];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"applicationDidEnterBackground called...");
    
    RootViewController *rvc = [self getRVC];
    if (rvc.activeTally)
        [rvc.activeTally applicationDidEnterBackground:application];
    
    [self doArchive];
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DLog(@"applicationWillTerminate called...");
    [self doArchive];
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc {
    [_window release];
    [_navigationController release];
    [_hostReach release];
    [_appDefaults release];
    
    [super dealloc];
}

@end
