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
#import "CASMarkdownParser.h"
#import "CASExternalScreen.h"

#define SLIDE_MARGIN_SCREEN0 20
#define SLIDE_MARGIN_SCREEN1 40

#define DEFAULT_DIAGONAL 800

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface MKSPlayViewController ()

@property (strong, nonatomic) NSArray *markShowSlides;
@property (strong, nonatomic) NSArray *markShowPresenterNotes;
@property (strong, nonatomic) NSDictionary *markShowSlideStyle;
@property (strong, nonatomic) NSDictionary *markShowNoteStyle;
@property (strong, nonatomic) NSMutableArray *pageViews;

@property (strong, nonatomic) MKSSlideView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;

- (void)prepareSlideData;
- (void)preparePages;
- (void)prepareExternalExternalScreen;
- (void)getStyleInformation:(NSString *)styleName;
- (void)setPageSize;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
- (void)loadVisiblePages:(BOOL)purgeAllExistingPages;
- (void)loadPageForAirPlay:(NSInteger)page;
- (void)unloadPageForAirPlay;

@end

#pragma mark - Play the MarkShow

@implementation MKSPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self prepareSlideData];
    [self preparePages];
    [self prepareExternalExternalScreen];
    [self getStyleInformation:self.markShowSlidesStyle];
    
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self setPageSize];
    //[self loadVisiblePages:NO];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setPageSize];
    [self loadVisiblePages:NO];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self unloadPageForAirPlay];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [self.externalScreen tearDownScreenConnectionNotificationHandlers];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadVisiblePages:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setPageSize];
    [self loadVisiblePages:YES];
}



- (void)prepareSlideData {
    NSMutableArray *slidesSlides = [[NSMutableArray alloc] init];
    NSMutableArray *slidesNotes = [[NSMutableArray alloc] init];
    NSArray *slides = [self.markShowSlidesText componentsSeparatedByString:@"\n\n\n\n"];
    for (NSString *slide in slides) {
        NSArray *slidesSplit = [slide componentsSeparatedByString:@"\n\n\n"];
        [slidesSlides addObject:slidesSplit[0]];
        if ([slidesSplit count] > 1) {
            [slidesNotes addObject:slidesSplit[1]];
        }else{
            [slidesNotes addObject:slidesSplit[0]];
        }
    }
    self.markShowSlides = slidesSlides;
    self.markShowPresenterNotes = slidesNotes;
}

- (void)preparePages {
    NSInteger pageCount = self.markShowSlides.count;
    
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)prepareExternalExternalScreen {
    self.externalScreen = [[CASExternalScreen alloc] init];
    [self.externalScreen setUpScreenConnectionNotificationHandlers];
    [self.externalScreen checkForExistingScreenAndInitializeIfPresent];
}

- (void)getStyleInformation:(NSString *)styleName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MKSSlideStyles" ofType:@"plist"];
    NSDictionary *stylesRoot = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *styleRoot = stylesRoot[styleName];
    //NSDictionary *styleRoot = stylesRoot[@"Simple"];
    self.markShowSlideStyle = styleRoot[@"slides"];
    self.markShowNoteStyle = styleRoot[@"notes"];
}

- (void)setPageSize {
    CGSize contentSize = self.scrollView.frame.size;
    [self.scrollView setContentSize:CGSizeMake(contentSize.width * self.markShowSlides.count, contentSize.height)];
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.markShowSlides.count) {
        return;
    }
    
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = ( frame.size.width * page ) + SLIDE_MARGIN_SCREEN0;
        frame.origin.y = SLIDE_MARGIN_SCREEN0;
        frame.size.width = frame.size.width - (SLIDE_MARGIN_SCREEN0 * 2);
        frame.size.height = frame.size.height - (SLIDE_MARGIN_SCREEN0 * 2);
        
        MKSSlideView *newPageView = [[MKSSlideView alloc] initWithFrame:frame];
        
        NSDictionary *styleSheet = self.markShowNoteStyle;
        NSNumber *currentBackgroundColor = styleSheet[@"backgroundColor"];
        
        NSAttributedString *markShownSlide = [CASMarkdownParser attributedStringFromMarkdown:[self.markShowPresenterNotes objectAtIndex:page] withStyleSheet:self.markShowNoteStyle andScale:@1];
        [newPageView setSlideContents:markShownSlide];
        [newPageView setBackgroundColor:[UIColor whiteColor]];
        
        [newPageView setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];
        [self.scrollView setBackgroundColor:UIColorFromRGB([currentBackgroundColor integerValue])];

        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

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
    [self loadPageForAirPlay:page];
}

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
    
    //NSMutableAttributedString *pageCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i / %i", (int)(page+1), (int)self.markShowSlides.count]];
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

- (void)unloadPageForAirPlay {
    if (self.externalScreen.secondWindow) {
        //NSLog(@"unload-airplay-window");
        
        self.externalScreen.secondWindow.hidden = YES;
        self.externalScreen.secondWindow = nil;
    }
}

@end
