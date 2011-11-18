//
//  RootViewController.m
//  TH
//
//  Created by Mark Blackwell on 11/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ScrollingTallyDetailVC.h"
#import "DebugMacros.h"


#if TARGET_IPHONE_SIMULATOR

@implementation CLLocationManager (Simulator)

+ (BOOL)locationServicesEnabled {
    return YES;
}
- (void)hackLocationFix {
    //sydney is -33.8667,151.2000
    DLog(@"hackLocation fix called...");
    CLLocation *location = [[CLLocation alloc] initWithLatitude:-33.8667 longitude:151.2]; 
    [[self delegate] locationManager:self didUpdateToLocation:location fromLocation:nil];     
}
- (void)startUpdatingLocation {
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:3.0];
}
@end

#endif


@interface RootViewController ()

@property (nonatomic, readwrite, retain) TallyDetailVC *activeTally;
@property (nonatomic, retain) CLLocationManager *locnMgr;
@property (nonatomic, retain) CLLocation *currentLocn;
@property (nonatomic, retain) ScrollingTallyDetailVC *unlocatedTally;

@end

@implementation RootViewController

@synthesize detailControllers = _tallies, activeTally = _activeTally, unlocatedTally = _unlocatedTally, locnMgr = _locnMgr, currentLocn = _currentLocn;

- (void)addButtonPressed:(id)sender {
    [self addNewScrollingTallyDetailVC];
}

- (void)addNewScrollingTallyDetailVC {
    ScrollingTallyDetailVC *vc = [[ScrollingTallyDetailVC alloc] init];
    
    //use the current location to provide a starting guess for the correct placename
    if ([CLLocationManager locationServicesEnabled]) {
        CLLocationManager *lm = [[CLLocationManager alloc] init];
        lm.delegate = self;
        lm.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        self.locnMgr = lm;
        [lm release];
        
        self.unlocatedTally = vc;
        
        _isLocating = YES;
        _isLocated = NO;
        [lm startUpdatingLocation];
        
        [self performSelector:@selector(locatorTimeOut) withObject:nil afterDelay:10];
    }
    
    
    [_tallies addObject:vc];
    [vc release];
    
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    DLog(@"found location %@", [newLocation description]);
    self.currentLocn = newLocation;
    if (newLocation.horizontalAccuracy < 50000 &&
        ABS([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) < 120) {   
        _isLocated = YES;
        [manager stopUpdatingLocation];
        _isLocating = NO;
        _unlocatedTally.location = newLocation;
        
        // for some fucking reason, nil-ing the location manager causes an EXC_BAD_ACCESS error...
//        self.locnMgr = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DLog(@"location error %@", [error description]);
    if(error.code == kCLErrorDenied) {
        _isLocated = NO;
        [manager stopUpdatingLocation];
        _isLocating = NO;
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        //keep trying to locate until the timeout...
    }
}

- (void)locatorTimeOut {
    if (!_isLocating)
        return;
    
    DLog(@"Locator timed out...");
    [_locnMgr stopUpdatingLocation];
}



- (void)viewDidLoad {
    self.title = @"TallyHome";
    
    if (!_tallies) {
        DLog(@"_tallyViewDataControllers nil, creating new object");
        TallyVCArray *dcs = [[TallyVCArray alloc] init];
        self.detailControllers = dcs;
        [dcs release];
    }
    
    // if there are no detail controllers, then create a PropertyDetailVC for current locn
    if (_tallies.count == 0) {
        DLog(@"_tallyViewDetailControllers.count == 0, creating default");
        [self addNewScrollingTallyDetailVC];
    }
    
    if (_tallies.count == 1) {
        [self navigateToTallyViewAtIndex:0 animated:NO];
    }
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                  target:self 
                                  action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem  = addButton;
    [addButton release];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tallies.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TallyDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    TallyDetailVC *ctrlr = [_tallies objectAtIndex:indexPath.row];
    cell.textLabel.text = ctrlr.rowTitle;
    cell.imageView.image = ctrlr.rowImage;
    cell.detailTextLabel.text = ctrlr.rowLatestData;
    
    // Configure the cell.
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    //return (indexPath.row != 0);
    return _tallies.count > 1;
}



 // Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        DLog(@"deleting row at index %d", indexPath.row);
        [_tallies removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        DLog(@"insert row called...");
    }   
}
 


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
      toIndexPath:(NSIndexPath *)toIndexPath {
    [_tallies swapObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [self navigateToTallyViewAtIndex:indexPath.row animated:YES];

}
         
- (void)navigateToTallyViewAtIndex:(NSUInteger)index animated:(BOOL)anim {
    if (self.navigationController) {
        self.activeTally = [_tallies objectAtIndex:index];
        if (_activeTally) {
            [self.navigationController 
                pushViewController:_activeTally 
                          animated:anim];
        }
        else {
            DLog(@"ERROR: no tally at index %d", index);
        }
    }
    else {
        DLog(@"ERROR: No nav controller!")
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}



@end
