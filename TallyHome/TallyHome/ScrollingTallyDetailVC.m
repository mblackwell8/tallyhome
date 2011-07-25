//
//  ScrollingTallyDetailVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollingTallyDetailVC.h"

#define TH_XGAP 32.0
#define TH_YGAP 5.0
#define TH_OFFSET 60.0

#define TH_L0_X 100.0
#define TH_L0_Y 0.0
#define TH_L0_W 118.0
#define TH_L0_H 30.0

@implementation ScrollingTallyDetailVC
@synthesize customizeAlertImage = _customizeAlertImage;
@synthesize scrollView = _scrollView;

- (id)init {
    if ((self = [self initWithNibName:@"ScrollingTallyDetailVC" bundle:nil])) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        

    }
    return self;
}

#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    return @"???";
}
- (NSString *)rowTitle {
    return @"hello world";
}

- (void)dealloc
{
    [_customizeAlertImage release];
    [_scrollView release];
    [_labels release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    _scrollView.contentSize = CGSizeMake(320.0, 1600.0);
//    [_scrollView setContentOffset:CGPointMake(0, 600.0)];
    
    // make the five labels, with starting locations
    _aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _bLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _cLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _dLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _eLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _fLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _gLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    _labels = [[NSArray alloc] initWithObjects:_aLabel, _bLabel, _cLabel, _dLabel, _eLabel, _fLabel, _gLabel, nil];
    
    UIFont *f = [UIFont fontWithName:@"Helvetica" size:50.0];
    for (UILabel *l in _labels) {
        l.font = f;
        l.backgroundColor = [UIColor blueColor];
        l.text = @"lorem ipsum blah";
        l.numberOfLines = 1;
        l.adjustsFontSizeToFitWidth = YES;
        l.minimumFontSize = 4.0;
    }
        
//    [_scrollView addSubview:_aLabel];
//    [_aLabel release];
//    [_scrollView addSubview:_bLabel];
//    [_bLabel release];
//    [_scrollView addSubview:_cLabel];
//    [_cLabel release];
//    [_scrollView addSubview:_dLabel];
//    [_dLabel release];
//    [_scrollView addSubview:_eLabel];
//    [_eLabel release];
    
    [_scrollView setViews:_labels];

}

- (void)viewDidUnload
{
    [self setCustomizeAlertImage:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
