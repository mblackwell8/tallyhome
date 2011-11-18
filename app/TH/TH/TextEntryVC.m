//
//  TextEntryVC.m
//  TallyHome
//
//  Created by Mark Blackwell on 3/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextEntryVC.h"
#import "DebugMacros.h"

@interface TextEntryVC ()

@property (nonatomic, retain) UITableView *textTableView;
@property (nonatomic, readwrite, retain) UITextField *textField;

@end


@implementation TextEntryVC

@synthesize textField = _textField, guidanceMessage = _guidanceMsg, previousData = _preData, keyboardType = _kbdType, delegate = _delegate, textTableView = _textTableView, commentText = _commentText;

- (id)init {
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (void)dealloc {
    [_textField release];
    [_guidanceMsg release];
    [_preData release];
    [super dealloc];
}


- (void)loadView {
    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = theView;
    [theView release];
    
    UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 67.0, 320.0, 480.0) style:UITableViewStyleGrouped];
    theTableView.delegate = self;
    theTableView.dataSource = self;
    [self.view addSubview:theTableView];
    self.textTableView = theTableView;
    [theTableView release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLocalizedString(@"Done", @"Done - to save changes")
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(_done)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UITextField *txtField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 275, 30)];
    txtField.adjustsFontSizeToFitWidth = YES;
    txtField.font = [UIFont systemFontOfSize:16.0];
    txtField.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    txtField.placeholder = @"Required";
    txtField.keyboardType = _kbdType;
    txtField.backgroundColor = [UIColor whiteColor];
    txtField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    txtField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    txtField.textAlignment = UITextAlignmentLeft;
    txtField.tag = 0;
    [txtField addTarget:self 
                 action:@selector(textFieldEditingDidEnd:) 
       forControlEvents:UIControlEventEditingDidEnd];
    txtField.delegate = self;
    
    txtField.clearButtonMode = UITextFieldViewModeNever;
    [txtField setEnabled: YES];
    
    self.textField = txtField;    
    [txtField release];

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _commentText;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *textCellIdentifier = @"TextCellIdentifier";
    UITableViewCell *cell = [_textTableView dequeueReusableCellWithIdentifier:textCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:textCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
                
        [cell addSubview:_textField];
        
    }
    
    //cell.textLabel.text = @"Log in";
    return cell;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;   
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate textEntryShouldReturn:self]) {
        [textField resignFirstResponder];
        
        return YES;
    }
    
    return NO;
}

- (void)textFieldEditingDidEnd:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_done {
    //just alert, ignore response
    [_delegate textEntryShouldReturn:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.  
}

- (void)viewWillAppear:(BOOL)animated {
    [_textField becomeFirstResponder];
    
    DLog(@"Kbd type %d", _textField.keyboardType);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
