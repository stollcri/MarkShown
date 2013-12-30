//
//  MKSStyleViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 12/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSStyleViewController.h"

@interface MKSStyleViewController ()

@end

@implementation MKSStyleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update the user interface for the detail item.
    if (self.markShowItem) {
        //NSLog(@"%@", [[self.markShowItem valueForKey:@"presentationCSS"] description]);
        //[self.textView setText:[[self.markShowItem valueForKey:@"presentationCSS"] description]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
