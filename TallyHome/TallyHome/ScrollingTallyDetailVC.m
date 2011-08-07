//
//  ScrollingTallyDetailVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollingTallyDetailVC.h"

#define kUnknownLocation @"Unknown"

@implementation ScrollingTallyDetailVC
@synthesize customizeAlertImage = _customizeAlertImage;
@synthesize scrollView = _scrollView;
@synthesize propertyName = _propertyName, pricePath = _pricePath, location = _location;


static NSDateFormatter *dateLblFormatter;
static NSNumberFormatter *normalValueLblFormatter;
static NSNumberFormatter *middleValueLblFormatter; // has extra decimal places see setRoundingIncrement

+ (void) initialize {
    dateLblFormatter = [[NSDateFormatter alloc] init];
    
    normalValueLblFormatter = [[NSNumberFormatter alloc] init];
    [normalValueLblFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [normalValueLblFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [normalValueLblFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:0.05]];
    
    middleValueLblFormatter = [[NSNumberFormatter alloc] init]; 
    [middleValueLblFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [middleValueLblFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [normalValueLblFormatter setRoundingIncrement:[[NSNumber alloc] initWithDouble:0.01]];

}

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
        self.location = kUnknownLocation;
        self.propertyName = self.location;

    }
    return self;
}

#pragma mark NSCoding

#define kVerNoCoding    @"VerNo"
#define kLocation       @"Location"
//#define kPurchDate      @"PurchDate"
//#define kPurchPrice     @"PurchPrice"
#define kPropertyName   @"PropName"
#define kPricePath      @"PricePath"


- (void) encodeWithCoder:(NSCoder *)encoder {
    DLog(@"Encoding ScrollingTallyDetailVC");
    [encoder encodeObject:GetTallyHomeVersionNum forKey:kVerNoCoding];
    
    [encoder encodeObject:_location forKey:kLocation];
    //    [encoder encodeObject:_purchDate forKey:kPurchDate];
    //    [encoder encodeDouble:purchasePrice forKey:kPurchPrice];
    [encoder encodeObject:_propertyName forKey:kPropertyName];
    [encoder encodeObject:_pricePath forKey:kPricePath];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [self init])) {
        DLog(@"Decoding ScrollingTallyDetailVC");
        if (!(self.location = [decoder decodeObjectForKey:kLocation])) {
            self.location = kUnknownLocation;
        }
        if (!(self.propertyName = [decoder decodeObjectForKey:kPropertyName])) {
            self.propertyName = self.location;
        }
        if (!(self.pricePath = [decoder decodeObjectForKey:kPricePath])) {
            self.pricePath = nil;
        }
    }
    
    return self;
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
    
    cell.dateLabel.backgroundColor = [UIColor grayColor];
    cell.dateLabel.text = @"30 June 2011";
    cell.valueLabel.backgroundColor = [UIColor whiteColor];
    cell.valueLabel.text = @"$X,XXX,XXX.00";
    cell.commentLabel.backgroundColor = [UIColor grayColor];
    cell.commentLabel.text = @"Increased by 3%";
    
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 2.0f;
    cell.layer.cornerRadius = 0.0f;//10.0f;
    
    return [cell autorelease];
}

- (void)tallyView:(TallyView *)tallyView willAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor {
    for(UILabel *lbl in cell.subviews) {
        CGFloat newSz = lbl.font.pointSize * scaleFactor;
        lbl.font = [lbl.font fontWithSize:newSz];
    }
}

- (void)tallyView:(TallyView *)tallyView didAdjustCellSize:(TallyViewCell *)cell by:(CGFloat)scaleFactor {
    //do nothing for now
    
    return;
}

- (void)tallyView:(TallyView *)tallyView willShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx {
    
    THDateVal *newData = nil;
    if (fromIx == 6 && toIx == 0) {
        THDateVal *ixZero = cell.data;
        newData = [_displayedData calcValueAt:[ixZero.date addDays:365]];  // add one year to ixZero date
    }
    else if (fromIx == 0 && toIx == 6) {
        THDateVal *ixSix = cell.data;
        newData = [_displayedData calcValueAt:[ixSix.date addDays:-365]];  // subtract one year from ixSix date
    }
    else {
        // adjust colors???
        
        return;
    }
    
    //NSAssert(newData, @"New data not initialized");
    if (!newData)
        DLog(@"newData is nil at fromIx %d toIx %d", fromIx, toIx);
    [self _applyData:newData toTallyViewCell:cell atIndex:toIx];
}

- (void)tallyView:(TallyView *)tallyView didShuffleCell:(TallyViewCell *)cell fromIndexPosition:(NSInteger)fromIx toIndexPosition:(NSInteger)toIx {
    // reformat the middle label
    TallyViewCell *middleLbl = [_scrollView.cells objectAtIndex:3];
    [self _applyData:middleLbl.data toTallyViewCell:middleLbl atIndex:3];
}

- (void)tallyView:(TallyView *)tallyView dataForCell:(TallyViewCell *)cell atIndexPosition:(NSInteger)ix {
    NSInteger yearsAhead = tallyView.scrollPosition + (3 - ix);
    THDateVal *data = [_displayedData calcValueAt:[[NSDate date] addDays:(yearsAhead * 365)]];
    cell.data = data;
    [self _applyData:data toTallyViewCell:cell atIndex:ix];
}

- (void)_applyData:(THDateVal *)data toTallyViewCell:(TallyViewCell *)cell atIndex:(NSInteger)ix {
    
    UILabel *dateLbl = [cell.subviews objectAtIndex:0];
    dateLbl.text = [data.date fuzzyRelativeDateString];
    
    UILabel *valueLbl = [cell.subviews objectAtIndex:1];
    if (ix == 3)
        valueLbl.text = [middleValueLblFormatter stringFromNumber:[NSNumber numberWithFloat:data.val]];
    else
        valueLbl.text = [normalValueLblFormatter stringFromNumber:[NSNumber numberWithFloat:data.val]];
    
    UILabel *changeLbl = [cell.subviews objectAtIndex:2];
    changeLbl.text = @"TODO: Change label";
    cell.data = data;
}



- (void)dealloc {
    [_customizeAlertImage release];
    [_scrollView release];
    [_displayedData release];
    [super dealloc];
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
    if (!_pricePath) {
        DLog(@"_pricePath nil, initializing");
        [self _initPricePath];
    }
    
    DLog(@"making price path...");
    _displayedData = [_pricePath makePricePath];
    DLog(@"...done");
    [_displayedData retain];
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
