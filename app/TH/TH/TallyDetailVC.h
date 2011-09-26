//
//  TallyDetailVC.h
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GetTallyHomeVersionNum ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])


@interface TallyDetailVC : UIViewController <NSCoding> {
    UIImage *_rowImage;
}

@property (nonatomic, retain) UIImage *rowImage;

- (NSString *)rowLatestData;
- (NSString *)rowTitle;

- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;


@end
