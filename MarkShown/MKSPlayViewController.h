//
//  MKSPlayViewController.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/22/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKSSlideView.h"

@interface MKSPlayViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) NSString *markShowSlidesText;
@property (strong, nonatomic) NSString *markShowSlidesStyle;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
