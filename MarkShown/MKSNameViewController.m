//
//  MKSEditViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSNameViewController.h"

@interface MKSNameViewController ()
- (void)saveMarkShowName;
@end

#pragma mark - Edit the name of the MarkShow

@implementation MKSNameViewController

@synthesize markShowItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the user interface for the detail item.
    if (self.markShowItem) {
        [self.markShowName setText:[[self.markShowItem valueForKey:@"presentationName"] description]];
        [self.markShowName becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveMarkShowName];
    [super viewWillDisappear:animated];
}

- (void)saveMarkShowName {
    if (self.markShowItem) {
        // save the edited value
        [self.markShowItem setValue:[self.markShowName text] forKey:@"presentationName"];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showStyle"]){
        [[segue destinationViewController] setMarkShowItem:self.markShowItem];
    }
}

- (IBAction)endMarkShowName:(id)sender {
    // on keyboard done button press go back to main view
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self.markShowName resignFirstResponder];
}

@end
