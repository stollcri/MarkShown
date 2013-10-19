//
//  MKSEditViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSNameViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) id markShowItem;
@property (weak, nonatomic) NSArray *markShowStyles;

@property (strong, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *nameContainerView;
@property (weak, nonatomic) IBOutlet UITextField *markShowName;
@property (weak, nonatomic) IBOutlet UIPickerView *markShowStyle;

- (IBAction)endMarkShowName:(id)sender;

@end
