//
//  MKSDetailViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/18/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSEditViewController.h"
#import "MKSPlayViewController.h"
#import "CASColorMacros.h"

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
        self.markShowContent.inputAccessoryView = self.accessoryView;
        
        self.accessoryView.backgroundColor = [UIColor colorWithRed:((float)((0xDCDFE2 & 0xFF0000) >> 16))/255.0 green:((float)((0xDCDFE2 & 0xFF00) >> 8))/255.0 blue:((float)(0xDCDFE2 & 0xFF))/255.0 alpha:1.0];
        
        self.hashButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        self.slashButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        self.asteriskButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        self.underscoreButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        self.strikethroughButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        self.doubleAsteriskButton.backgroundColor = UIColorFromRGB([@0xFDFDFD integerValue]);
        
        //
        // TODO: add abstraction or refactor?
        //
        CALayer *layerHashButton = [self.hashButton layer];
        [layerHashButton setCornerRadius:5.0];
        CGSize sizeHashButton = self.underscoreButton.bounds.size;
        CGRect rectHashButton = CGRectMake(0.0f, 4.0f, sizeHashButton.width - 0, sizeHashButton.height);
        UIBezierPath *pathHashButton = [UIBezierPath bezierPathWithRoundedRect:rectHashButton cornerRadius:5.0];
        [layerHashButton setShadowPath:pathHashButton.CGPath];
        [layerHashButton setShadowRadius:0.0];
        [layerHashButton setShadowOpacity:5.0];
        [layerHashButton setShadowColor:[UIColor lightGrayColor].CGColor];
        
        CALayer *layerslashButton = [self.slashButton layer];
        [layerslashButton setCornerRadius:5.0];
        CGSize sizeSlashButton = self.underscoreButton.bounds.size;
        CGRect rectSlashButton = CGRectMake(0.0f, 4.0f, sizeSlashButton.width - 0, sizeSlashButton.height);
        UIBezierPath *pathSlashButton = [UIBezierPath bezierPathWithRoundedRect:rectSlashButton cornerRadius:5.0];
        [layerslashButton setShadowPath:pathSlashButton.CGPath];
        [layerslashButton setShadowRadius:0.0];
        [layerslashButton setShadowOpacity:5.0];
        [layerslashButton setShadowColor:[UIColor lightGrayColor].CGColor];
        
        CALayer *layerAsteriskButton = [self.asteriskButton layer];
        [layerAsteriskButton setCornerRadius:5.0];
        CGSize sizeAsteriskButton = self.underscoreButton.bounds.size;
        CGRect rectAsteriskButton = CGRectMake(0.0f, 4.0f, sizeAsteriskButton.width - 0, sizeAsteriskButton.height);
        UIBezierPath *pathAsteriskButton = [UIBezierPath bezierPathWithRoundedRect:rectAsteriskButton cornerRadius:5.0];
        [layerAsteriskButton setShadowPath:pathAsteriskButton.CGPath];
        [layerAsteriskButton setShadowRadius:0.0];
        [layerAsteriskButton setShadowOpacity:5.0];
        [layerAsteriskButton setShadowColor:[UIColor lightGrayColor].CGColor];
        
        CALayer *layerUnderlineButton = [self.underscoreButton layer];
        [layerUnderlineButton setCornerRadius:5.0];
        CGSize sizeUnderlineButton = self.underscoreButton.bounds.size;
        CGRect rectUnderlineButton = CGRectMake(0.0f, 4.0f, sizeUnderlineButton.width - 0, sizeUnderlineButton.height);
        UIBezierPath *pathUnderlineButton = [UIBezierPath bezierPathWithRoundedRect:rectUnderlineButton cornerRadius:5.0];
        [layerUnderlineButton setShadowPath:pathUnderlineButton.CGPath];
        [layerUnderlineButton setShadowRadius:0.0];
        [layerUnderlineButton setShadowOpacity:5.0];
        [layerUnderlineButton setShadowColor:[UIColor lightGrayColor].CGColor];
        
        CALayer *layerStrikethroughButton = [self.strikethroughButton layer];
        [layerStrikethroughButton setCornerRadius:5.0];
        CGSize sizeStrikethroughButton = self.strikethroughButton.bounds.size;
        CGRect rectStrikethroughButton = CGRectMake(0.0f, 4.0f, sizeStrikethroughButton.width - 0, sizeStrikethroughButton.height);
        UIBezierPath *pathStrikethroughButton = [UIBezierPath bezierPathWithRoundedRect:rectStrikethroughButton cornerRadius:5.0];
        [layerStrikethroughButton setShadowPath:pathStrikethroughButton.CGPath];
        [layerStrikethroughButton setShadowRadius:0.0];
        [layerStrikethroughButton setShadowOpacity:5.0];
        [layerStrikethroughButton setShadowColor:[UIColor lightGrayColor].CGColor];
        
        CALayer *layerDoubleAsteriskButton = [self.doubleAsteriskButton layer];
        [layerDoubleAsteriskButton setCornerRadius:5.0];
        CGSize sizeDoubleAsteriskButton = self.doubleAsteriskButton.bounds.size;
        CGRect rectDoubleAsteriskButton = CGRectMake(0.0f, 4.0f, sizeDoubleAsteriskButton.width - 0, sizeDoubleAsteriskButton.height);
        UIBezierPath *pathDoubleAsteriskButton = [UIBezierPath bezierPathWithRoundedRect:rectDoubleAsteriskButton cornerRadius:5.0];
        [layerDoubleAsteriskButton setShadowPath:pathDoubleAsteriskButton.CGPath];
        [layerDoubleAsteriskButton setShadowRadius:0.0];
        [layerDoubleAsteriskButton setShadowOpacity:5.0];
        [layerDoubleAsteriskButton setShadowColor:[UIColor lightGrayColor].CGColor];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
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

- (IBAction)tappedStrikethrough:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"--";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (IBAction)tappedDoubleAsterisk:(id)sender {
    // Get a reference to the system pasteboard
    UIPasteboard* lPasteBoard = [UIPasteboard generalPasteboard];
    
    // Save the current pasteboard contents so we can restore them later
    NSArray* lPasteBoardItems = [lPasteBoard.items copy];
    
    // Update the system pasteboard with my string
    lPasteBoard.string = @"**";
    
    // Paste the pasteboard contents at current cursor location
    [self.markShowContent paste:self];
    
    // Restore original pasteboard contents
    lPasteBoard.items = lPasteBoardItems;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

@end
