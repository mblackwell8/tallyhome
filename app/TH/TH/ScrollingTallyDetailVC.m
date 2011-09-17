//
//  ScrollingTallyDetailVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollingTallyDetailVC.h"
//#import "TallyVCArray.h"

#import "DebugMacros.h"
#import "THAppDelegate.h"
#import "Reachability.h"

#define TH_CHECK_REACHABILITY YES

#define kUnknownCity @"Unknown"
#define kDefaultCountry @"Australia"
#define kDefaultPropertyName @"Not set"
#define TH_AUTO_UPDATE_HZ 60.0
//#define MAX_TIMEINTERVAL_UNTIL_SERVER_UPDATE 30*24*60*60


@interface ScrollingTallyDetailVC ()

@property (nonatomic, retain, readwrite) THTimeSeries *displayedData;
@property (nonatomic, retain) NSNumberFormatter *valueFormatter;
@property (nonatomic, retain) NSNumberFormatter *commentValueFormatter;

- (void)initPricePath;
- (void)initPricePathWorker;
- (void)editProperty;
- (void)setDisplayedDateValueTo:(NSDate *)date;
- (void)updateStatusLabel:(NSString *)newText;

- (void)infoButtonTapped:(id)sender;
- (void)refreshButtonTapped:(id)sender;

@end

@implementation ScrollingTallyDetailVC

@synthesize settingsNotSetAlertView = _settingsNotSetAlertView;
@synthesize statusLabel = _statusLabel;
@synthesize infoButton = _infoButton;
@synthesize refreshButton = _refreshButton;
@synthesize waitingForDataIndicator = _waitingForDataIndicator;
@synthesize bottomToolbar = _bottomToolbar;
@synthesize propertyName = _propertyName;
@synthesize pricePath = _pricePath;
@synthesize city = _city;
@synthesize country = _country;
@synthesize displayedData = _displayedData;
@synthesize currentValueLabel = _currentValueLbl;
@synthesize scroller = _scroller;
@synthesize displayedValue = _displayedValue;
@synthesize nowValue = _nowValue;
@synthesize currentDateLabel = _currentDateLbl;
@synthesize commentLabel = _commentLbl;
@synthesize backgroundRect = _backgroundRect;
@synthesize valueFormatter = _valueFormatter;
@synthesize commentValueFormatter = _commentValueFormatter;

- (id)init {
    return [self initWithNibName:@"ScrollingTallyDetailVC" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //HACK: these are released... problematic?
        _city = kUnknownCity;
        _country = kDefaultCountry;
        _propertyName = kDefaultPropertyName;

    }
    return self;
}

#pragma mark NSCoding

#define kVerNoCoding    @"VerNo"
#define kCity           @"City"
#define kCountry        @"Country"
#define kPropertyName   @"PropName"
#define kPricePath      @"PricePath"
#define kLastNowValue   @"LastNowValue"
#define kIsSettingsSet  @"IsSettingsSet"


- (void)encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding ScrollingTallyDetailVC");
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    [encoder encodeObject:_city forKey:kCity];
    [encoder encodeObject:_country forKey:kCountry];
    [encoder encodeObject:_propertyName forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
    [encoder encodeObject:_nowValue forKey:kLastNowValue];
    [encoder encodeBool:_isSettingsSet forKey:kIsSettingsSet];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        DLog(@"Decoding ScrollingTallyDetailVC");
        if (!(_city = [[decoder decodeObjectForKey:kCity] retain])) {
            _city = kUnknownCity;
        }
        if (!(_country = [[decoder decodeObjectForKey:kCountry] retain])) {
            _country = kDefaultCountry;
        }
        if (!(_propertyName = [[decoder decodeObjectForKey:kPropertyName] retain])) {
            _propertyName = kDefaultPropertyName;
        }
        if (!(_pricePath = [[decoder decodeObjectForKey:kPricePath] retain])) {
            _pricePath = nil;
        }
        if (!(_lastNowValue = [[decoder decodeObjectForKey:kLastNowValue] retain])) {
            _lastNowValue = nil;
        }
        if (!(_isSettingsSet = [decoder decodeBoolForKey:kIsSettingsSet])) {
            _isSettingsSet = NO;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_settingsNotSetAlertView release];
    [_backgroundRect release];
    [_currentDateLbl release];
    [_currentValueLbl release];
    [_commentLbl release];
    [_scroller release];
    [_bottomToolbar release];
    [_infoButton release];
    [_statusLabel release];
    [_refreshButton release];
    [_waitingForDataIndicator release];

    [_autoUpdateTimer release];
    
    [_valueFormatter release];
    [_commentValueFormatter release];

    [_displayedValue release];
    [_nowValue release];
//    [_nowValueToEncode release];
    [_lastNowValue release];
    
    [_city release];
    [_country release];
    [_propertyName release];
    [_pricePath release];
    [_displayedData release];
    
    [super dealloc];
}

- (void)updateCurrentValueAuto {
    if (_scroller.isRotating) {
        DLog(@"Cannot update current value right now. Ignoring");
        return;
    }
    
    if (_isInitingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    NSDate *newDt = [_displayedValue.date addTimeInterval:60.0 / TH_AUTO_UPDATE_HZ];
    [self setDisplayedDateValueTo:newDt];
    //[self performSelectorOnMainThread:@selector(_setDisplayedDateValueTo:) withObject:newDt waitUntilDone:NO];
}

- (void)setDisplayedDateValueTo:(NSDate *)date {
    if (_isInitingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    self.displayedValue = [_displayedData calcValueAt:date];
    NSString *valueText = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:_displayedValue.val]];
    _currentValueLbl.text = valueText;
    _currentDateLbl.text = [_displayedValue.date fuzzyRelativeDateString];
    
    double diff = 0.0;
    NSString *comparator = nil;
    // if in future or past, then tell user how much more/less than now
    if (ABS([_displayedValue.date daysSince:_nowValue.date]) >= (365.0/2.0)) {
        diff = _displayedValue.val - _nowValue.val;
        comparator = @"now";
    }
    // otherwise, tell user change since last check in
    else {
        if (_lastNowValue) {
            diff = _displayedValue.val - _lastNowValue.val;
        }
        // else diff will be zero
        comparator = @"last check in";
    }
    
    NSString *diffStr = [_commentValueFormatter stringFromNumber:[NSNumber numberWithDouble:ABS(diff)]];

    if (diff != 0.0) {
        _commentLbl.text = [NSString stringWithFormat:@"%@ %@ than %@",
                            diffStr,
                            diff > 0.0 ? @"higher" : @"lower",
                            comparator];
    }
    else {
        _commentLbl.text = [NSString stringWithFormat:@"Same as %@", comparator];;
    }
}

//@protocol ScrollWheelDelegate <NSObject>

//@required

- (void)scrollWheel:(ScrollWheel *)sw didRotate:(NSInteger)years {   
    if (_isInitingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    DLog(@"scrolling %d years", years);
    [self setDisplayedDateValueTo:[_displayedValue.date addDays:years * 365]];
}
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw {
    if (_isInitingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    [self setDisplayedDateValueTo:[NSDate date]];
}

//@end


#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    if (_isInitingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return @"n/a";
    }
    
    THDateVal *latestVal = _nowValue;
    if (latestVal == nil && _pricePath != nil) {
        THTimeSeries *ts = _displayedData;
        if (!_displayedData)
            ts = [_pricePath makePricePath];
        latestVal = [ts calcValueAt:[NSDate date]];
    }
    
    if (latestVal) {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init]; 
        [nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
        [nf setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
        [nf setMaximumFractionDigits:0];

        return [nf stringFromNumber:[NSNumber numberWithDouble:latestVal.val]];
    }
    
    return @"n/a";
}
- (NSString *)rowTitle {
    return _propertyName;
}

- (void)editProperty {
    if (_isInitingPricePath || !_pricePath || !_displayedData) {
        DLog(@"Cannot do");
        return;
    }
    
    PropertySettingsVC *propSettings = [[PropertySettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
    propSettings.title = @"Settings";
    propSettings.delegate = self;
    propSettings.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    propSettings.location = _city;
    propSettings.propertyName = _propertyName;
    propSettings.buyPrice = _pricePath.buyPrice;
    propSettings.sources = _pricePath.sources;
    propSettings.proximities = _pricePath.proximities;
    propSettings.trendExtrapolationInterval = _displayedData.trendExtrapolationInterval;
    
    //[self.navigationController pushViewController:propSettings animated:YES];
    
    //following http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/ModalViewControllers/ModalViewControllers.html
    
    UINavigationController *navCtrlr = [[UINavigationController alloc]
                                                    initWithRootViewController:propSettings];
    [self presentModalViewController:navCtrlr animated:YES];
    
    [propSettings release];
    [navCtrlr release]; 
}

- (void)propertySettingsWillFinishDone:(PropertySettingsVC *)propSettings {
    _isSettingsSet = YES;
    _settingsNotSetAlertView.hidden = YES;
    
    [self dismissModalViewControllerAnimated:YES];
    
    self.propertyName = propSettings.propertyName;
    
    BOOL reInit = NO;
    BOOL reMakePP = NO;
    BOOL recalcCurrentVal = NO;
    if (![self.city isEqualToString:propSettings.location]) {
        self.city = propSettings.location;
        reInit = YES;
    }
    
    if (![propSettings.buyPrice isEqual:_pricePath.buyPrice]) {
        NSAssert(!_isInitingPricePath, @"cannot init price path and edit settings");
        _pricePath.buyPrice = propSettings.buyPrice;
        reMakePP = YES;
        recalcCurrentVal = NO; //will happen after thread finishes
    }
    
    if (propSettings.sources != _pricePath.sources) {
        _pricePath.sources = propSettings.sources;
        reMakePP = YES;
        recalcCurrentVal = YES;
    }
    
    if (propSettings.proximities != _pricePath.proximities) {
        _pricePath.proximities = propSettings.proximities;
        reMakePP = YES;
        recalcCurrentVal = YES;
    }
    
    if (propSettings.trendExtrapolationInterval != 
        _displayedData.trendExtrapolationInterval) {
        // no need to remake the price path... just change the current value
        recalcCurrentVal = YES;
        _displayedData.trendExtrapolationInterval = propSettings.trendExtrapolationInterval;
        
    }
    
    if (reInit) {
        _forceInitPricePath = YES;
        [self initPricePath];
    }
    else if (reMakePP) {
        self.displayedData = [_pricePath makePricePath];
        self.nowValue = [_displayedData calcValueAt:[NSDate date]];
    }
    
    if (recalcCurrentVal) {
        [self setDisplayedDateValueTo:[NSDate date]];
    }
}

- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)infoButtonTapped:(id)sender {
    if (_isInitingPricePath) {
        DLog(@"Cannot do");
        return;
    }
    
    InfoViewController *ivc = [[InfoViewController alloc] init];
    ivc.resourceFileName = @"InfoButtonText";
    ivc.delegate = self;
    
    UINavigationController *navCtrlr = [[UINavigationController alloc]
                                        initWithRootViewController:ivc];
    
    navCtrlr.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:navCtrlr animated:YES];
    
    [ivc release];
    [navCtrlr release];
}

- (void)infoViewControllerDidFinish:(InfoViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)refreshButtonTapped:(id)sender {
    [self initPricePath];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(editProperty)];          
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    //setup the bottom toolbar
    NSMutableArray *items = [[NSMutableArray alloc] init];
        
    UIBarButtonItem *rfBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    self.refreshButton = rfBtn;
    [items addObject:rfBtn];
    [rfBtn release];
        
    UILabel *updtLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, 200.0, 21.0f)];
    updtLbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    updtLbl.text = @"Updated.";
    updtLbl.backgroundColor = [UIColor clearColor];
    updtLbl.textColor = [UIColor whiteColor];
    updtLbl.textAlignment = UITextAlignmentLeft;
    self.statusLabel = updtLbl;
    UIBarButtonItem *updtLblBtn = [[UIBarButtonItem alloc] initWithCustomView:updtLbl];
    [items addObject:updtLblBtn];
    [updtLbl release];
    [updtLblBtn release];
    
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:spacer2];
    [spacer2 release];
    
    UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(infoButtonTapped:)];
    self.infoButton = infoBtn;
    [items addObject:infoBtn];
    [infoBtn release];

    [self.bottomToolbar setItems:items animated:NO];
    [items release];
    
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.waitingForDataIndicator = ai;
    [ai release];
        
    _scroller.fullCircleScale = 20.0;
    _scroller.stepScale = 1.0;
    _scroller.delegate = self;

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init]; 
    [nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setRoundingIncrement:[[NSNumber alloc] initWithDouble:0.01]];
    self.valueFormatter = nf;
    
    nf = [[NSNumberFormatter alloc] init]; 
    [nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
    [nf setMaximumFractionDigits:0];
    self.commentValueFormatter = nf;
    
    _backgroundRect.backgroundColor = [UIColor colorWithRed:10.0/255.0 
                                                      green:68.0/255.0 
                                                       blue:151.0/255.0 
                                                      alpha:1.0];
    _backgroundRect.layer.cornerRadius = 5.0;
    
    _settingsNotSetAlertView.hidden = _isSettingsSet;
    
    [self initPricePath];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setDisplayedDateValueTo:[NSDate date]];
    
    self.title = _propertyName;
    _autoUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 / TH_AUTO_UPDATE_HZ 
                                                         target:self
                                                       selector:@selector(updateCurrentValueAuto) 
                                                       userInfo:nil 
                                                        repeats:YES] retain];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_autoUpdateTimer invalidate];
    [_autoUpdateTimer release];
    _autoUpdateTimer = nil;
    
    //    _nowValueToEncode = [_nowValue retain];
    //    [_nowValue release];

}

- (void)viewDidUnload {
    [self setSettingsNotSetAlertView:nil];
    [self setStatusLabel:nil];
    [self setBottomToolbar:nil];
    
    self.scroller = nil;
    self.infoButton = nil;
    self.refreshButton = nil;
    self.waitingForDataIndicator = nil;
    self.backgroundRect = nil;
    self.currentValueLabel = nil;
    self.currentDateLabel = nil;
    self.commentLabel = nil;
    
    [super viewDidUnload];
    
}

- (void)initPricePath {   
    NSMutableArray *items = [_bottomToolbar.items mutableCopy];
    [items removeObjectAtIndex:0];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithCustomView:_waitingForDataIndicator];
    self.refreshButton = bbi;
    [items insertObject:bbi atIndex:0];
    [bbi release];
    
    [_bottomToolbar setItems:items animated:NO];
    [items release];
    
    [_waitingForDataIndicator startAnimating];
    //self.buyPriceLocalCopy = bp;
    [self performSelectorInBackground:@selector(initPricePathWorker) withObject:nil];
}

- (void)initPricePathWorker {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _isInitingPricePath = YES;
    
    THDateVal *oldBP = nil;
    int sources = 0;
    int proxs = 0;
    NSTimeInterval fcTI = 0;
    BOOL wasOldPP = (_pricePath != nil);
    if (wasOldPP) {
        oldBP = [_pricePath.buyPrice copy];
        sources = _pricePath.sources;
        proxs = _pricePath.proximities;
    }
    BOOL wasOldDD = (_displayedData != nil);
    if (wasOldDD) {
        fcTI = _displayedData.trendExtrapolationInterval;
    }
    
    NSString *update = @"Getting data from server...";
    [self performSelectorOnMainThread:@selector(updateStatusLabel:) withObject:update waitUntilDone:NO];
#ifdef DEBUG
    _forceInitPricePath = YES;
#endif
    if (_forceInitPricePath ||
        !_pricePath ||
        _pricePath.innerSerieses.count == 0 ||
        !_pricePath.lastServerUpdate ||
        ABS([_pricePath.lastServerUpdate timeIntervalSinceNow]) > TH_OneDayInSecs * 30.0) {
        
        THAppDelegate *appD = (THAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (! TH_CHECK_REACHABILITY || 
            [appD.serverReachability isReachable]) {
            DLog(@"reinitializing _pricePath");
            THURLCreator *urlCreator = [[THURLCreator alloc] init];
            urlCreator.tallyId = @"HousePriceIx";
            urlCreator.city = _city;
            urlCreator.country = _country;
            urlCreator.userId = [appD getUUID];
                        
            THHomePricePath *newPP = [[THHomePricePath alloc] initWithURL:[urlCreator makeURL]];
            if (wasOldPP) {
                newPP.buyPrice = oldBP;
                newPP.sources = sources;
                newPP.proximities = proxs;
            }
            self.pricePath = newPP;
            [newPP release];
            [urlCreator release];
        }
        else {
            //if we don't have any price path, then just use a generic Australian PP
            //from file and tell the user
            NSString *msg = @"";
            if (!_pricePath ||
                _pricePath.innerSerieses.count == 0) {
                msg = @"Cannot contact TallyHome server. TallyHome will use a generic Australian price index that may not reflect your locality.\n\nPlease use the refresh button on lower right when next you have internet access";
                
                NSString *file = [appD.appDefaults objectForKey:@"genericOzIndex"];
                NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:file];    
                NSString *xml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                THHomePricePath *ozPP = [[THHomePricePath alloc] initWithXmlString:xml];
                self.pricePath = ozPP;
                [ozPP release];
            }
            //if the only issue is an old price path, then just tell the user
            else {
                msg = @"Cannot contact TallyHome server to update the current price index.\n\nPlease use the refresh button on lower right when next you have internet access";
            }
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle:@"Network connection error"
                                  message:msg
                                  delegate:nil 
                                  cancelButtonTitle:@"OK" 
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        _forceInitPricePath = NO;
    }
    
    update = @"Calculating price index...";
    [self performSelectorOnMainThread:@selector(updateStatusLabel:) withObject:update waitUntilDone:NO];
    DLog(@"making price path...");
    self.displayedData = [_pricePath makePricePath];
    if (wasOldDD) {
        _displayedData.trendExtrapolationInterval = fcTI;
    }
    
    DLog(@"calculating now value...");
    self.nowValue = [_displayedData calcValueAt:[NSDate date]];
    
    _isInitingPricePath = NO;
    
    DLog(@"finsihing init...");
    [self performSelectorOnMainThread:@selector(setDisplayedDateValueTo:) 
                           withObject:[NSDate date] 
                        waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(finishInitializingOnMainThread) 
                           withObject:nil 
                        waitUntilDone:NO];
    
    DLog(@"releasing pool");
    [pool release];
}

- (void)finishInitializingOnMainThread {
    NSMutableArray *items = [_bottomToolbar.items mutableCopy];
    [items removeObjectAtIndex:0];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    self.refreshButton = bbi;
    [items insertObject:bbi atIndex:0];
    [bbi release];
    
    [_bottomToolbar setItems:items animated:NO];
    [items release];
    
    [_waitingForDataIndicator stopAnimating];
    [self updateStatusLabel:@"Updated."];
}

- (void)updateStatusLabel:(NSString *)newText {
    _statusLabel.text = newText;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
