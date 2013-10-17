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
    //[center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)tearDownScreenConnectionNotificationHandlers {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //[center removeObserver:self name:UIScreenDidConnectNotification object:nil];
    //[center removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
    [center removeObserver:self name:nil object:nil];
}
/*
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
*/
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

#pragma mark - Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    // you can create the accessory view programmatically (in code), or from the storyboard
    if (self.markShowContent.inputAccessoryView == nil) {
        NSLog(@"tada");
        self.markShowContent.inputAccessoryView = self.accessoryView;
        self.accessoryView.backgroundColor = [UIColor colorWithRed:0xDC green:0xDF blue:0xE2 alpha:1.0f];
        self.accessoryView.backgroundColor = [UIColor colorWithRed:((float)((0xDCDFE2 & 0xFF0000) >> 16))/255.0 green:((float)((0xDCDFE2 & 0xFF00) >> 8))/255.0 blue:((float)(0xDCDFE2 & 0xFF))/255.0 alpha:1.0];
    }
    
   // self.navigationItem.rightBarButtonItem = self.doneButton;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    /*
    [aTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = self.editButton;
    */
    return YES;
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's
    // coordinate system. The bottom of the text view's frame should align with the top
    // of the keyboard's final position.
    //
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

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.markShowContent.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

#pragma mark - Accessory view action

- (IBAction)tappedHash:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"#";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (IBAction)tappedSlash:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"//";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (IBAction)tappedAsterisk:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"*";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (IBAction)tappedUnderscore:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"__";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

@end
