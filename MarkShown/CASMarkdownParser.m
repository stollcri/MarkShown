//
//  CASMarkdownParser.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "CASMarkdownParser.h"

@implementation CASMarkdownParser

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown withStyleSheet:(BOOL)styleSheet {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:markdown];
    NSRange entireString = NSMakeRange(0, markdown.length);
    
    if (styleSheet) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:36.0] range:entireString];
    }else{
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:18.0] range:entireString];
    }
    
    NSRegularExpression *findHeadingOne = [[NSRegularExpression alloc] initWithPattern:@"^((# ){1}.+)" options:kNilOptions error:nil];
    [findHeadingOne enumerateMatchesInString:markdown options:kNilOptions range:entireString usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:1];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:24.0] range:subStringRange];
    }];
    
    return attributedString;
}

@end
