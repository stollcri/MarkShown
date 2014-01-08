//
//  MKSEditViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSNameViewController : UITableViewController

@property (strong, nonatomic) id markShowItem;
@property (weak, nonatomic) NSArray *markShowStyles;

@property (weak, nonatomic) IBOutlet UITextField *markShowName;

- (IBAction)endMarkShowName:(id)sender;

@end
