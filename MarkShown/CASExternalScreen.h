//
//  CASHandleExternalScreen.h
//  MarkShown
//
//  Created by Christopher Stoll on 10/2/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CASExternalScreen : NSObject

@property (strong, nonatomic) UIWindow *secondWindow;

- (void)setUpScreenConnectionNotificationHandlers;
- (void)checkForExistingScreenAndInitializeIfPresent;
- (void)tearDownScreenConnectionNotificationHandlers;

@end
