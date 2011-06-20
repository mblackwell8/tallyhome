//
//  THArray.h
//  TallyHome
//
//  Created by Mark Blackwell on 20/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//source: https://gist.github.com/988219

@interface NSArray (THArray)

- (id)binarySearch:(id)searchItem;
- (id)binarySearch:(id)searchItem usingComparator:(SEL)comp;

@end
