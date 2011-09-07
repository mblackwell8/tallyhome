//
//  ScrollingTallyDetailVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollingTallyDetailVC.h"
#import "DebugMacros.h"


#define kUnknownLocation @"Unknown"
#define TH_AUTO_UPDATE_HZ 60.0

@interface ScrollingTallyDetailVC ()

@property (nonatomic, retain, readwrite) THTimeSeries *displayedData;
@end

@implementation ScrollingTallyDetailVC
@synthesize customizeAlertImage = _customizeAlertImage;
@synthesize propertyName = _propertyName, pricePath = _pricePath, 
        location = _location, waitingForDataIndicator = _waitingForDataIndicator, displayedData = _displayedData, currentValueLabel = _currentValueLbl, scroller = _scroller, currentValue = _displayedValue, currentDateLabel = _currentDateLbl, commentLabel = _commentLbl, activityIndicator = _activityIndicator, backgroundRect = _backgroundRect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //HACK: these are released... problematic?
        _location = kUnknownLocation;
        _propertyName = kUnknownLocation;

    }
    return self;
}

#pragma mark NSCoding

#define kVerNoCoding    @"VerNo"
#define kLocation       @"Location"
#define kPropertyName   @"PropName"
#define kPricePath      @"PricePath"
#define kLastNowValue   @"LastNowValue"


- (void) encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding ScrollingTallyDetailVC");
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    [encoder encodeObject:_location forKey:kLocation];
    [encoder encodeObject:_propertyName forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
    [encoder encodeObject:_nowValueToEncode forKey:kLastNowValue];
    [_nowValueToEncode release];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        DLog(@"Decoding ScrollingTallyDetailVC");
        if (!(_location = [[decoder decodeObjectForKey:kLocation] retain])) {
            _location = kUnknownLocation;
        }
        if (!(_propertyName = [[decoder decodeObjectForKey:kPropertyName] retain])) {
            _propertyName = kUnknownLocation;
        }
        if (!(_pricePath = [[decoder decodeObjectForKey:kPricePath] retain])) {
            _pricePath = nil;
        }
        if (!(_lastNowValue = [[decoder decodeObjectForKey:kLastNowValue] retain])) {
            _lastNowValue = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_location release];
    [_propertyName release];
    [_pricePath release];
    [_displayedData release];
    [_lastNowValue release];
    
    [_customizeAlertImage release];
    [_waitingForDataIndicator release];
    
    [_valueFormatter release];
    [_commentValueFormatter release];
    
    [_scroller release];
    [_currentValueLbl release];
    [_displayedValue release];
    [super dealloc];
}

- (void)_updateCurrentValueAuto {
    if (_scroller.isRotating)
        return;
    
    NSDate *newDt = [_displayedValue.date addTimeInterval:60.0 / TH_AUTO_UPDATE_HZ];
    [self performSelectorOnMainThread:@selector(_setDisplayedDateValueTo:) withObject:newDt waitUntilDone:NO];
}

- (void)_setDisplayedDateValueTo:(NSDate *)date {
    self.currentValue = [_displayedData calcValueAt:date];
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
//    // if in past, then tell user change vs purch date
//    else if ([_currentValue.date daysUntil:_nowValue.date] >= 365) {
//        diff = _currentValue.val - _pricePath.buyPrice.val;
//        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit 
//                                                                       fromDate:_pricePath.buyPrice.date];
//        comparator = [NSString stringWithFormat:@"%d", [components year]];
//    }
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
    DLog(@"scrolling %d years", years);
    [self _setDisplayedDateValueTo:[_displayedValue.date addDays:years * 365]];
}
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw {
    [self _setDisplayedDateValueTo:[NSDate date]];
}

//@end


#pragma mark TallyDetailVC

- (NSString *)rowLatestData {
    if (_pricePath) {
        THTimeSeries *ts = [_pricePath makePricePath];
        THDateVal *latestVal = [ts calcValueAt:[NSDate date]];
        
        return [NSString stringWithFormat:@"%.2f", latestVal.val];
    }
    
    return @"???";
}
- (NSString *)rowTitle {
    return _propertyName;
}

- (void)_editProperty {
    //TODO: _autoUpdateTimer stop or pause somehow??
    
    PropertySettingsVC *propSettings = [[PropertySettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
    propSettings.delegate = self;
    propSettings.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    propSettings.location = _location;
    propSettings.propertyName = _propertyName;
    propSettings.buyPrice = _pricePath.buyPrice;
    
    //[self.navigationController pushViewController:propSettings animated:YES];
    
    //following http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/ModalViewControllers/ModalViewControllers.html
    
    UINavigationController *navCtrlr = [[UINavigationController alloc]
                                                    initWithRootViewController:propSettings];
    [self presentModalViewController:navCtrlr animated:YES];
    
    [propSettings release];
    [navCtrlr release]; 
}

- (void)propertySettingsWillFinishDone:(PropertySettingsVC *)propSettings {
    self.location = propSettings.location;
    self.propertyName = propSettings.propertyName;
    _pricePath.buyPrice = propSettings.buyPrice;
    
    [self dismissModalViewControllerAnimated:YES];
}
- (void)propertySettingsWillFinishCancelled:(PropertySettingsVC *)propSettings {
    [self dismissModalViewControllerAnimated:YES];
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
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(_editProperty)];          
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    _scroller.fullCircleScale = 20.0;
    _scroller.stepScale = 1.0;
    _scroller.delegate = self;

    _valueFormatter = [[NSNumberFormatter alloc] init]; 
    [_valueFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_valueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_valueFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:0.01]];
    [_valueFormatter retain];
    
    _commentValueFormatter = [[NSNumberFormatter alloc] init]; 
    [_commentValueFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_commentValueFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [_commentValueFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:1.0]];
    [_commentValueFormatter setMaximumFractionDigits:0];
    [_commentValueFormatter retain];

    
    _backgroundRect.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:151.0/255.0 alpha:1.0];
    _backgroundRect.layer.cornerRadius = 5.0;
    
    if (!_pricePath) {
        DLog(@"_pricePath nil, initializing");
        [self _initPricePath];
    }
    
    DLog(@"making price path...");
    self.displayedData = [_pricePath makePricePath];
    _nowValue = [[_displayedData calcValueAt:[NSDate date]] copy];
}

- (void)viewWillAppear:(BOOL)animated {
    [self _setDisplayedDateValueTo:[NSDate date]];
    
    self.title = _propertyName;
    
    _autoUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 / TH_AUTO_UPDATE_HZ 
                                                         target:self
                                                       selector:@selector(_updateCurrentValueAuto) 
                                                       userInfo:nil 
                                                        repeats:YES] retain];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_autoUpdateTimer invalidate];
    [_autoUpdateTimer release];
    _autoUpdateTimer = nil;
    
    
}

- (void)_initPricePath {
    THURLCreator *urlCreator = [[THURLCreator alloc] init];
    self.pricePath = [[THHomePricePath alloc] initWithURL:[urlCreator makeURL]];
    [urlCreator release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.customizeAlertImage = nil;
//    self.scrollView = nil;
    
    _nowValueToEncode = [_nowValue retain];
    [_nowValue release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
