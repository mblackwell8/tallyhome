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

@property (nonatomic, readwrite, retain) UITextField *textField;

@end


@implementation TextEntryVC

@synthesize textField = _textField, guidanceMessage = _guidanceMsg, previousData = _preData, keyboardType = _kbdType, delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        
        
    }
    return self;
}

- (void)loadView {
    CGFloat screenHt = 480.0 - 20.0; //allow for status bar
    if (self.navigationController)
        screenHt -= 44;
    if (self.tabBarController)
        screenHt -= 49;
    
    CGRect screenRect = CGRectMake(0.0, 0.0, 320.0, screenHt);
    UIView *v = [[UIView alloc] initWithFrame:screenRect];
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 116.0, 280.0, 131.0)];
    _textField.font = [UIFont systemFontOfSize:16.0];
    [_textField addTarget:self 
                   action:@selector(textFieldEditingDidEnd:) 
         forControlEvents:UIControlEventEditingDidEnd];
    
    _textField.delegate = self;
    
    _textField.text = _preData;
    _textField.keyboardType = _kbdType;
    
    [v addSubview:_textField];
    
    self.view = v;
    
    [v release];
}

- (void)dealloc {
    [_textField release];
    [_guidanceMsg release];
    [_preData release];
    [super dealloc];
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
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self 
                                                                  action:@selector(_done)]; 
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [doneButton release];    
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
