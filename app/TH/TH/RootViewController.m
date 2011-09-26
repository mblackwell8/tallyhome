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

@interface RootViewController ()

@property (nonatomic, readwrite, retain) TallyDetailVC *activeTally;

@end

@implementation RootViewController

@synthesize detailControllers = _tallies, activeTally = _activeTally;

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

- (void)addButtonPressed:(id)sender {
    [self addNewScrollingTallyDetailVC];
}

- (void)addNewScrollingTallyDetailVC {
    ScrollingTallyDetailVC *vc = [[ScrollingTallyDetailVC alloc] init];
    [_tallies addObject:vc];
    [vc release];

    [self.tableView reloadData];
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
