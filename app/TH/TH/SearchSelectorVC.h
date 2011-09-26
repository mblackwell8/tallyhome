//
//  SearchSelectorVC.h
//  TH
//
//  Created by Mark Blackwell on 25/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPlaceName.h"

@class SearchSelectorVC;

@protocol SearchBarSelectorDelegate <NSObject>

- (void)searchSelectorDidSelect:(SearchSelectorVC *)searcher place:(THPlaceName *)place;

@end

@interface SearchSelectorVC: UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray			*_listContent;			// The master content.
	NSMutableArray	*_filteredListContent;	// The content filtered as a result of a search.
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*_savedSearchTerm;
    NSInteger		_savedScopeButtonIndex;
    BOOL			_searchWasActive;
    
    id<SearchBarSelectorDelegate> _delegate;
}

@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) id<SearchBarSelectorDelegate> delegate;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@end
