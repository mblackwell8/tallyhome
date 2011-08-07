//
//  RootViewController.h
//  TallyHome
//
//  Created by Mark Blackwell on 4/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface RootViewController : UITableViewController /*<UITableViewDelegate, UITableViewDataSource>*/ {
    NSMutableArray *_tallyViewDetailControllers;
}

@property (nonatomic, retain) NSArray *detailControllers;




@end
