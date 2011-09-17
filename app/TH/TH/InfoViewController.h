//
//  InfoViewController.h
//  TH
//
//  Created by Mark Blackwell on 13/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewControllerDelegate;

@interface InfoViewController : UIViewController <UIWebViewDelegate> {
	id <InfoViewControllerDelegate> _delegate;
	
    UIWebView *_contentWebView;
	NSString *_resourceFileName;
}

@property (retain, nonatomic) NSString *resourceFileName;

@property (nonatomic, assign) id <InfoViewControllerDelegate> delegate;

- (IBAction)done;

@end

@protocol InfoViewControllerDelegate
- (void)infoViewControllerDidFinish:(InfoViewController *)controller;
@end

