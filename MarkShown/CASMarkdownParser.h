//
//  CASMarkdownParser.h
//  MarkShown
//
//  Created by Christopher Stoll on 9/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CASMarkdownParser : NSObject

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown withStyleSheet:(BOOL)styleSheet;

@end
