//
//  MKSDetailViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSEditViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) id markShowItem;
@property (weak, nonatomic) IBOutlet UITextView *markShowContent;
@property (nonatomic, weak) IBOutlet UIView *accessoryView;

- (IBAction)tappedHash:(id)sender;
- (IBAction)tappedSlash:(id)sender;
- (IBAction)tappedAsterisk:(id)sender;
- (IBAction)tappedUnderscore:(id)sender;

@end
