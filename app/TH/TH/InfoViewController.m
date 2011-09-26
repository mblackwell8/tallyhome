//
//  InfoViewController.m
//  TH
//
//  Created by Mark Blackwell on 13/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController

@synthesize delegate = _delegate;
@synthesize resource = _resource;

- (void)dealloc {
    [_contentWebView release];
    [_resource release];
    
    [super dealloc];
}


- (IBAction)done {
	[self.delegate infoViewControllerDidFinish:self];	
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	//allow internal links (and any links to a file) to pass through unaltered
	if (navigationType == UIWebViewNavigationTypeLinkClicked && !request.URL.isFileURL) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	
	return YES;
}


#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
//    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.view = theView;
//    [theView release];
//    
    CGFloat screenHt = 480.0 - 20.0; //allow for status bar
    if (self.navigationController)
        screenHt -= 44;
    if (self.tabBarController)
        screenHt -= 49;
    
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, screenHt);
    UIView *v = [[UIView alloc] initWithFrame:screenRect];
    
    _contentWebView = [[UIWebView alloc] initWithFrame:screenRect];
    _contentWebView.delegate = self;
    [v addSubview:_contentWebView];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(done)]; 
    
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];    

    self.view = v;
    [v release];
    
	NSURLRequest *request = [NSURLRequest requestWithURL:_resource];
	//[[contentWebView mainFrame] loadRequest:request];
	[_contentWebView loadRequest:request];
	
	_contentWebView.delegate = self;

}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
