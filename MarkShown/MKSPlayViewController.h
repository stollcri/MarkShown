//
//  MKSPlayViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/22/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSPlayViewController : UIViewController <UIGestureRecognizerDelegate, UIWebViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSString *markShowSlidesText;
@property (strong, nonatomic) NSString *markShowSlidesStyle;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)didPressRefresh:(id)sender;


@end
