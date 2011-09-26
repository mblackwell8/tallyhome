//
//  SearchBarVC.m
//  TH
//
//  Created by Mark Blackwell on 23/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchBarSelectorVC.h"




@implementation SearchBarSelectorVC

@synthesize listContent = _listContent, filteredListContent = _filteredListContent, savedSearchTerm = _savedSearchTerm, savedScopeButtonIndex = _savedScopeButtonIndex, searchWasActive = _searchWasActive, delegate = _delegate;

- (id)init {
    self = [self initWithNibName:@"SearchBarSelectorVC" bundle:nil];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
	[_listContent release];
	[_filteredListContent release];
	
	[super dealloc];
}


#pragma mark - 
#pragma mark Lifecycle methods

- (void)viewDidLoad {
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (_savedSearchTerm) {
        [self.searchDisplayController setActive:_searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:_savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}

- (void)viewDidUnload {
	self.filteredListContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}



#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent count];
    }
	else {
        return [self.listContent count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	THPlaceName *place = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else {
        place = [self.listContent objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.text = [place description];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	THPlaceName *place = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else {
        place = [self.listContent objectAtIndex:indexPath.row];
    }

    [_delegate searchSelectorDidSelect:self place:place];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (THPlaceName *place in _listContent) {
//		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope]) {
			if ([place hasOneOrMoreNamesMatching:searchText]) {
				[self.filteredListContent addObject:place];
            }
//		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    [self filterContentForSearchText:searchString scope:nil];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}


@end
