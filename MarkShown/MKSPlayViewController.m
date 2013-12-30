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
#define SLIDE_MARGIN_SCREEN0 20
#define SLIDE_MARGIN_SCREEN1 40
#define PAN_FROM_LEFT 0
#define PAN_FROM_RIGHT 1
#define DEFAULT_DIAGONAL 800

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

@property (strong, nonatomic) NSDictionary *markShowSlideStyle;
@property (strong, nonatomic) NSDictionary *markShowNoteStyle;
@property (strong, nonatomic) NSMutableArray *pageViews;

@property (strong, nonatomic) MKSSlideView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;
/*
- (NSString *)getHTML:(NSString*)fromMarkdown;
- (void)preparePresentationData;
- (void)setDefaultImage;
- (void)setPageControls;
- (void)setPage:(NSInteger)page;
*/
/*
- (void)preparePages;
- (void)prepareExternalExternalScreen;
- (void)getStyleInformation:(NSString *)styleName;
- (void)setPageSize;
- (void)purgePage:(NSInteger)page;
- (void)loadVisiblePages:(BOOL)purgeAllExistingPages;
- (void)loadPageForAirPlay:(NSInteger)page;
- (void)unloadPageForAirPlay;
*/
/*
- (void)didPanFromLeft:(UIScreenEdgePanGestureRecognizer*)gesture;
- (void)didPanFromRight:(UIScreenEdgePanGestureRecognizer*)gesture;
- (void)didPan:(UIScreenEdgePanGestureRecognizer*)gesture fromSide:(NSInteger)side;
- (void)addAnimationChild:(CGFloat)withXPosition;
- (void)removeAnimationChildren;
*/
@end

#pragma mark - Play the MarkShow

@implementation MKSPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self preparePresentationData];
    [self setDefaultImage];
    [self setPageControls];
    [self setPage:0];
    [self prepareExternalExternalScreen];
    //[self getStyleInformation:self.markShowSlidesStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // don't sleep while we are playing a slideshow
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self setPageSize];
    //[self loadVisiblePages:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    // the app can sleap when it is not playing a slideshow
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    //[self unloadPageForAirPlay];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self.externalScreen tearDownScreenConnectionNotificationHandlers];
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //[self setPageSize];
    //[self loadVisiblePages:YES];
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

- (void)setDefaultImage {
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
    
    NSString *pageString = [self.markShowSlides objectAtIndex:page];
    [self.webView loadHTMLString:pageString baseURL:nil];
}







- (void)prepareExternalExternalScreen {
    self.externalScreen = [[CASExternalScreen alloc] init];
    [self.externalScreen setUpScreenConnectionNotificationHandlers];
    [self.externalScreen checkForExistingScreenAndInitializeIfPresent];
}

/*
- (void)getStyleInformation:(NSString *)styleName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MKSSlideStyles" ofType:@"plist"];
    NSDictionary *stylesRoot = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *styleRoot = stylesRoot[styleName];
    self.markShowSlideStyle = styleRoot[@"slides"];
    self.markShowNoteStyle = styleRoot[@"notes"];
}
*/
/*
- (void)setPageSize {
    CGSize contentSize = self.webView.frame.size;
    //[self.webView setContentSize:CGSizeMake(contentSize.width * self.markShowSlides.count, contentSize.height)];
}
*/
/*
- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.markShowSlides.count) {
        return;
    }

    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.webView.bounds;
        frame.origin.x = ( frame.size.width * page ) + SLIDE_MARGIN_SCREEN0;
        frame.origin.y = SLIDE_MARGIN_SCREEN0;
        frame.size.width = frame.size.width - (SLIDE_MARGIN_SCREEN0 * 2);
        frame.size.height = frame.size.height - (SLIDE_MARGIN_SCREEN0 * 2);
        
        MKSSlideView *newPageView = [[MKSSlideView alloc] initWithFrame:frame];
        
        NSDictionary *styleSheet = self.markShowNoteStyle;
        NSNumber *currentBackgroundColor = styleSheet[@"backgroundColor"];
        
        //NSAttributedString *markShownSlide = [CASMarkdownParser attributedStringFromMarkdown:[self.markShowPresenterNotes objectAtIndex:page] withStyleSheet:self.markShowNoteStyle andScale:@1];
        [newPageView setSlideContents:markShownSlide];
        [newPageView setBackgroundColor:[UIColor whiteColor]];
        
        [newPageView setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];
        //[self.scrollView setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];

        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}
*/
/*
- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.markShowSlides.count) {
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}
*/
/*
- (void)loadVisiblePages:(BOOL)purgeAllExistingPages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 2;
    NSInteger lastPage = page + 2;
    
    if (purgeAllExistingPages) {
        for (NSInteger i=0; i<self.markShowSlides.count; i++) {
            [self purgePage:i];
        }
    }else{
        // Purge anything before the first page
        for (NSInteger i=0; i<firstPage; i++) {
            [self purgePage:i];
        }
        
        // Purge anything after the last page
        for (NSInteger i=lastPage+1; i<self.markShowSlides.count; i++) {
            [self purgePage:i];
        }
    }
    
	// Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
    // Load the airplay page
    //[self loadPageForAirPlay:page];
}
 */
/*
- (void)loadPageForAirPlay:(NSInteger)page {
    CGRect frame = self.externalScreen.secondWindow.bounds;
    
    double diagonalLength = sqrt((frame.size.width * frame.size.width) + (frame.size.height * frame.size.height));
    NSNumber *fontScale = [NSNumber numberWithDouble:(diagonalLength / DEFAULT_DIAGONAL)];
    
    frame.origin.x = floor(SLIDE_MARGIN_SCREEN1 * [fontScale doubleValue]);
    frame.origin.y = floor(SLIDE_MARGIN_SCREEN1 * [fontScale doubleValue]);
    frame.size.width = frame.size.width - (floor(SLIDE_MARGIN_SCREEN1 * [fontScale doubleValue]) * 2);
    frame.size.height = frame.size.height - (floor(SLIDE_MARGIN_SCREEN1 * [fontScale doubleValue]) * 2);
    self.airPlayView = [[MKSSlideView alloc] initWithFrame:frame];
    
    NSAttributedString *markShownSlide = [CASMarkdownParser attributedStringFromMarkdown:[self.markShowSlides objectAtIndex:page] withStyleSheet:self.markShowSlideStyle andScale:fontScale];
    
    NSMutableAttributedString *pageCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i", (int)(page+1)]];
    
    NSRange pageCountRange = NSMakeRange(0, [pageCount length]);
    NSDictionary *styleSheet = self.markShowSlideStyle;
    NSNumber *currentBackgroundColor = styleSheet[@"backgroundColor"];
    NSDictionary *currentTypeStyle = styleSheet[@"footer"];
    NSString *currentFontFace = currentTypeStyle[@"font"];
    NSNumber *currentFontSize = currentTypeStyle[@"size"];
    NSNumber *currentFontColor = currentTypeStyle[@"color"];
    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
    currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
    
    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
    [pageCount addAttribute:NSFontAttributeName value:currentFont range:pageCountRange];
    [pageCount addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB([currentFontColor integerValue]) range:pageCountRange];
    
    if ([currentParagraphAlign isEqualToNumber:@1]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentCenter;
        [pageCount addAttribute:NSParagraphStyleAttributeName value:paragraph range:pageCountRange];
    }else if([currentParagraphAlign isEqualToNumber:@2]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentRight;
        [pageCount addAttribute:NSParagraphStyleAttributeName value:paragraph range:pageCountRange];
    }
     
    [self.airPlayView setSlideContents:markShownSlide];
    [self.airPlayView setSlideFooterCenter:pageCount];
    
    [self.airPlayView setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];
    [self.externalScreen.secondWindow setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];
    
    [self.externalScreen.secondWindow addSubview:self.airPlayView];
}
*/
/*
- (void)unloadPageForAirPlay {
    if (self.externalScreen.secondWindow) {
        self.externalScreen.secondWindow.hidden = YES;
        self.externalScreen.secondWindow = nil;
    }
}
*/


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
