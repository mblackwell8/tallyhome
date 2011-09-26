//
//  TableSelectorVC.m
//  TH
//
//  Created by Mark Blackwell on 13/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableSelectorVC.h"
#import "DebugMacros.h"

@interface TableSelectorVC ()

- (void)selectCellAtIndexPath:(NSIndexPath *)path;
- (void)unSelectCellAtIndexPath:(NSIndexPath *)path;
- (void)doneButtonTapped:(id)sender;

@end

@implementation TableSelectorVC

@synthesize options = _options, delegate = _delegate, allowsMultipleSelections = _allowsMultipleSelections, selectedOptions = _selectedOptions, allowsNoSelection = _allowsNoSelection;
@synthesize commentText = _commentText, headerText = _headerText;

- (void)setOptionsUsingCSV:(NSString *)csv {
    self.options = [csv componentsSeparatedByString:@","];
}

- (void)setSelectedOptions:(NSArray *)selectedOptions {
    NSMutableArray *selOpts = [[NSMutableArray alloc] initWithArray:selectedOptions];
    [_selectedOptions release];
    _selectedOptions = selOpts;
}

- (void)setSelectedOptionsUsingCSV:(NSString *)csv {
    [self setSelectedOptions:[csv componentsSeparatedByString:@","]];
}

- (NSString *)selectedOptionUsingCSV {
    return [_selectedOptions componentsJoinedByString:@","];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
    [_options release];
    [_selectedOptions release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    if (_allowsMultipleSelections) {
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                 style:UIBarButtonItemStyleDone 
                                                                target:self 
                                                                action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItem = done;
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _headerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _commentText;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_options ? _options.count : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    id option = [_options objectAtIndex:indexPath.row];
    cell.textLabel.text = [option description];
    if (_selectedOptions &&
        [_selectedOptions containsObject:option]) {
        //don't check multiple/no selections
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    id option = [_options objectAtIndex:indexPath.row];
    if (_selectedOptions &&
        [_selectedOptions containsObject:option]) {
        [self unSelectCellAtIndexPath:indexPath];
    }
    else {    
        [self selectCellAtIndexPath:indexPath];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    id newOption = [_options objectAtIndex:indexPath.row];
    if (!_selectedOptions)
        _selectedOptions = [[NSMutableArray alloc] init];
    [_selectedOptions addObject:newOption];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [_delegate tableSelectorDidSelect:self itemNumber:indexPath.row];
    
    if (_selectedOptions.count <= 1 || _allowsMultipleSelections)
        return;
    
    int ix = 0;
    for (id option in _options) {
        if (option != newOption && [_selectedOptions containsObject:option]) {
            [self unSelectCellAtIndexPath:[NSIndexPath indexPathForRow:ix inSection:0]];
        }
        ix += 1;
    }
}

- (void)unSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    if (!_selectedOptions)
        return;
    
    if (_selectedOptions.count > 1 || _allowsNoSelection) {
        DLog(@"ix path: %d", indexPath.row);
        id option = [_options objectAtIndex:indexPath.row];
        if (![_selectedOptions containsObject:option])
            return;
        
        [_selectedOptions removeObject:option];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (_delegate &&
            [_delegate respondsToSelector:@selector(tableSelectorDidUnselect:itemNumber:)]) {
            [_delegate tableSelectorDidUnselect:self itemNumber:indexPath.row];
        }
    }
}

- (void)doneButtonTapped:(id)sender {
    //assume that selection code has ensured that we have appropriate selections
    NSAssert(_allowsMultipleSelections || _selectedOptions.count <= 1, @"error");
    NSAssert(_allowsNoSelection || _selectedOptions.count > 0, @"error");
    
    if (_delegate &&
        [_delegate respondsToSelector:@selector(tableSelectorWillFinishDone:)]) {
        [_delegate tableSelectorWillFinishDone:self];
    }
    
    //commit suicide
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
