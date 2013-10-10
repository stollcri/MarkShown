//
//  MKSSlideView.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/28/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface MKSSlideView : UIView

@property (retain, nonatomic) NSAttributedString *slideContents;
@property (retain, nonatomic) NSAttributedString *slideFooterCenter;

@end
