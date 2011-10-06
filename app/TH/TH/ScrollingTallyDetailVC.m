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

//#define kUnknownCity @"Unknown"

#define kDefaultCountry @"Australia"
#define kDefaultLocation [[THPlaceName alloc] initWithCity:@"" state:@"" country:kDefaultCountry]
#define kDefaultPropertyName @"Average house"
#define TH_AUTO_UPDATE_HZ 60.0
//#define MAX_TIMEINTERVAL_UNTIL_SERVER_UPDATE 30*24*60*60
#define kServerUpdateAlert  @"Getting data from server..."
#define kCalcPriceIxAlert   @"Calculating price index..."
#define kUpdatedAlert       @"Updated."
#define kRefreshingAlert    @"     Refreshing. Please wait...     "

@interface ScrollingTallyDetailVC ()

@property (nonatomic, retain, readwrite) THTimeSeries *displayedData;
@property (nonatomic, retain) NSNumberFormatter *valueFormatter;
@property (nonatomic, retain) NSNumberFormatter *commentValueFormatter;

@property (nonatomic, retain) NSString *updateWorkerErrorMessage;

- (void)initPricePath;
- (void)updatePricePath;
- (void)updatePricePathWorker;
- (void)editProperty;
- (void)setDisplayedDateValueTo:(NSDate *)date;
- (void)updateStatusLabel:(NSString *)newText;

- (void)infoButtonTapped:(id)sender;
- (void)refreshButtonTapped:(id)sender;

@end

@implementation ScrollingTallyDetailVC

@synthesize helpStepOneView = _helpStepOneView;
@synthesize helpStepTwoView = _helpStepTwoView;
@synthesize helpStepThreeView = _helpStepThreeView;
@synthesize statusLabel = _statusLabel;
@synthesize infoButton = _infoButton;
@synthesize refreshButton = _refreshButton;
@synthesize waitingForDataIndicator = _waitingForDataIndicator;
@synthesize bottomToolbar = _bottomToolbar;
@synthesize propertyName = _propertyName;
@synthesize pricePath = _pricePath;
@synthesize location = _locationName;
@synthesize displayedData = _displayedData;
@synthesize currentValueLabel = _currentValueLbl;
@synthesize currentValueRefreshingLabel = _currentValueRefreshingLbl;
@synthesize scroller = _scroller;
@synthesize displayedValue = _displayedValue;
@synthesize nowValue = _nowValue;
@synthesize nowValueToEncode = _nowValueToEncode;
@synthesize currentDateLabel = _currentDateLbl;
@synthesize commentLabel = _commentLbl;
@synthesize backgroundRect = _backgroundRect;
@synthesize valueFormatter = _valueFormatter;
@synthesize commentValueFormatter = _commentValueFormatter;
@synthesize updateWorkerErrorMessage = _updateWorkerErrorMessage;

- (id)init {
    return [self initWithNibName:@"ScrollingTallyDetailVC" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _locationName = kDefaultLocation;
        _propertyName = kDefaultPropertyName;

        _decodedOrDefaultTrendInterval = TH_FiveYearTimeInterval;
    }
    return self;
}

#pragma mark NSCoding

#define kVerNoCoding    @"VerNo"
#define kLocation       @"Location"
#define kPropertyName   @"PropName"
#define kPricePath      @"PricePath"
#define kTrendInterval  @"TrendInterval"
#define kLastNowValue   @"LastNowValue"
#define kIsSettingsSet  @"IsSettingsSet"
#define kIsHelpStepOneDone  @"IsHelpStepOneDone"
#define kIsHelpStepTwoDone  @"IsHelpStepTwoDone"
#define kIsHelpStepThreeDone  @"IsHelpStepThreeDone"



- (void)encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding ScrollingTallyDetailVC");
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    [encoder encodeObject:_locationName forKey:kLocation];
    [encoder encodeObject:_propertyName forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
    [encoder encodeBool:_isHelpStepOneDone forKey:kIsHelpStepOneDone];
    [encoder encodeBool:_isHelpStepTwoDone forKey:kIsHelpStepTwoDone];
    [encoder encodeBool:_isHelpStepThreeDone forKey:kIsHelpStepThreeDone];
    
    [encoder encodeDouble:_displayedData.trendExtrapolationInterval forKey:kTrendInterval];
    
    //only encode a now value that was actually shown, otherwise just
    //encode the last now value
    if (_nowValueToEncode)
        [encoder encodeObject:_nowValueToEncode forKey:kLastNowValue];
    else
        [encoder encodeObject:_lastNowValue forKey:kLastNowValue];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        DLog(@"Decoding ScrollingTallyDetailVC");
        if (!(_locationName = [[decoder decodeObjectForKey:kLocation] retain])) {
            _propertyName = kDefaultLocation;
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
        if (!(_isHelpStepOneDone = [decoder decodeBoolForKey:kIsHelpStepOneDone])) {
            _isHelpStepOneDone = NO;
        }
        if (!(_isHelpStepTwoDone = [decoder decodeBoolForKey:kIsHelpStepTwoDone])) {
            _isHelpStepTwoDone = NO;
        }
        if (!(_isHelpStepThreeDone = [decoder decodeBoolForKey:kIsHelpStepThreeDone])) {
            _isHelpStepThreeDone = NO;
        }
        if (!(_decodedOrDefaultTrendInterval = [decoder decodeDoubleForKey:kTrendInterval])) {
            _decodedOrDefaultTrendInterval = TH_FiveYearTimeInterval;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_helpStepOneView release];
    [_helpStepTwoView release];
    [_helpStepThreeView release];
    [_backgroundRect release];
    [_currentDateLbl release];
    [_currentValueLbl release];
    [_currentValueRefreshingLbl release];
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
    [_nowValueToEncode release];
    [_lastNowValue release];
    
    [_locationName release];
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
    
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    NSDate *newDt = [_displayedValue.date addTimeInterval:60.0 / TH_AUTO_UPDATE_HZ];
    [self setDisplayedDateValueTo:newDt];
    //[self performSelectorOnMainThread:@selector(_setDisplayedDateValueTo:) withObject:newDt waitUntilDone:NO];
}

- (void)setDisplayedDateValueTo:(NSDate *)date {
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    _currentValueRefreshingLbl.hidden = YES;
    _currentValueLbl.hidden = NO;
    self.displayedValue = [_displayedData calcValueAt:date];
//    NSString *valueText = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:_displayedValue.val]];
//    _currentValueRefreshingLbl.text = valueText;
    _currentValueLbl.value = _displayedValue.val;
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

#pragma ScrollWheelDelegate

//@required

- (void)scrollWheel:(ScrollWheel *)sw didRotate:(NSInteger)years {   
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    _isHelpStepTwoDone = YES;
    _helpStepTwoView.hidden = YES;
    
    DLog(@"scrolling %d years", years);
    [self setDisplayedDateValueTo:[_displayedValue.date addDays:years * 365]];
}
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw {
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    _isHelpStepThreeDone = YES;
    _helpStepThreeView.hidden = YES;
    
    [self setDisplayedDateValueTo:[NSDate date]];
}

//@optional
- (void)scrollWheelRightTap:(ScrollWheel *)sw {
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    _isHelpStepTwoDone = YES;
    _helpStepTwoView.hidden = YES;
    
    [self setDisplayedDateValueTo:[_displayedValue.date addDays:365]];
}

- (void)scrollWheelLeftTap:(ScrollWheel *)sw {
    if (_isUpdatingPricePath) {
        DLog(@"Cannot use price path data. Ignoring");
        return;
    }
    
    _isHelpStepTwoDone = YES;
    _helpStepTwoView.hidden = YES;
    
    [self setDisplayedDateValueTo:[_displayedValue.date addDays:-365]];
}

//@end


#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    if (_isUpdatingPricePath) {
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
    if (_isUpdatingPricePath || !_pricePath || !_displayedData) {
        DLog(@"Cannot do");
        return;
    }
    
    PropertySettingsVC *propSettings = [[PropertySettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
    propSettings.title = @"Settings";
    propSettings.delegate = self;
    propSettings.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    propSettings.location = _locationName;
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
    
    _isHelpStepOneDone = YES;
    _helpStepOneView.hidden = YES;
    
    self.propertyName = propSettings.propertyName;

    [self dismissModalViewControllerAnimated:YES];
    
    BOOL reInit = NO;
    BOOL reMakePP = NO;
    BOOL recalcCurrentVal = NO;
    if (![self.location isEqual:propSettings.location]) {
        self.location = propSettings.location;
        reInit = YES;
    }
    
    if (![propSettings.buyPrice isEqual:_pricePath.buyPrice]) {
        NSAssert(!_isUpdatingPricePath, @"cannot init price path and edit settings");
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
        [self updatePricePath];
    }
    else if (reMakePP) {
        [self updateStatusLabel:kCalcPriceIxAlert];
        self.displayedData = [_pricePath makePricePath];
        self.nowValue = [_displayedData calcValueAt:[NSDate date]];
        [self updateStatusLabel:kUpdatedAlert];
    }
    
    if (recalcCurrentVal) {
        [self setDisplayedDateValueTo:[NSDate date]];
    }
}

- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)infoButtonTapped:(id)sender {
    if (_isUpdatingPricePath) {
        DLog(@"Cannot do");
        return;
    }
    
    THAppDelegate *appD = [[UIApplication sharedApplication] delegate];
    NSString *urlStr = [appD.appDefaults objectForKey:@"infoURL"];
    
    InfoViewController *ivc = [[InfoViewController alloc] init];
    ivc.resource = [NSURL URLWithString:urlStr];
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
    [self updatePricePath];
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
    [nf release];
    
    nf = [[NSNumberFormatter alloc] init]; 
    [nf setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [nf setNumberStyle:NSNumberFormatterCurrencyStyle];
    [nf setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
    [nf setMaximumFractionDigits:0];
    self.commentValueFormatter = nf;
    [nf release];
    
    _backgroundRect.backgroundColor = [UIColor colorWithRed:10.0/255.0 
                                                      green:68.0/255.0 
                                                       blue:151.0/255.0 
                                                      alpha:1.0];
    _backgroundRect.layer.cornerRadius = 5.0;
    
#ifdef DEBUG__avoidForNow
    _helpStepOneView.hidden = NO;
    _helpStepTwoView.hidden = NO;
    _helpStepThreeView.hidden = NO;
#else
    _helpStepOneView.hidden = _isHelpStepOneDone;
    _helpStepTwoView.hidden = _isHelpStepTwoDone;
    _helpStepThreeView.hidden = _isHelpStepThreeDone;
#endif
    
    if (!_pricePath) {
        [self initPricePath];
    }
    else  if (_pricePath.innerSerieses.count == 0 ||
              !_pricePath.lastServerUpdate ||
              ABS([_pricePath.lastServerUpdate timeIntervalSinceNow]) > TH_OneDayInSecs * 30.0) {
        [self updatePricePath];
    }
    else {
        self.displayedData = [_pricePath makePricePath];
        self.nowValue = [_displayedData calcValueAt:[NSDate date]]; 
    }
    
    _displayedData.trendExtrapolationInterval = _decodedOrDefaultTrendInterval;
    
#ifdef DEBUG
    //wait for reachability to become available
    //[self updatePricePath];
#endif

}

//when app comes back from background, viewWillAppear is not called
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self setDisplayedDateValueTo:[NSDate date]];
    self.nowValueToEncode = _nowValue;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setDisplayedDateValueTo:[NSDate date]];
    
    self.title = _propertyName;
    _autoUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 / TH_AUTO_UPDATE_HZ 
                                                         target:self
                                                       selector:@selector(updateCurrentValueAuto) 
                                                       userInfo:nil 
                                                        repeats:YES] retain];
    
    //only encode the new now value if it was actually shown
    self.nowValueToEncode = _nowValue;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_autoUpdateTimer invalidate];
    [_autoUpdateTimer release];
    _autoUpdateTimer = nil;
    
}

- (void)viewDidUnload {
    [self setHelpStepOneView:nil];
    [self setHelpStepTwoView:nil];
    [self setHelpStepThreeView:nil];
    [self setStatusLabel:nil];
    [self setBottomToolbar:nil];
    
    self.scroller = nil;
    self.infoButton = nil;
    self.refreshButton = nil;
    self.waitingForDataIndicator = nil;
    self.backgroundRect = nil;
    self.currentValueLabel = nil;
    self.currentValueRefreshingLabel = nil;
    self.currentDateLabel = nil;
    self.commentLabel = nil;
    
    [super viewDidUnload];
    
}

#pragma Price Path init and update

- (void)initPricePath {
    //longer term want to put in files for all major markets (US, UK, Japan etc)
    
    THAppDelegate *appD = (THAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *file = [appD.appDefaults objectForKey:@"genericOzIndexFile"];
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:file];    
    //NSString *xml = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    THHomePricePath *ozPP = [[THHomePricePath alloc] initWithURL:url];
    
    ozPP.sources = THHomePriceIndexSourceGovt | THHomePriceIndexSourceBranded;
    ozPP.proximities = THHomePriceIndexProximityCountry;
    
    self.pricePath = ozPP;
    [ozPP release];
    
    self.displayedData = [_pricePath makePricePath];
    self.nowValue = [_displayedData calcValueAt:[NSDate date]];
}

- (void)updatePricePath {   
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
    
    _currentValueRefreshingLbl.text = kRefreshingAlert;
    _currentValueRefreshingLbl.hidden = NO;
    _currentValueLbl.hidden = YES;
    
    [self performSelectorInBackground:@selector(updatePricePathWorker) withObject:nil];
}



- (void)updatePricePathWorker {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    _isUpdatingPricePath = YES;
    
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
    
    [self performSelectorOnMainThread:@selector(updateStatusLabel:) withObject:kServerUpdateAlert waitUntilDone:NO];
    
    THAppDelegate *appD = (THAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (! TH_CHECK_REACHABILITY || 
        [appD.serverReachability isReachable]) {
        DLog(@"reinitializing _pricePath");
        THURLCreator *urlCreator = [[THURLCreator alloc] init];
        urlCreator.tallyId = @"HousePriceIx";
        urlCreator.location = _locationName;
        urlCreator.userId = [appD getUUID];
                    
        THHomePricePath *newPP = [[THHomePricePath alloc] initWithURL:[urlCreator makeURL]];
        if (newPP.innerSerieses.count > 0) {
            THHomePriceIndex *bestIx = [newPP calcBestIndex];
            newPP.sources = [bestIx src];
            newPP.proximities = [bestIx prox];
            
            if (wasOldPP) {
                newPP.buyPrice = oldBP;
                
                //TODO: need to find a better way to combine any existing prefs
                //with a potentially limited set of updated sources
                //eg. what if user has specified city, but the indices only have
                //a country index in the set??
                //newPP.sources |= sources;
                //newPP.proximities |= proxs;
                self.pricePath = newPP;
            }
        }
        else {
            self.updateWorkerErrorMessage = 
                [NSString stringWithFormat:@"Tally Home does not have any data for the '%@', '%@' in '%@'\n\nPlease try again", _locationName.city, _locationName.state, _locationName.country];
        }
        
        [newPP release];
        [urlCreator release];
    }
    else {
        self.updateWorkerErrorMessage = @"Cannot contact TallyHome server to update the current price index.\n\nPlease use the refresh button on lower left when next you have internet access";
    }
    
    [self performSelectorOnMainThread:@selector(updateStatusLabel:) withObject:kCalcPriceIxAlert waitUntilDone:NO];
    DLog(@"making price path...");
    self.displayedData = [_pricePath makePricePath];
    if (wasOldDD) {
        _displayedData.trendExtrapolationInterval = fcTI;
    }
    
    DLog(@"calculating now value...");
    self.nowValue = [_displayedData calcValueAt:[NSDate date]];
    self.nowValueToEncode = _nowValue;
    
    _isUpdatingPricePath = NO;
    
    DLog(@"finsihing init...");
    [self performSelectorOnMainThread:@selector(setDisplayedDateValueTo:) 
                           withObject:[NSDate date] 
                        waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(finishUpdatingOnMainThread) 
                           withObject:nil 
                        waitUntilDone:NO];
    
    DLog(@"releasing pool");
    [pool release];
}

- (void)finishUpdatingOnMainThread {
    if (_updateWorkerErrorMessage != nil) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error"
                              message:_updateWorkerErrorMessage
                              delegate:nil 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        self.updateWorkerErrorMessage = nil;
        _currentValueRefreshingLbl.text = @"Not available";
    }
    else {
        _currentValueRefreshingLbl.hidden = YES;
        _currentValueLbl.hidden = NO;
    }
    
    NSMutableArray *items = [_bottomToolbar.items mutableCopy];
    [items removeObjectAtIndex:0];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped:)];
    self.refreshButton = bbi;
    [items insertObject:bbi atIndex:0];
    [bbi release];
    
    [_bottomToolbar setItems:items animated:NO];
    [items release];
    
    [_waitingForDataIndicator stopAnimating];
    [self updateStatusLabel:kUpdatedAlert];
}

- (void)updateStatusLabel:(NSString *)newText {
    _statusLabel.text = newText;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
