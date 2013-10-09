//
//  MKSDetailViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSEditViewController.h"
#import "MKSPlayViewController.h"

@interface MKSEditViewController ()
- (void)saveMarkShowContent;
@end

#pragma mark - Edit the content of the MarkShow

@implementation MKSEditViewController

@synthesize markShowItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Update the user interface for the detail item.
    if (self.markShowItem) {
        self.markShowContent.text = [[self.markShowItem valueForKey:@"presentationContent"] description];
    }
    [self setUpKeyboardNotificationHandlers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveMarkShowContent];
    [super viewWillDisappear:animated];
}

- (void)setUpKeyboardNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)tearDownScreenConnectionNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.markShowContent.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.markShowContent.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self saveMarkShowContent];
    [self.markShowContent resignFirstResponder];
    if ([[segue identifier] isEqualToString:@"showPlay"]){
        NSString *presentationContent = [[self.markShowItem valueForKey:@"presentationContent"] description];
        [[segue destinationViewController] setMarkShowSlidesText:presentationContent];
        
        NSString *presentationStyle = [[self.markShowItem valueForKey:@"presentationStyle"] description];
        [[segue destinationViewController] setMarkShowSlidesStyle:presentationStyle];
    }
}

- (void)saveMarkShowContent {
    if (self.markShowItem) {
        // save the edited value
        [self.markShowItem setValue:[self.markShowContent text] forKey:@"presentationContent"];
    }
}

@end
