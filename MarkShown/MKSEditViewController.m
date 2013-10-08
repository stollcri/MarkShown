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
        
        // DEBUG
        self.markShowContent.text = @"# Slide 1\n//Italics// __Underline__ **Bold**\n--Lorem-- --ipsum_dolor-- sit amet/bmet (#2 * # 2), consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. \n\n\n# Slide 1 Notes H1\n## Slide 1 Notes H2\n//Italics// __Underline__ **Bold** \nDuis --aute-- irure_dolor in #1 reprehenderit / in voluptate velit esse cillum\n###Slide 1 Notes H3\ndolore eu fugiat nulla pariatur (*2).\n* one\n- two\n*thrre\n-four\n_five \n\n\n\n#Slide 2 \nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. //Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \n\n\n\n## Slide 3 \nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \n\n\n\n# Slide 4 \nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
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
    [center addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)tearDownScreenConnectionNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification {
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

- (void)keyboardWillBeHidden:(NSNotification*)notification {
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
