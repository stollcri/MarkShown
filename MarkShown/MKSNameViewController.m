//
//  MKSEditViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSNameViewController.h"

//
// TODO: abstraction of macros
//

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

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
    self.markShowStyle.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the user interface for the detail item.
    if (self.markShowItem) {
        [self.markShowName setText:[[self.markShowItem valueForKey:@"presentationName"] description]];
        [self.markShowName becomeFirstResponder];
        
        NSString *styleName = [[self.markShowItem valueForKey:@"presentationStyle"] description];
        NSInteger styleIndex = [self.markShowStyles indexOfObject:styleName];
        [self.markShowStyle selectRow:styleIndex inComponent:0 animated:NO];
    }
    self.nameView.backgroundColor = UIColorFromRGB([@0xEFEFF4 integerValue]);
    self.nameContainerView.backgroundColor = [UIColor whiteColor];
    self.markShowName.backgroundColor = [UIColor whiteColor];
    self.markShowStyle.backgroundColor = [UIColor whiteColor];
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

- (IBAction)endMarkShowName:(id)sender {
    // on keyboard done button press go back to main view
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.markShowName resignFirstResponder];
}

#pragma mark Picker DataSource/Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.markShowStyles count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.markShowStyles objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.markShowName resignFirstResponder];
    [self.markShowItem setValue:[[self.markShowStyles objectAtIndex:row] description] forKey:@"presentationStyle"];
}

@end
