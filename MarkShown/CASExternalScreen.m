//
//  CASHandleExternalScreen.m
//  MarkShown
//
//  Created by Christopher Stoll on 10/2/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "CASExternalScreen.h"

@implementation CASExternalScreen

- (void)setUpScreenConnectionNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(ScreenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
}

- (void)tearDownScreenConnectionNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}


- (void)screenDidConnect:(NSNotification*)notification {
    if (!self.secondWindow) {
        // Set the initial UI for the window.
        [self checkForExistingScreenAndInitializeIfPresent];
    }
}

- (void)ScreenDidDisconnect:(NSNotification*)notification {
    if (self.secondWindow) {
        // Hide and then delete the window.
        self.secondWindow.hidden = YES;
        self.secondWindow = nil;
    }
}

- (void)checkForExistingScreenAndInitializeIfPresent {
    if ([[UIScreen screens] count] > 1) {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        // Get the screen's bounds so that you can create a window of the correct size.
        CGRect screenBounds = secondScreen.bounds;
        
        // get the second screen's modes
        NSArray *availableModes = [secondScreen availableModes];
        // get the highest available resolution
        NSInteger selectedRow = [availableModes count] - 1;
        // set the screen mode to the highest avilable resolution
        secondScreen.currentMode = [availableModes objectAtIndex:selectedRow];
        // set overscan compensation
        secondScreen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
        
        self.secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        self.secondWindow.backgroundColor = [UIColor whiteColor];
        self.secondWindow.screen = secondScreen;
        
        // Set up initial content to display...
        // Show the window.
        self.secondWindow.hidden = NO;
    }
}

@end
