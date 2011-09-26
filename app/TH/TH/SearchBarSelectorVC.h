//
//  SearchBarVC.h
//  TH
//
//  Created by Mark Blackwell on 23/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THPlaceName.h"

@class SearchBarSelectorVC;

@protocol SearchBarSelectorDelegate <NSObject>

- (void)searchSelectorDidSelect:(SearchBarSelectorVC *)searcher place:(THPlaceName *)place;

@end

@interface SearchBarSelectorVC: UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
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


