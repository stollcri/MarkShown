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

@interface MKSPlayViewController ()

@property (strong, nonatomic) NSArray *markShowSlides;
@property (strong, nonatomic) NSArray *markShowPresenterNotes;
@property (strong, nonatomic) NSMutableArray *pageViews;

@property (strong, nonatomic) MKSSlideView *airPlayView;
@property (strong, nonatomic) CASExternalScreen *externalScreen;

- (void)prepareSlideData;
- (void)preparePages;
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
    
    self.externalScreen = [[CASExternalScreen alloc] init];
    [self.externalScreen setUpScreenConnectionNotificationHandlers];
    [self.externalScreen checkForExistingScreenAndInitializeIfPresent];
    
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
    [super viewWillDisappear:animated];
    [self unloadPageForAirPlay];
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
        
        NSAttributedString *markShownSlide = [CASMarkdownParser attributedStringFromMarkdown:[self.markShowPresenterNotes objectAtIndex:page] withStyleSheet:NO];
        [newPageView setSlideContents:markShownSlide];
        [newPageView setBackgroundColor:[UIColor whiteColor]];

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
    frame.origin.x = SLIDE_MARGIN_SCREEN1;
    frame.origin.y = SLIDE_MARGIN_SCREEN1;
    frame.size.width = frame.size.width - (SLIDE_MARGIN_SCREEN1 * 2);
    frame.size.height = frame.size.height - (SLIDE_MARGIN_SCREEN1 * 2);
    self.airPlayView = [[MKSSlideView alloc] initWithFrame:frame];

    NSAttributedString *markShownSlide = [CASMarkdownParser attributedStringFromMarkdown:[self.markShowSlides objectAtIndex:page] withStyleSheet:YES];
    [self.airPlayView setBackgroundColor:[UIColor whiteColor]];
    [self.airPlayView setSlideContents:markShownSlide];
    
    [self.externalScreen.secondWindow addSubview:self.airPlayView];
}

- (void)unloadPageForAirPlay {
    if (self.externalScreen.secondWindow) {
        NSLog(@"unload-airplay-window");
        /*
        [self.airPlayView setBackgroundColor:[UIColor purpleColor]];
        [self.airPlayView setSlideContents:nil];
        [self.externalWindow addSubview:self.airPlayView];
        [[self.externalWindow.subviews objectAtIndex:0] setSlideContents:nil];
        [self.externalWindow makeKeyAndVisible];
        */
        
        //[self.externalWindow setHidden:YES];
        
        //[self.externalScreen]
        //[self.externalWindow setScreen:nil];
        //self.externalWindow = nil;
        
    }
}

@end
