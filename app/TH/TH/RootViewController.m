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

@implementation RootViewController

@synthesize detailControllers = _tallyViewDetailControllers;

- (void)viewDidLoad {
    if (!_tallyViewDetailControllers) {
        DLog(@"_tallyViewDataControllers nil, creating new object");
        TallyVCArray *dcs = [[TallyVCArray alloc] init];
        self.detailControllers = dcs;
        [dcs release];
    }
    
    // if there are no detail controllers, then create a PropertyDetailVC for current locn
    if (_tallyViewDetailControllers.count == 0) {
        DLog(@"_tallyViewDetailControllers.count == 0, creating default");
        ScrollingTallyDetailVC *vc = [[ScrollingTallyDetailVC alloc] init];
        [_tallyViewDetailControllers addObject:vc];
        [vc release];
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return _tallyViewDetailControllers.count;
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
    
    TallyDetailVC *ctrlr = [_tallyViewDetailControllers objectAtIndex:indexPath.row];
    cell.textLabel.text = ctrlr.rowTitle;
    cell.imageView.image = ctrlr.rowImage;
    cell.detailTextLabel.text = ctrlr.rowLatestData;
    
    // Configure the cell.
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete)
 {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert)
 {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    if (self.navigationController) {
        [self.navigationController pushViewController:[_tallyViewDetailControllers objectAtIndex:indexPath.row] animated:YES];
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

//@synthesize detailControllers = _tallyViewDetailControllers, uniqueUserId = _uniqueUserId;
//
//// pasted from http://blog.ablepear.com/2010/09/creating-guid-or-uuid-in-objective-c.html
//
//// return a new autoreleased UUID string
//- (NSString *)generateUuidString
//{
//    // create a new UUID which you own
//    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
//    
//    // create a new CFStringRef (toll-free bridged to NSString)
//    // that you own
//    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
//    
//    // transfer ownership of the string
//    // to the autorelease pool
//    [uuidString autorelease];
//    
//    // release the UUID
//    CFRelease(uuid);
//    
//    return uuidString;
//}
//
//#pragma mark NSCoding
//
//#define kTallyViewDetailCtrlrs    @"TVDetailCtrlrs"
//#define kUUID                     @"UUID"
//
//
//- (void)encodeWithCoder:(NSCoder *)encoder {
//    DLog(@"Encoding RootViewController");
//    [encoder encodeObject:_tallyViewDetailControllers forKey:kTallyViewDetailCtrlrs];
//    [encoder encodeObject:_uniqueUserId forKey:kUUID];
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    
//    if ((self = [self init])) {
//        DLog(@"Decoding RootViewController");
//        if (!(_tallyViewDetailControllers = [[decoder decodeObjectForKey:kTallyViewDetailCtrlrs] retain])) {
//            _tallyViewDetailControllers = nil;
//        }
//        if (!(_uniqueUserId = [[decoder decodeObjectForKey:kUUID] retain])) {
//            _uniqueUserId = [[self generateUuidString] retain];
//        }
//    }
//    
//    return self;
//}
//
//- (void)dealloc {
//    [super dealloc];
//    
//    [_tallyViewDetailControllers release];
//    [_uniqueUserId release];
//}
//
//- (void)viewDidLoad {
//    if (self.navigationController)
//        NSLog(@"got one!");
//    
//    if (!_tallyViewDetailControllers) {
//        DLog(@"_tallyViewDataControllers nil, creating new object");
//        NSMutableArray *dcs = [[NSMutableArray alloc] init];
//        self.detailControllers = dcs;
//        [dcs release];
//    }
//    
//    // if there are no detail controllers, then create a PropertyDetailVC for current locn
//    if (_tallyViewDetailControllers.count == 0) {
//        DLog(@"_tallyViewDetailControllers.count == 0, creating default");
//        ScrollingTallyDetailVC *vc = [[ScrollingTallyDetailVC alloc] init];
//        [_tallyViewDetailControllers addObject:vc];
//        [vc release];
//    }
//    
//    [super viewDidLoad];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//	[super viewDidDisappear:animated];
//}
//
///*
// // Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	// Return YES for supported orientations.
//	return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
// */
//
//// Customize the number of sections in the table view.
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return _tallyViewDetailControllers.count;
//}
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"TallyDetailCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
//                                       reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    
//    TallyDetailVC *ctrlr = [_tallyViewDetailControllers objectAtIndex:indexPath.row];
//    cell.textLabel.text = ctrlr.rowTitle;
//    cell.imageView.image = ctrlr.rowImage;
//    cell.detailTextLabel.text = ctrlr.rowLatestData;
//    
//    // Configure the cell.
//    return cell;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        // Delete the row from the data source.
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert)
//    {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    /*
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//    // ...
//    // Pass the selected object to the new view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    [detailViewController release];
//	*/
//    
//    if (self.navigationController) {
//        [self.navigationController pushViewController:[_tallyViewDetailControllers objectAtIndex:indexPath.row] animated:YES];
//    }
//    else {
//        DLog(@"ERROR: No nav controller!")
//    }
//
//}
//
//- (void)didReceiveMemoryWarning
//{
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//    
//    // Relinquish ownership any cached data, images, etc that aren't in use.
//}
//
//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//
//    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
//    // For example: self.myOutlet = nil;
//}
//

@end
