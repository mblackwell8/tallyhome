//
//  PropertySettingsVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PropertySettingsVC.h"
#import "DebugMacros.h"

#define TH_PROPSETTINGS_LOCNENTRY_IX 0
#define TH_PROPSETTINGS_PRICEENTRY_IX 2
#define TH_PROPSETTINGS_LABELENTRY_IX 3

@implementation PropertySettingsVC

@synthesize delegate = _delegate, location = _location, propertyName = _propertyName, buyPrice = _buyPrice;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"Edit";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                   style:UIBarButtonItemStylePlain 
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"City";
            cell.detailTextLabel.text = _location;
            break;
            
        case 1:
            cell.textLabel.text = @"Purchase date";
            cell.detailTextLabel.text = [dateFormatter stringFromDate:_buyPrice.date];
            break;
            
        case 2:
            cell.textLabel.text = @"Price";
            NSNumber *price = [[NSNumber alloc] initWithDouble:_buyPrice.val];
            cell.detailTextLabel.text = [priceFormatter stringFromNumber:price];
            [price release];
            break;
            
        case 3:
            cell.textLabel.text = @"Label";
            cell.detailTextLabel.text = _propertyName;
            break;

        default:
            break;
    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TextEntryVC *locnEntryVC = nil;
    DateSelectorVC *buyDateEntryVC = nil;
    TextEntryVC *buyPriceEntryVC = nil;
    TextEntryVC *labelEntryVC = nil;
    
    switch (indexPath.row) {
        case 0:
            //Location, edit with text        
            locnEntryVC = [[TextEntryVC alloc] init];
            locnEntryVC.title = @"City";
            locnEntryVC.delegate = self;
            locnEntryVC.previousData = _location;
            locnEntryVC.view.tag = TH_PROPSETTINGS_LOCNENTRY_IX;
            [self.navigationController pushViewController:locnEntryVC animated:YES];
            [locnEntryVC release];
            break;
            
        case 1:
            //Purchase date, edit with date control
            buyDateEntryVC = [[DateSelectorVC alloc] init];
            buyDateEntryVC.title = @"Purchase date";
            buyDateEntryVC.delegate = self;
            buyDateEntryVC.date = _buyPrice.date;
            [self.navigationController pushViewController:buyDateEntryVC animated:YES];
            [buyDateEntryVC release];
            break;
            
        case 2:
            // buy price, edit with text
            buyPriceEntryVC = [[TextEntryVC alloc] init];
            buyPriceEntryVC.title = @"Purchase price";
            buyPriceEntryVC.delegate = self;
            NSNumber *value = [NSNumber numberWithDouble:_buyPrice.val];
            buyPriceEntryVC.keyboardType = UIKeyboardTypeDecimalPad;
            buyPriceEntryVC.previousData = [priceFormatter stringFromNumber:value];
            buyPriceEntryVC.view.tag = TH_PROPSETTINGS_PRICEENTRY_IX;
            [self.navigationController pushViewController:buyPriceEntryVC animated:YES];
            [buyPriceEntryVC release];
            break;
            
        case 3:
            //Label, edit with text
            labelEntryVC = [[TextEntryVC alloc] init];
            labelEntryVC.title = @"Name";
            labelEntryVC.delegate = self;
            labelEntryVC.previousData = _propertyName;
            labelEntryVC.view.tag = TH_PROPSETTINGS_LABELENTRY_IX;
            [self.navigationController pushViewController:labelEntryVC animated:YES];
            [labelEntryVC release];
            break;
            
        default:
            break;
    }

}

//@protocol TextEntryVCDelegate <NSObject>

- (BOOL)textEntryShouldReturn:(TextEntryVC *)textEntry {
    double val = 0.0;
    THDateVal *bp = nil;
    switch (textEntry.view.tag) {
        case TH_PROPSETTINGS_LOCNENTRY_IX:
            //accept anything
            self.location = textEntry.textField.text;
            break;
            
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
