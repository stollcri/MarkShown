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
@property (strong, nonatomic) NSMutableArray *markShowSlidesImages;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panLeft;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *panRight;
@property (nonatomic, strong) UIImageView *defaultImage;
@property (nonatomic, strong) UIImageView *animationImage1;
@property (nonatomic, strong) UIImageView *animationImage2;
@property (strong, nonatomic) UIWebView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;

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
    [self setDefaultImage];
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
    [self clearSlideImageCache];
}

#pragma mark - Markshown Methods

- (void)preparePresentationData {
    NSMutableArray *slidesSlides = [[NSMutableArray alloc] init];
    NSMutableArray *slidesNotes = [[NSMutableArray alloc] init];
    NSMutableArray *slidesImgs = [[NSMutableArray alloc] init];
    
    NSArray *slides = [self.markShowSlidesText componentsSeparatedByString:@"\n\n\n\n"];
    for (NSString *slide in slides) {
        NSArray *slidesSplit = [slide componentsSeparatedByString:@"\n\n\n"];
        [slidesSlides addObject:[self getHTML:slidesSplit[0]]];
        if ([slidesSplit count] > 1) {
            [slidesNotes addObject:[self getHTML:slidesSplit[1]]];
        }else{
            [slidesNotes addObject:[self getHTML:slidesSplit[0]]];
        }
        [slidesImgs addObject:[NSNull null]];
    }
    
    self.markShowSlides = slidesSlides;
    self.markShowSlidesImages = slidesImgs;
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

- (void)setDefaultImage {
    // TODO: is there are way to get the actual images?
    // can we create a UIWebView in Memory and grab the images from there?
    UIGraphicsBeginImageContext(self.webView.frame.size);
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *grab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.defaultImage = [[UIImageView alloc] initWithImage:grab];
    self.defaultImage.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
    self.defaultImage.layer.shadowOpacity = 0.5;
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
    
    NSString *presentationNotes = [self.markShowPresenterNotes objectAtIndex:page];
    [self.webView loadHTMLString:presentationNotes baseURL:nil];
    
    NSString *presentationSlides = [NSString stringWithFormat:@"%@%@%@%@%@", @"<html><head><style type='text/css'>", self.markShowSlidesStyle, @"</style></head><body>", [self.markShowSlides objectAtIndex:page], @"</body></html>"];
    NSLog(@"%@", presentationSlides);
    [self.airPlayView loadHTMLString:presentationSlides baseURL:nil];
}

- (void)clearSlideImageCache {
    for (int i=0; i<self.markShowSlidesImages.count; ++i) {
        self.markShowSlidesImages[i] = [NSNull null];
    }
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
    if ((self.currentPage <= 0) & (!self.webView.canGoBack)) {
        return;
    }
    if (self.webView.canGoBack) {
        // TODO: this needs to be pretier
        [self.webView goBack];
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
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.markShowSlidesImages[self.currentPage] == [NSNull null]) {
            UIGraphicsBeginImageContext(self.webView.frame.size);
            [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *grab = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *currentWindow = [[UIImageView alloc] initWithImage:grab];
            currentWindow.layer.shadowOffset = CGSizeMake(-1.0, -1.0);
            currentWindow.layer.shadowOpacity = 0.5;
            self.markShowSlidesImages[self.currentPage] = currentWindow;
        }
        
        [self removeAnimationChildren];
        
        if (side == PAN_FROM_LEFT) {
            
            if (self.markShowSlidesImages[self.currentPage-1] == [NSNull null]) {
                _animationImage1 = self.defaultImage;
            }else{
                _animationImage1 = self.markShowSlidesImages[self.currentPage-1];
            }
            
            _animationImage2 = self.markShowSlidesImages[self.currentPage];
            
            _animationImage1.frame = self.webView.frame;
            _animationImage1.userInteractionEnabled = YES;
            [self.view addSubview:_animationImage1];
            
            _animationImage2.frame = self.webView.frame;
            _animationImage2.userInteractionEnabled = YES;
            [self.view addSubview:_animationImage2];
        }else{
            //_animationImage1 = self.markShowSlidesImages[self.currentPage];
            
            if (self.markShowSlidesImages[self.currentPage+1] == [NSNull null]) {
                _animationImage2 = self.defaultImage;
            }else{
                _animationImage2 = self.markShowSlidesImages[self.currentPage+1];
            }
            
            _animationImage2.frame = self.webView.frame;
            _animationImage2.userInteractionEnabled = YES;
            [self.view addSubview:_animationImage2];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        _animationImage2.frame = CGRectMake([gesture locationInView:_animationImage2.superview].x, _animationImage2.frame.origin.y, _animationImage2.frame.size.width, _animationImage2.frame.size.height);
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat xPosition = [gesture locationInView:_animationImage2.superview].x;
        CGFloat viewWidth = _animationImage2.superview.frame.size.width;
        // TODO: make the pan stick at 40% or so instead of half way
        CGFloat xMidpoint = floorf(viewWidth / 2);
        
        [self addAnimationChild:[gesture locationInView:_animationImage2.superview].x];
        
        if (side == PAN_FROM_LEFT) {
            if (xPosition > xMidpoint) {
                [self setPage:self.currentPage - 1];
            }
        } else {
            if (xPosition < xMidpoint) {
                [self setPage:self.currentPage + 1];
            }
        }
    }
}

- (void)addAnimationChild:(CGFloat)withXPosition {
    CGFloat xPosition = withXPosition;
    CGFloat viewWidth = _animationImage2.superview.frame.size.width;
    CGFloat xMidpoint = floorf(viewWidth / 2);
    CGFloat animationDistance = xMidpoint - abs(xMidpoint - xPosition);
    CGFloat animationFactor = animationDistance / xMidpoint;
    NSTimeInterval animationDuration = SLIDE_ANIMATION_TIME * animationFactor;
    
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size = _animationImage2.frame.size;
    newTextViewFrame.origin = _animationImage2.frame.origin;
    
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
    
    _animationImage2.frame = newTextViewFrame;
    
    [UIView commitAnimations];
}

- (void)removeAnimationChildren {
    if (_animationImage2) {
        [_animationImage2 removeFromSuperview];
    }
    
    if (_animationImage1) {
        [_animationImage1 removeFromSuperview];
    }
}

@end
