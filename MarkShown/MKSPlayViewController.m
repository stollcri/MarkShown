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
#define SCROLL_FACTOR 16

@interface MKSPlayViewController ()

@property (nonatomic) int currentPage;
@property (strong, nonatomic) NSArray *markShowSlides;
@property (strong, nonatomic) NSArray *markShowPresenterNotes;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panLeft;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panRight;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRight;
@property (strong, nonatomic) UIWebView *animationView;
@property (strong, nonatomic) UIWebView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;
@property (strong, nonatomic) NSString *scaleFactor;

@property CGPoint scrollBegin;
@property CGPoint scrollEnd;
@property BOOL scrolling;
@property BOOL scrollDirectionKnown;
@property BOOL scrollDown;

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
    self.webView.scrollView.delegate = self;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.airPlayView.tag == 1) {
        self.scrolling = YES;
        self.scrollDirectionKnown = NO;
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.airPlayView.tag == 1) {
        self.scrolling = NO;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.airPlayView.tag == 1) {
        if (!self.scrollDirectionKnown) {
            if (scrollView.contentOffset.y < 0) {
                self.scrollDown = YES;
            } else if (scrollView.contentOffset.y > 0) {
                self.scrollDown = NO;
            }
            self.scrollDirectionKnown = YES;
        }
        
        if (self.scrolling) {
            CGPoint newOffset = self.airPlayView.scrollView.contentOffset;
            if (self.scrollDown) {
                if (self.airPlayView.scrollView.contentOffset.y >= SCROLL_FACTOR) {
                    newOffset.y -= SCROLL_FACTOR;
                    [self.airPlayView.scrollView setContentOffset:newOffset];
                }
            } else {
                newOffset.y += SCROLL_FACTOR;
                [self.airPlayView.scrollView setContentOffset:newOffset];
            }
        }
    }
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
     CGRect offScreen = CGRectMake(self.webView.bounds.size.width, self.webView.bounds.origin.y, self.webView.bounds.size.width, self.webView.bounds.size.height);
    _animationView = [[UIWebView alloc] initWithFrame:offScreen];
}

- (void)setPageControls {
    self.panLeft = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromLeft:)];
    self.panLeft.edges = UIRectEdgeLeft;
    [self.webView addGestureRecognizer:self.panLeft];
    
    self.panRight = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanFromRight:)];
    self.panRight.edges = UIRectEdgeRight;
    [self.webView addGestureRecognizer:self.panRight];
    
    self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.webView addGestureRecognizer:self.swipeLeft];
    
    self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:self.swipeRight];
}

- (void)setPage:(NSInteger)page {
    if (page < 0 || page >= self.markShowSlides.count) {
        return;
    }
    self.currentPage = (int)page;
    
    NSString *presentationNotes = [self.markShowPresenterNotes objectAtIndex:page];
    [self.webView loadHTMLString:presentationNotes baseURL:nil];
    
    NSString *presentationSlides = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", @"<html><head><meta name='viewport' content='width=device-width,initial-scale=", self.scaleFactor, @",minimum-scale=0.2,maximum-scale=5.0;user-scalable=0;' /><style type='text/css'>", self.markShowSlidesStyle, @"</style></head><body>", [self.markShowSlides objectAtIndex:page], @"</body></html>"];
    
    [self.airPlayView loadHTMLString:presentationSlides baseURL:nil];
}

#pragma mark - External Screen

- (NSString*)setScaleFactor {
    CGRect frame = self.externalScreen.secondWindow.bounds;
    double diagonalLength = sqrt((frame.size.width * frame.size.width) + (frame.size.height * frame.size.height));
    NSNumber *fontScale =  [NSNumber numberWithDouble:(diagonalLength / 500)];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundUp];
    NSString *numberString = [formatter stringFromNumber:fontScale];
    
    return numberString;
}

- (void)prepareExternalExternalScreen {
    self.externalScreen = [[CASExternalScreen alloc] init];
    [self.externalScreen setUpScreenConnectionNotificationHandlers];
    [self.externalScreen checkForExistingScreenAndInitializeIfPresent];
    
    self.airPlayView = [[UIWebView alloc] initWithFrame:self.externalScreen.secondWindow.bounds];
    self.airPlayView.scalesPageToFit = NO;
    self.airPlayView.scrollView.minimumZoomScale = 0.1;
    self.airPlayView.scrollView.maximumZoomScale = 4.0;
    self.airPlayView.tag = 0;
    [self.externalScreen.secondWindow addSubview:self.airPlayView];
    
    self.scaleFactor = [self setScaleFactor];
    self.airPlayView.delegate = self;
}

- (void)freeExternalScreen {
    if (self.externalScreen.secondWindow) {
        self.externalScreen.secondWindow.hidden = YES;
        [self.airPlayView removeFromSuperview];
        self.externalScreen.secondWindow = nil;
    }
}

#pragma mark - Swipping Gestures

- (void)didSwipeLeft:(UIScreenEdgePanGestureRecognizer*)gesture
{
    if ((self.currentPage + 1) >= self.markShowSlides.count) {
        return;
    }
    [self didPan:gesture fromSide:PAN_FROM_RIGHT withSwipe:YES];
}

- (void)didSwipeRight:(UIScreenEdgePanGestureRecognizer*)gesture
{
    if (self.currentPage <= 0) {
        return;
    }
    [self didPan:gesture fromSide:PAN_FROM_LEFT withSwipe:YES];
}

#pragma mark - Panning Gestures

- (void)didPanFromLeft:(UIScreenEdgePanGestureRecognizer*)gesture {
    if (self.currentPage <= 0) {
        return;
    }
    [self didPan:gesture fromSide:PAN_FROM_LEFT withSwipe:NO];
}

- (void)didPanFromRight:(UIScreenEdgePanGestureRecognizer*)gesture {
    if ((self.currentPage + 1) >= self.markShowSlides.count) {
        return;
    }
    [self didPan:gesture fromSide:PAN_FROM_RIGHT withSwipe:NO];
}

- (void)didPan:(UIScreenEdgePanGestureRecognizer*)gesture fromSide:(NSInteger)side withSwipe:(BOOL)swiped {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGRect onScreen = CGRectMake(self.webView.bounds.origin.x, self.webView.bounds.origin.y, self.webView.bounds.size.width, self.webView.bounds.size.height);
        CGRect offScreen = CGRectMake(self.webView.bounds.size.width, self.webView.bounds.origin.y, self.webView.bounds.size.width, self.webView.bounds.size.height);
        
        if (side == PAN_FROM_LEFT) {
            NSString *presentationNotes1 = [self.markShowPresenterNotes objectAtIndex:self.currentPage-1];
            // preset below to reduce flicker from page loading
            //NSString *presentationNotes2 = [self.markShowPresenterNotes objectAtIndex:self.currentPage];
            //[_animationView loadHTMLString:presentationNotes2 baseURL:nil];
            
            _animationView.frame = onScreen;
            _animationView.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
            _animationView.layer.shadowOpacity = 0.5;
            [self.view addSubview:_animationView];
            
            [self.webView loadHTMLString:presentationNotes1 baseURL:nil];
        }else{
            NSString *presentationNotes2 = [self.markShowPresenterNotes objectAtIndex:self.currentPage+1];
            [_animationView loadHTMLString:presentationNotes2 baseURL:nil];
            
            _animationView.frame = offScreen;
            _animationView.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
            _animationView.layer.shadowOpacity = 0.5;
            [self.view addSubview:_animationView];
        }
    
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        _animationView.frame = CGRectMake([gesture locationInView:_animationView.superview].x, _animationView.frame.origin.y, _animationView.frame.size.width, _animationView.frame.size.height);
        
    }else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat xPosition = [gesture locationInView:_animationView.superview].x;
        CGFloat viewWidth = _animationView.superview.frame.size.width;
        // TODO: make the pan stick at 40% or so instead of half way
        CGFloat xMidpoint = floorf(viewWidth / 2);
        
        if (swiped) {
            if (side == PAN_FROM_RIGHT) {
                [self setPage:self.currentPage + 1];
            } else {
                [self setPage:self.currentPage - 1];
            }
        } else {
            if (side == PAN_FROM_RIGHT) {
                if (xPosition < xMidpoint) {
                    [self setPage:self.currentPage + 1];
                }
            } else {
                if (xPosition > xMidpoint) {
                    [self setPage:self.currentPage - 1];
                }else{
                    [self setPage:self.currentPage];
                }
            }
        }
        
        [self finishPanAnimation:[gesture locationInView:_animationView.superview].x usingDefaultImage:NO];
    }
}

- (void)finishPanAnimation:(CGFloat)withXPosition usingDefaultImage:(BOOL)useImageView {
    CGFloat xPosition = withXPosition;
    CGFloat viewWidth = _animationView.superview.frame.size.width;
    CGFloat xMidpoint = floorf(viewWidth / 2);
    CGFloat animationDistance = xMidpoint - abs(xMidpoint - xPosition);
    CGFloat animationFactor = animationDistance / xMidpoint;
    NSTimeInterval animationDuration = SLIDE_ANIMATION_TIME * animationFactor;
    
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size = _animationView.frame.size;
    newTextViewFrame.origin = _animationView.frame.origin;
    
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
    
    _animationView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
    
    // preload for left to right pans (previous page) to reduce flicker
    NSString *presentationNotes2 = [self.markShowPresenterNotes objectAtIndex:self.currentPage];
    [_animationView loadHTMLString:presentationNotes2 baseURL:nil];
    self.airPlayView.tag = 0;
}

- (void)removeAnimationChildren {
    if (_animationView) {
        [_animationView removeFromSuperview];
    }
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType != UIWebViewNavigationTypeOther) {
        [self.airPlayView loadRequest:request];
        self.airPlayView.tag = 1;
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.tag == 1) {
        [self.airPlayView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 1.4;"];
    }
}

- (IBAction)didPressRefresh:(id)sender {
    [self.airPlayView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 1.0;"];
    [self setPage:self.currentPage];
    self.airPlayView.tag = 0;
}

@end
