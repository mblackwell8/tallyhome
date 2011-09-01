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
        location = _location, waitingForDataIndicator = _waitingForDataIndicator, displayedData = _displayedData, currentValueLabel = _currentValueLbl, scroller = _scroller, currentValue = _currentValue, currentDateLabel = _currentDateLbl, commentLabel = _commentLbl, activityIndicator = _activityIndicator, backgroundRect = _backgroundRect;

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


- (void) encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding ScrollingTallyDetailVC");
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    [encoder encodeObject:_location forKey:kLocation];
    [encoder encodeObject:_propertyName forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
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
    }
    
    return self;
}

- (void)dealloc {
    [_location release];
    [_propertyName release];
    [_pricePath release];
    [_displayedData release];
    
    [_customizeAlertImage release];
    [_waitingForDataIndicator release];
    
    [_valueFormatter release];
    
    [_scroller release];
    [_currentValueLbl release];
    [_currentValue release];
    [super dealloc];
}

- (void)_updateCurrentValueAuto {
    if (_scroller.isRotating)
        return;
    
    NSDate *newDt = [_currentValue.date addTimeInterval:60.0 / TH_AUTO_UPDATE_HZ];
    [self performSelectorOnMainThread:@selector(_setCurrentValueTo:) withObject:newDt waitUntilDone:NO];
}

- (void)_setCurrentValueTo:(NSDate *)date {
    self.currentValue = [_displayedData calcValueAt:date];
    NSString *valueText = [_valueFormatter stringFromNumber:[NSNumber numberWithDouble:_currentValue.val]];
    _currentValueLbl.text = valueText;
    _currentDateLbl.text = [_currentValue.date fuzzyRelativeDateString];
    
}

//@protocol ScrollWheelDelegate <NSObject>

//@required


- (void)scrollWheel:(ScrollWheel *)sw didRotate:(NSInteger)years {   
    DLog(@"scrolling %d years", years);
    [self _setCurrentValueTo:[_currentValue.date addDays:years * 365]];
}
- (void)scrollWheelButtonPressed:(ScrollWheel *)sw {
    [self _setCurrentValueTo:[NSDate date]];
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
    
    _backgroundRect.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:68.0/255.0 blue:151.0/255.0 alpha:1.0];
    _backgroundRect.layer.cornerRadius = 5.0;
    
    if (!_pricePath) {
        DLog(@"_pricePath nil, initializing");
        [self _initPricePath];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"making price path...");
    self.displayedData = [_pricePath makePricePath];    
    [self _setCurrentValueTo:[NSDate date]];
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
