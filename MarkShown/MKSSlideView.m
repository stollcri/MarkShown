//
//  MKSSlideView.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/28/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "MKSSlideView.h"

@implementation MKSSlideView

@synthesize slideContents;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.slideContents); //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.slideContents length]), path, NULL);
    CTFrameDraw(frame, context);
    
    if (self.slideFooterCenter) {
        CGRect pageCount = self.bounds;
        pageCount.origin.x = (NSInteger)floor(pageCount.size.width / 2) - 20;
        pageCount.origin.y = 0;
        pageCount.size.height = 20;
        
        path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, pageCount);
        
        framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.slideFooterCenter); //3
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.slideFooterCenter length]), path, NULL);
        CTFrameDraw(frame, context);
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end
