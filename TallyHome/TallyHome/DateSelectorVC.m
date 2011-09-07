//
//  THDateSelectorVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 7/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DateSelectorVC.h"


@implementation DateSelectorVC


@synthesize datePicker;
@synthesize dateTableView;
@synthesize date = _date;
@synthesize delegate = _delegate;

-(IBAction)dateChanged {
    self.date = [datePicker date];
    [dateTableView reloadData];
}

- (id)init {
    self = [self initWithNibName:@"DateSelectorVC" bundle:nil];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc  {
    [datePicker release];
    [dateTableView release];
    [_date release];
    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//-(IBAction)cancel {
//    [[self.delegate navController] popViewControllerAnimated:YES];
//}
-(IBAction)save {
    self.date = [datePicker date];
    //just alert, ignore response
    [_delegate dateEntryShouldReturn:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)loadView {
    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = theView;
    [theView release];
    
    UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 67.0, 320.0, 480.0) style:UITableViewStyleGrouped];
    theTableView.delegate = self;
    theTableView.dataSource = self;
    [self.view addSubview:theTableView];
    self.dateTableView = theTableView;
    [theTableView release];
    
    UIDatePicker *theDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 200.0, 320.0, 216.0)];
    theDatePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker = theDatePicker;
    [theDatePicker release];
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    
    
    
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
//                                     initWithTitle:NSLocalizedString(@"Cancel", @"Cancel - for button to cancel changes")
//                                     style:UIBarButtonItemStylePlain
//                                     target:self
//                                     action:@selector(cancel)];
//    self.navigationItem.leftBarButtonItem = cancelButton;
//    [cancelButton release];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Done", @"Done - to save changes")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (_date != nil)
        [self.datePicker setDate:_date animated:YES];
    else 
        [self.datePicker setDate:[NSDate date] animated:YES];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
//    [_delegate setDate:_date];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Table View Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *DateCellIdentifier = @"DateCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DateCellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DateCellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    cell.textLabel.text = [formatter stringFromDate:_date];
    [formatter release];
    
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;   
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



@end


