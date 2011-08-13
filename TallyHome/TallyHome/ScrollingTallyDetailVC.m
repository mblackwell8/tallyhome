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

@interface ScrollingTallyDetailVC ()

@property (nonatomic, retain, readwrite) THTimeSeries *displayedData;
@end

@implementation ScrollingTallyDetailVC
@synthesize customizeAlertImage = _customizeAlertImage;
@synthesize scrollView = _scrollView;
@synthesize propertyName = _propertyName, pricePath = _pricePath, 
        location = _location, waitingForDataIndicator = _waitingForDataIndicator, displayedData = _displayedData;



- (id)init {
    if ((self = [self initWithNibName:@"ScrollingTallyDetailVC" bundle:nil])) {
        
    }
    
    return self;
}

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
    [_scrollView release];
    [_waitingForDataIndicator release];
    [super dealloc];
}

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

- (TallyViewCell *)tallyView:(TallyView *)tallyView cellForRowAtIndex:(NSInteger)ix {
    
    //make an arbitrary height, so that construction works
    TallyViewCell *cell = [[TallyViewCell alloc] initWithFrame:CGRectMake(0, 0, tallyView.frame.size.width, tallyView.frame.size.height / 7.0)];
    
    return [cell autorelease];
}

- (void)tallyView:(TallyView *)tallyView willAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor {

}

- (void)tallyView:(TallyView *)tallyView didAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor {
    
}

- (void)tallyView:(TallyView *)tallyView willShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx {
    
}

- (void)tallyView:(TallyView *)tallyView didShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx {
//    if (fromIx == toIx) {
//        DLog(@"ERROR: fromIx == toIx == %d", fromIx);
//        return;
//    }
//    
//    // reformat the incoming middle label
//    TallyViewCell *middleLbl = [_scrollView.cells objectAtIndex:3];
//    middleLbl.valueLabel = [middleValueLblFormatter stringFromNumber:[NSNumber numberWithDouble:middleLbl.data.val]]; 
//    [middleLbl setNeedsDisplay];
//    
//    // reformat the outgoing middle label
//    TallyViewCell *oldMiddleLbl = nil;
//    if (fromIx < toIx) {
//        //moving up, so old middle label is now at position 2
//        oldMiddleLbl = [_scrollView.cells objectAtIndex:2];
//    }
//    else {
//        oldMiddleLbl = [_scrollView.cells objectAtIndex:4];
//    }
//    oldMiddleLbl.valueLabel = [normalValueLblFormatter stringFromNumber:[NSNumber numberWithDouble:oldMiddleLbl.data.val]]; 
//    [oldMiddleLbl setNeedsDisplay];
    
}

- (void)tallyView:(TallyView *)tallyView dataForCell:(TallyViewCell *)cell atIndexPosition:(NSInteger)ix {
    NSInteger yearsAhead = tallyView.scrollPosition + (3 - ix);
    THDateVal *data = [_displayedData calcValueAt:[[NSDate date] addDays:(yearsAhead * 365)]];
    cell.data = data;
    [cell setNeedsDisplay];
}

//- (void)_applyData:(THDateVal *)data toTallyViewCell:(TallyViewCell *)cell atIndex:(NSInteger)ix {
//    
//    cell.dateLabel = [data.date fuzzyRelativeDateString];
//    
//    if (ix == 3)
//        cell.valueLabel = [middleValueLblFormatter stringFromNumber:[NSNumber numberWithDouble:data.val]];
//    else
//        cell.valueLabel = [normalValueLblFormatter stringFromNumber:[NSNumber numberWithDouble:data.val]];
//    
//    cell.commentLabel = @"TODO: Change label";
//    cell.data = data;
//
//    [cell setNeedsDisplay];
//}

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
    _scrollView.delegate = self;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(_editProperty)];          
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    if (!_pricePath) {
        DLog(@"_pricePath nil, initializing");
        [self _initPricePath];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"making price path...");
    self.displayedData = [_pricePath makePricePath];
    [_scrollView reloadData];
}

- (void)_initPricePath {
    THURLCreator *urlCreator = [[THURLCreator alloc] init];
    self.pricePath = [[THHomePricePath alloc] initWithURL:[urlCreator makeURL]];
    [urlCreator release];
}

- (void)viewDidUnload {
    [self setCustomizeAlertImage:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}     
     

@end
