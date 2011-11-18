//
//  PropertySettingsVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropertySettingsVC.h"
#import "DebugMacros.h"

@implementation PropertySettingsVC

@synthesize delegate = _delegate, location = _location, propertyName = _propertyName, buyPrice = _buyPrice, proximitiesIncluded = _proximitiesIncluded, sourcesIncluded = _sourcesIncluded, forecastingTimeScale = _forecastingTimeScale, selectedIndexPath = _selectedIndexPath;

static NSDateFormatter *dateFormatter;
static NSNumberFormatter *priceFormatter;

+ (void) initialize {
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    //HACK: this seems to work, but looks inappropriate... may not localize
    [priceFormatter setMaximumFractionDigits:0];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [_location release];
    [_propertyName release];
    [_buyPrice release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)_done {
    if ([_delegate respondsToSelector:@selector(propertySettingsWillFinishDone:)])
        [_delegate propertySettingsWillFinishDone:self];
}

- (void)_cancel {
    if ([_delegate respondsToSelector:@selector(propertySettingsWillFinishCancelled:)])
        [_delegate propertySettingsWillFinishCancelled:self];
}

- (THHomePriceIndexProximity)proximities {
    int p = 0;
    for (NSString *prox in [_proximitiesIncluded componentsSeparatedByString:@","]) {
        //#define TH_PROX_LIST @"City,State,Country"
         
        if ([prox isEqualToString:@"City"]) {
            p |= THHomePriceIndexProximityCity;
        }
        else if ([prox isEqualToString:@"State"]) {
            p |= THHomePriceIndexProximityState;
        }
        else if ([prox isEqualToString:@"Country"]) {
            p |= THHomePriceIndexProximityCountry;
        }
    }
    
    return p;
}

- (void)setProximities:(THHomePriceIndexProximity)proximities {
    NSMutableArray *proxs = [[NSMutableArray alloc] init];
    //#define TH_PROX_LIST @"City,State,Country"    

    if (proximities & THHomePriceIndexProximityCity) {
        [proxs addObject:@"City"];
    }
    if (proximities & THHomePriceIndexProximityState) {
        [proxs addObject:@"State"];
    }
    if (proximities & THHomePriceIndexProximityCountry) {
        [proxs addObject:@"Country"];
    }
    
    self.proximitiesIncluded = [proxs componentsJoinedByString:@","];
    [proxs release];
}

- (THHomePriceIndexSource)sources {
    int s = 0;
    for (NSString *prox in [_sourcesIncluded componentsSeparatedByString:@","]) {
        //TH_SOURCE_LIST @"Government,Branded,Other"
        
        if ([prox isEqualToString:@"Government"]) {
            s |= THHomePriceIndexSourceGovt;
        }
        else if ([prox isEqualToString:@"Branded"]) {
            s |= THHomePriceIndexSourceBranded;
        }
        else if ([prox isEqualToString:@"Other"]) {
            s |= THHomePriceIndexSourceOther;
        }
    }
    
    return s;

}

- (void)setSources:(THHomePriceIndexSource)sources {
    NSMutableArray *srcs = [[NSMutableArray alloc] init];
    //TH_SOURCE_LIST @"Government,Branded,Other"
    if (sources & THHomePriceIndexSourceGovt) {
        [srcs addObject:@"Government"];
    }
    if (sources & THHomePriceIndexSourceBranded) {
        [srcs addObject:@"Branded"];
    }
    if (sources & THHomePriceIndexSourceOther) {
        [srcs addObject:@"Other"];
    }
    
    self.sourcesIncluded = [srcs componentsJoinedByString:@","];
    [srcs release];
}

- (NSTimeInterval)trendExtrapolationInterval {
    //#define TH_FORECASTTIME_LIST @"One year,Five years,Ten years"
    if ([_forecastingTimeScale isEqualToString:@"One year"]) {
        return TH_OneYearTimeInterval;
    }
    if ([_forecastingTimeScale isEqualToString:@"Five years"]) {
        return TH_FiveYearTimeInterval;
    }
    if ([_forecastingTimeScale isEqualToString:@"Ten years"]) {
        return TH_TenYearTimeInterval;
    }
    
    NSAssert(NO, @"should not get here");
    return 0;
}

- (void)setTrendExtrapolationInterval:(NSTimeInterval)interval {
    if (interval == TH_OneYearTimeInterval) {
        _forecastingTimeScale = @"One year";
    }
    else if (interval == TH_FiveYearTimeInterval) {
        _forecastingTimeScale = @"Five years";
    }
    else if (interval == TH_TenYearTimeInterval) {
        _forecastingTimeScale = @"Ten years";
    }
    else {
        NSAssert(NO, @"should not get here");
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
        
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(_done)]; 
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(_cancel)]; 
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [doneButton release];
    [cancelButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Property settings";
            
        case 1:
            return @"Advanced";
            
        default:
            NSAssert(NO, @"should not get here");
            return 0;
    }
    
    NSAssert(NO, @"should not get here either");
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
            
        case 1:
            return 3;
            
        default:
            NSAssert(NO, @"should not get here");
            return 0;
    }
    
    NSAssert(NO, @"should not get here either");
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Property name";
                    cell.detailTextLabel.text = _propertyName;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Location";
                    cell.detailTextLabel.text = [_location shortDescription];
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Valuaton date";
                    cell.detailTextLabel.text = [dateFormatter stringFromDate:_buyPrice.date];
                    break;
                    
                case 3:
                    cell.textLabel.text = @"Valuation";
                    NSNumber *price = [[NSNumber alloc] initWithDouble:_buyPrice.val];
                    cell.detailTextLabel.text = [priceFormatter stringFromNumber:price];
                    [price release];
                    break;
                  
                default:
                    break;
            }
            break;
        // advanced section
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Proximities";
                    cell.detailTextLabel.text = _proximitiesIncluded;
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Sources";
                    cell.detailTextLabel.text = _sourcesIncluded;
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Forecasting basis";
                    cell.detailTextLabel.text = _forecastingTimeScale;
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
            
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
    
    return (indexPath.row == 0);
}

#pragma mark - Table view delegate

#define TH_PROPSETTINGS_LABELENTRY_IX 0
#define TH_PROPSETTINGS_LOCNENTRY_IX 1
#define TH_PROPSETTINGS_DATEENTRY_IX 2
#define TH_PROPSETTINGS_PRICEENTRY_IX 3

#define TH_PROPSETTINGS_PROX_IX 4
#define TH_PROPSETTINGS_SOURCE_IX 5
#define TH_PROPSETTINGS_FORECASTTIME_IX 6


//#define TH_AUSTRALIAN_CITYLIST @"Sydney,Melbourne,Brisbane,Perth,Adelaide,Darwin,Hobart,Canberra,Other"
#define TH_PROX_LIST @"City,State,Country"
#define TH_SOURCE_LIST @"Government,Branded,Other"
#define TH_FORECASTTIME_LIST @"One year,Five years,Ten years"

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TableSelectorVC *tableSelector = nil;
    SearchSelectorVC *searchSelector = nil;
    DateSelectorVC *dateSelector = nil;
    TextEntryVC *textSelector = nil;
    
    self.selectedIndexPath = indexPath;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    //Label, edit with text
                    textSelector = [[TextEntryVC alloc] init];
                    textSelector.title = @"Property name";
                    textSelector.commentText = @"Choose a name for this property... it doesn't matter what, but try to keep it less than 15 characters";
                    textSelector.delegate = self;
                    textSelector.previousData = _propertyName;
                    textSelector.view.tag = TH_PROPSETTINGS_LABELENTRY_IX;
                    [self.navigationController pushViewController:textSelector animated:YES];
                    [textSelector release];
                    break;
                    
                case 1:
                    //Location, edit with table selector for now        
                    searchSelector = [[SearchSelectorVC alloc] init];
                    searchSelector.title = @"Location";
                    searchSelector.listContent = [THPlaceName sharedPlaceNames];
//                    NSString *cityList = TH_AUSTRALIAN_CITYLIST;
//                    searchSelector.listContent = [cityList componentsSeparatedByString:@","];
                    searchSelector.delegate = self;
                    //locnEntryVC.previousData = _location;
                    searchSelector.view.tag = TH_PROPSETTINGS_LOCNENTRY_IX;
                    [self.navigationController pushViewController:searchSelector animated:YES];
                    
                    //HACK: the UISearchDisplayController appears to take a reference to the
                    //view controller, then releases it... but i can't see where it is taking
                    //a reference... so the object is over-released and crashes
                    
                    //this is just a convenient place to stop the over-release, by not releasing in my code
                    
                    //[searchSelector release];
                    break;
                    
                case 2:
                    //Purchase date, edit with date control
                    dateSelector = [[DateSelectorVC alloc] init];
                    dateSelector.title = @"Valuation date";
                    dateSelector.commentText = @"Enter the date of your valuation... today is fine if you like";
                    dateSelector.delegate = self;
                    dateSelector.date = _buyPrice.date;
                    dateSelector.view.tag = TH_PROPSETTINGS_DATEENTRY_IX;
                    [self.navigationController pushViewController:dateSelector animated:YES];
                    [dateSelector release];
                    break;
                    
                case 3:
                    // buy price, edit with text
                    textSelector = [[TextEntryVC alloc] init];
                    textSelector.title = @"Valuation";
                    textSelector.commentText = @"Enter a recent valuation, whatever you think (or perhaps some other expert thinks) the property is worth";
                    textSelector.delegate = self;
                    NSNumber *value = [NSNumber numberWithDouble:round(_buyPrice.val)];
                    textSelector.keyboardType = UIKeyboardTypeDecimalPad;
                    textSelector.previousData = [value stringValue];
                    textSelector.view.tag = TH_PROPSETTINGS_PRICEENTRY_IX;
                    [self.navigationController pushViewController:textSelector animated:YES];
                    [textSelector release];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    //proximities
                    tableSelector = [[TableSelectorVC alloc] initWithStyle:UITableViewStyleGrouped];
                    tableSelector.title = @"Proximities";
                    tableSelector.commentText = @"Select indices to include in your valuation estimate (eg. 'City' means only indices that track prices in your city)";
                    tableSelector.allowsNoSelection = NO;
                    tableSelector.allowsMultipleSelections = YES;
                    [tableSelector setOptionsUsingCSV:TH_PROX_LIST];
                    [tableSelector setSelectedOptionsUsingCSV:_proximitiesIncluded];
                    tableSelector.delegate = self;
                    //locnEntryVC.previousData = _location;
                    tableSelector.view.tag = TH_PROPSETTINGS_PROX_IX;
                    [self.navigationController pushViewController:tableSelector animated:YES];
                    [tableSelector release];
                    break;
                    
                case 1:
                    //sources        
                    tableSelector = [[TableSelectorVC alloc] initWithStyle:UITableViewStyleGrouped];
                    tableSelector.title = @"Sources";
                    tableSelector.commentText = @"Select the index sources to include in your valuation estimate (eg. 'Government' means only indices published by government)";
                    tableSelector.allowsNoSelection = NO;
                    tableSelector.allowsMultipleSelections = YES;
                    [tableSelector setOptionsUsingCSV:TH_SOURCE_LIST];
                    [tableSelector setSelectedOptionsUsingCSV:_sourcesIncluded];
                    tableSelector.delegate = self;
                    //locnEntryVC.previousData = _location;
                    tableSelector.view.tag = TH_PROPSETTINGS_SOURCE_IX;
                    [self.navigationController pushViewController:tableSelector animated:YES];
                    [tableSelector release];
                    break;
                    
                case 2:
                    //forecasting time scale
                    tableSelector = [[TableSelectorVC alloc] initWithStyle:UITableViewStyleGrouped];
                    tableSelector.title = @"Forecasting time scale";
                    tableSelector.commentText = @"Select the time duration that TallyHome should use to calculate a trend for forecasting purposes (eg. 'Five years' means TallyHome will use the past five years of price data to forecast price growth rates)";
                    tableSelector.allowsNoSelection = NO;
                    tableSelector.allowsMultipleSelections = NO;
                    [tableSelector setOptionsUsingCSV:TH_FORECASTTIME_LIST];
                    [tableSelector setSelectedOptionsUsingCSV:_forecastingTimeScale];
                    tableSelector.delegate = self;
                    //locnEntryVC.previousData = _location;
                    tableSelector.view.tag = TH_PROPSETTINGS_FORECASTTIME_IX;
                    [self.navigationController pushViewController:tableSelector animated:YES];
                    [tableSelector release];
                    break;
                    
                default:
                    break;
            }

    }

}

//@protocol TextEntryVCDelegate <NSObject>

- (BOOL)textEntryShouldReturn:(TextEntryVC *)textEntry {
    double val = 0.0;
    THDateVal *bp = nil;
    switch (textEntry.view.tag) {
        case TH_PROPSETTINGS_PRICEENTRY_IX:
            
            val = [textEntry.textField.text doubleValue];
            //use now as default date
            bp = [[THDateVal alloc] initWithVal:val
                                             at:_buyPrice ? _buyPrice.date : [NSDate date]];
            
            self.buyPrice = bp;
            [bp release];
            break;

            
        case TH_PROPSETTINGS_LABELENTRY_IX:
            self.propertyName = textEntry.textField.text;
            break;

            
        default:
            NSAssert(FALSE, @"Should not get here");
            break;
    }
    
    [self.tableView reloadData];
    
    return YES;
}

//@end

- (void)tableSelectorDidSelect:(TableSelectorVC *)tableSelector itemNumber:(NSUInteger)num {
    switch (tableSelector.view.tag) {
        case TH_PROPSETTINGS_PROX_IX:
            //multiple selections so wait for finished
            return;
            
        case TH_PROPSETTINGS_SOURCE_IX:
            //multiple selections so wait for finished
            return;
                
        case TH_PROPSETTINGS_FORECASTTIME_IX:
            self.forecastingTimeScale = [[TH_FORECASTTIME_LIST componentsSeparatedByString:@","] objectAtIndex:num];
            break;
            
        default:
            NSAssert(FALSE, @"should not get here");
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

- (void)tableSelectorDidUnSelect:(TableSelectorVC *)tableSelector itemNumber:(NSUInteger)num {
    switch (tableSelector.view.tag) {
        case TH_PROPSETTINGS_PROX_IX:
            break;
            
        case TH_PROPSETTINGS_SOURCE_IX:
            break;
            
        case TH_PROPSETTINGS_FORECASTTIME_IX:
            break;
            
        default:
            NSAssert(FALSE, @"Should not get here");
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

- (void)tableSelectorWillFinishDone:(TableSelectorVC *)tableSelector {
    switch (tableSelector.view.tag) {
        case TH_PROPSETTINGS_PROX_IX:
            self.proximitiesIncluded = tableSelector.selectedOptionUsingCSV;            
            break;
            
        case TH_PROPSETTINGS_SOURCE_IX:
            self.sourcesIncluded = tableSelector.selectedOptionUsingCSV;
            break;
            
        case TH_PROPSETTINGS_FORECASTTIME_IX:
            //has been handled above
            return;
            
        default:
            NSAssert(FALSE, @"should not get here");
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

- (void)searchSelectorDidSelect:(SearchSelectorVC *)searcher place:(THPlaceName *)place {
    THPlaceName *copy = [place copy];
    self.location = place;
    [copy release];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

//@protocol DateSelectorDelegate <NSObject>
//@required
- (BOOL)dateEntryShouldReturn:(DateSelectorVC *)dateEntry {
    //accept anything... even future?
    THDateVal *bp = [[THDateVal alloc] initWithVal:(_buyPrice ? _buyPrice.val : 0.0)
                                                at:dateEntry.date];
    
    self.buyPrice = bp;
    [bp release];
    
    [self.tableView reloadData];
    
    return YES;
}
//@end

@end
