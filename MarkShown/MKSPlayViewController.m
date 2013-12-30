//
//  MKSPlayViewController.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/22/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

//
// TODO: Figure out why views are too large on first load

#import "MKSPlayViewController.h"
#import "markdown.h"
#import "CASExternalScreen.h"

#define SLIDE_ANIMATION_TIME 0.25
#define PAN_FROM_LEFT 0
#define PAN_FROM_RIGHT 1

@interface MKSPlayViewController ()

@property (nonatomic) int currentPage;
@property (strong, nonatomic) NSArray *markShowSlides;
@property (strong, nonatomic) NSArray *markShowPresenterNotes;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panLeft;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panRight;
@property (nonatomic, strong) UIImageView *defaultImage;
@property (nonatomic, strong) UIWebView *animationView1;
@property (nonatomic, strong) UIWebView *animationView2;
@property (strong, nonatomic) UIWebView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;
@property (nonatomic) BOOL navigatedToWeb;

@property (strong, nonatomic) NSDictionary *markShowSlideStyle;
@property (strong, nonatomic) NSDictionary *markShowNoteStyle;

@end

#pragma mark - Play the MarkShow

@implementation MKSPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self preparePresentationData];
    [self prepareExternalExternalScreen];
    [self prepareAnimationViews];
    [self setPageControls];
    [self setPage:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // don't sleep while we are playing a slideshow
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    // the app can sleap when it is not playing a slideshow
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self freeExternalScreen];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self.externalScreen tearDownScreenConnectionNotificationHandlers];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //
}

#pragma mark - Markshown Methods

- (void)preparePresentationData {
    NSMutableArray *slidesSlides = [[NSMutableArray alloc] init];
    NSMutableArray *slidesNotes = [[NSMutableArray alloc] init];
    
    NSArray *slides = [self.markShowSlidesText componentsSeparatedByString:@"\n\n\n\n"];
    for (NSString *slide in slides) {
        NSArray *slidesSplit = [slide componentsSeparatedByString:@"\n\n\n"];
        [slidesSlides addObject:[self getHTML:slidesSplit[0]]];
        if ([slidesSplit count] > 1) {
            [slidesNotes addObject:[self getHTML:slidesSplit[1]]];
        }else{
            [slidesNotes addObject:[self getHTML:slidesSplit[0]]];
        }
    }
    
    self.markShowSlides = slidesSlides;
    self.markShowPresenterNotes = slidesNotes;
}

- (NSString *)getHTML:(NSString*)fromMarkdown {
    const char *pageChars = [fromMarkdown UTF8String];
    
    // generate Discount document
    Document *markdownIntermediate;
    markdownIntermediate = mkd_string(pageChars, (int)strlen(pageChars), 0);
    mkd_compile(markdownIntermediate, 0);
    
    // generate HTML from Discount document
    char *markdownHTML = NULL;
    if (mkd_document(markdownIntermediate, &markdownHTML)) {
        return [NSString stringWithUTF8String:markdownHTML];
    }else{
        return fromMarkdown;
    }
}

- (void)prepareAnimationViews {
    _animationView1 = [[UIWebView alloc] initWithFrame:self.webView.bounds];
    _animationView2 = [[UIWebView alloc] initWithFrame:self.webView.bounds];
}

- (void)setPageControls {
    self.panLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromLeft:)];
    self.panLeft.edges = UIRectEdgeLeft;
    [self.webView addGestureRecognizer:self.panLeft];
    
    self.panRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromRight:)];
    self.panRight.edges = UIRectEdgeRight;
    [self.webView addGestureRecognizer:self.panRight];
}

- (void)setPage:(NSInteger)page {
    if (page < 0 || page >= self.markShowSlides.count) {
        return;
    }
    self.currentPage = page;
    self.navigatedToWeb = NO;
    
    NSString *presentationNotes = [self.markShowPresenterNotes objectAtIndex:page];
    [self.webView loadHTMLString:presentationNotes baseURL:nil];
    
    NSString *presentationSlides = [NSString stringWithFormat:@"%@%@%@%@%@", @"<html><head><style type='text/css'>", self.markShowSlidesStyle, @"</style></head><body>", [self.markShowSlides objectAtIndex:page], @"</body></html>"];
    [self.airPlayView loadHTMLString:presentationSlides baseURL:nil];
}

#pragma mark - External Screen

- (void)prepareExternalExternalScreen {
    self.externalScreen = [[CASExternalScreen alloc] init];
    [self.externalScreen setUpScreenConnectionNotificationHandlers];
    [self.externalScreen checkForExistingScreenAndInitializeIfPresent];
    
    self.airPlayView = [[UIWebView alloc] initWithFrame:self.externalScreen.secondWindow.bounds];
    [self.externalScreen.secondWindow addSubview:self.airPlayView];
    self.airPlayView.scalesPageToFit = NO;
    [self.airPlayView stringByEvaluatingJavaScriptFromString:@"document. body.style.zoom = 20.0;"];
}

- (void)freeExternalScreen {
    if (self.externalScreen.secondWindow) {
        self.externalScreen.secondWindow.hidden = YES;
        self.externalScreen.secondWindow = nil;
    }
}

#pragma mark - Panning Gestures

- (void)didPanFromLeft:(UIScreenEdgePanGestureRecognizer*)gesture {
    // TODO: allow navigating back to the slide from a web page
    if ((self.currentPage <= 0) && (!self.navigatedToWeb)) {
        return;
    }
    
    if (self.navigatedToWeb) {
        [self didPan:gesture fromSide:PAN_FROM_LEFT usingDefaultImage:YES];
    }else{
        [self didPan:gesture fromSide:PAN_FROM_LEFT];
    }
}

- (void)didPanFromRight:(UIScreenEdgePanGestureRecognizer*)gesture {
    if ((self.currentPage + 1) >= self.markShowSlides.count) {
        return;
    }
    
    [self didPan:gesture fromSide:PAN_FROM_RIGHT];
}

- (void)didPan:(UIScreenEdgePanGestureRecognizer*)gesture fromSide:(NSInteger)side {
    [self didPan:gesture fromSide:side usingDefaultImage:NO];
}

- (void)didPan:(UIScreenEdgePanGestureRecognizer*)gesture fromSide:(NSInteger)side usingDefaultImage:(BOOL)useImageView  {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //[self removeAnimationChildren];
        
        if (side == PAN_FROM_LEFT) {
            if (!useImageView) {
                NSString *presentationNotes2 = [self.markShowPresenterNotes objectAtIndex:self.currentPage];
                [_animationView2 loadHTMLString:presentationNotes2 baseURL:nil];
                
                NSString *presentationNotes1 = [self.markShowPresenterNotes objectAtIndex:self.currentPage-1];
                [_animationView1 loadHTMLString:presentationNotes1 baseURL:nil];
            
                _animationView2.userInteractionEnabled = YES;
                _animationView2.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
                _animationView2.layer.shadowOpacity = 0.5;
                [self.view addSubview:_animationView2];
                
                _animationView1.userInteractionEnabled = YES;
                _animationView1.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
                _animationView1.layer.shadowOpacity = 0.5;
                [self.view insertSubview:_animationView1 belowSubview:_animationView2];
            
            // TODO: find a better way handle the image animation instances
            }else{
                NSString *presentationNotes1 = [self.markShowPresenterNotes objectAtIndex:self.currentPage];
                [_animationView1 loadHTMLString:presentationNotes1 baseURL:nil];
                
                UIGraphicsBeginImageContext(self.webView.frame.size);
                [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *grab = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                self.defaultImage = [[UIImageView alloc] initWithImage:grab];
                
                _defaultImage.userInteractionEnabled = YES;
                _defaultImage.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
                _defaultImage.layer.shadowOpacity = 0.5;
                [self.view addSubview:_defaultImage];
                
                _animationView1.userInteractionEnabled = YES;
                _animationView1.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
                _animationView1.layer.shadowOpacity = 0.5;
                [self.view insertSubview:_animationView1 belowSubview:_defaultImage];
            }
        }else{
            NSString *presentationNotes2 = [self.markShowPresenterNotes objectAtIndex:self.currentPage+1];
            [_animationView2 loadHTMLString:presentationNotes2 baseURL:nil];
            
            _animationView2.userInteractionEnabled = YES;
            _animationView2.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
            _animationView2.layer.shadowOpacity = 0.5;
            [self.view addSubview:_animationView2];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (!useImageView) {
            _animationView2.frame = CGRectMake([gesture locationInView:_animationView2.superview].x, _animationView2.frame.origin.y, _animationView2.frame.size.width, _animationView2.frame.size.height);
        }else{
            _defaultImage.frame = CGRectMake([gesture locationInView:_defaultImage.superview].x, _defaultImage.frame.origin.y, _defaultImage.frame.size.width, _defaultImage.frame.size.height);
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!useImageView) {
            CGFloat xPosition = [gesture locationInView:_animationView2.superview].x;
            CGFloat viewWidth = _animationView2.superview.frame.size.width;
            // TODO: make the pan stick at 40% or so instead of half way
            CGFloat xMidpoint = floorf(viewWidth / 2);
            
            if (side == PAN_FROM_LEFT) {
                if (xPosition > xMidpoint) {
                    [self setPage:self.currentPage - 1];
                }
            } else {
                if (xPosition < xMidpoint) {
                    [self setPage:self.currentPage + 1];
                }
            }
            
            [self finishPanAnimation:[gesture locationInView:_animationView2.superview].x usingDefaultImage:NO];
        
        // TODO: find a better way handle the image animation instances
        }else{
            CGFloat xPosition = [gesture locationInView:_defaultImage.superview].x;
            CGFloat viewWidth = _defaultImage.superview.frame.size.width;
            // TODO: make the pan stick at 40% or so instead of half way
            CGFloat xMidpoint = floorf(viewWidth / 2);
            
            if (xPosition > xMidpoint) {
                [self setPage:self.currentPage];
            }
            
            [self finishPanAnimation:[gesture locationInView:_defaultImage.superview].x usingDefaultImage:YES];
        }
    }
}

- (void)finishPanAnimation:(CGFloat)withXPosition usingDefaultImage:(BOOL)useImageView {
    if (!useImageView) {
        CGFloat xPosition = withXPosition;
        CGFloat viewWidth = _animationView2.superview.frame.size.width;
        CGFloat xMidpoint = floorf(viewWidth / 2);
        CGFloat animationDistance = xMidpoint - abs(xMidpoint - xPosition);
        CGFloat animationFactor = animationDistance / xMidpoint;
        NSTimeInterval animationDuration = SLIDE_ANIMATION_TIME * animationFactor;
        
        CGRect newTextViewFrame = self.view.bounds;
        newTextViewFrame.size = _animationView2.frame.size;
        newTextViewFrame.origin = _animationView2.frame.origin;
        
        if (xPosition > xMidpoint) {
            newTextViewFrame.origin.x = viewWidth;
        }else{
            newTextViewFrame.origin.x = 0;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(removeAnimationChildren)];
        
        _animationView2.frame = newTextViewFrame;
        
        [UIView commitAnimations];
    
    // TODO: find a better way handle the image animation instances
    }else{
        CGFloat xPosition = withXPosition;
        CGFloat viewWidth = _defaultImage.superview.frame.size.width;
        CGFloat xMidpoint = floorf(viewWidth / 2);
        CGFloat animationDistance = xMidpoint - abs(xMidpoint - xPosition);
        CGFloat animationFactor = animationDistance / xMidpoint;
        NSTimeInterval animationDuration = SLIDE_ANIMATION_TIME * animationFactor;
        
        CGRect newTextViewFrame = self.view.bounds;
        newTextViewFrame.size = _defaultImage.frame.size;
        newTextViewFrame.origin = _defaultImage.frame.origin;
        
        if (xPosition > xMidpoint) {
            newTextViewFrame.origin.x = viewWidth;
        }else{
            newTextViewFrame.origin.x = 0;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(removeAnimationChildren)];
        
        _defaultImage.frame = newTextViewFrame;
        
        [UIView commitAnimations];
    }
}

- (void)removeAnimationChildren {
    if (_animationView2) {
        [_animationView2 removeFromSuperview];
    }
    if (_animationView1) {
        [_animationView1 removeFromSuperview];
    }
    if (_defaultImage) {
        [_defaultImage removeFromSuperview];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%d, %@", navigationType, request);
    if (navigationType != UIWebViewNavigationTypeOther) {
        self.navigatedToWeb = YES;
        [self.airPlayView loadRequest:request];
        return NO;
    }
    return YES;
}

- (IBAction)didPressRefresh:(id)sender {
    [self setPage:self.currentPage];
}

@end
