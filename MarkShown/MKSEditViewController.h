//
//  MKSDetailViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSEditViewController : UIViewController

@property (strong, nonatomic) id markShowItem;
@property (weak, nonatomic) IBOutlet UITextView *markShowContent;

@end
