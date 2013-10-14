//
//  CASMarkdownParser.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

//
// TODO: post parser implementatoin clean up
//

#import "CASMarkdownParser.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@implementation CASMarkdownParser

NSMutableAttributedString *attributedString;
NSRange entireString;
NSRange subStringRange;

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown withStyleSheet:(NSDictionary *)styleSheet andScale:(NSNumber *)fontScale {
    NSString *workingText = [[NSString alloc] initWithFormat:@"\n%@\n", markdown];
    NSString *formatDelimiters = @"#*/_-";
    NSString *headerFormaters = @"#####*-";
    NSString *characterFormaters = @"#*/_-";
    NSString *bulletListFormaters = @"*-";
    
    NSMutableArray *formatTypeStack = [NSMutableArray array];
    NSMutableArray *formatRangeStack = [NSMutableArray array];
    NSMutableArray *formatTypes = [NSMutableArray array];
    NSMutableArray *formatRanges = [NSMutableArray array];
    
    NSString *prevCharacter = @"";
    NSString *lastCharacter = @"";
    NSString *currentCharacter = @"";
    NSMutableString *currentToken = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *textWithoutTokens = [[NSMutableString alloc] init];
    NSRange currentRange;
    int skipCount = 1;
    
    for (NSInteger i = 0; i < [workingText length]; i++) {
        // get the current character
        currentCharacter = [workingText substringWithRange:NSMakeRange(i, 1)];
        
        // check if the current character is interesting
        if (([formatDelimiters rangeOfString:currentCharacter].location != NSNotFound) && (![lastCharacter isEqualToString:@"\\"])) {
            // WHAT IS GOING ON HERE?
            // TODO: clean this mess up
            // hashes are only interesting at the begining of a line
            if ([currentCharacter isEqualToString:@"#"] && ([lastCharacter isEqualToString:@"\n"] || [lastCharacter isEqualToString:@"#"])) {
                [currentToken appendString:currentCharacter];
                skipCount += 1;
            }else{
                [currentToken appendString:currentCharacter];
                skipCount += 1;
            }
            
        // the current character is not interesting
        }else{
            // we have a token open
            if ([currentToken length] > 0) {
                // a single occurance of these characters is not signifigant, unless they begin a line
                if (([characterFormaters rangeOfString:currentToken].location != NSNotFound) && ![prevCharacter isEqualToString:@"\n"]) {
                    [textWithoutTokens appendString:currentToken];
                    [textWithoutTokens appendString:currentCharacter];
                    // reduce skip count since these are not signifigant
                    skipCount -= [currentToken length];
                
                // we have an open formating mark
                }else{
                    // we have a heading formating mark
                    if ([headerFormaters rangeOfString:currentToken].location != NSNotFound) {
                        // EXPERIMENTAL
                        if ([bulletListFormaters rangeOfString:currentToken].location != NSNotFound) {
                            [textWithoutTokens appendString:@"•\t"];
                        }
                        
                        // non-space chaacters are just saved
                        if (![currentCharacter isEqualToString:@" "]) {
                            [textWithoutTokens appendString:currentCharacter];
                        }
                        // push the formating mark onto the stack
                        NSString *tokenToSave = [[NSString alloc] initWithString:currentToken];
                        [formatTypeStack addObject:tokenToSave];
                        
                        // push the range onto the stack
                        // length equals 0 until we get the closing mark
                        currentRange = NSMakeRange(i-skipCount, 0);
                        [formatRangeStack addObject:[NSValue valueWithRange:currentRange]];
                        
                        // increment the skip count for non-spaces (after the above use!)
                        if ([currentCharacter isEqualToString:@" "]) {
                            skipCount += 1;
                        }
                        
                        if ([bulletListFormaters rangeOfString:currentToken].location != NSNotFound) {
                            skipCount -= 2;
                        }
                        
                    // we have a character formating mark
                    }else{
                        // this is the end format mark
                        if ([[formatTypeStack lastObject] isEqualToString:currentToken]) {
                            currentRange = [[formatRangeStack lastObject] rangeValue];
                            
                            currentRange.length = i - (currentRange.location + skipCount);
                            
                            [formatTypes addObject:[formatTypeStack lastObject]];
                            [formatRanges addObject:[NSValue valueWithRange:currentRange]];
                            
                            [formatTypeStack removeLastObject];
                            [formatRangeStack removeLastObject];
                            
                        // this is the begin format mark
                        }else{
                            // a single occurance of these characters is not signifigant
                            // we're checking again because one may have slipped through due to bullet list checking
                            if ([characterFormaters rangeOfString:currentToken].location == NSNotFound) {
                                // push the formating mark onto the stack
                                NSString *tokenToSave = [[NSString alloc] initWithString:currentToken];
                                [formatTypeStack addObject:tokenToSave];
                                
                                // push the range onto the stack
                                // length equals 0 until we get the closing mark
                                currentRange = NSMakeRange(i-skipCount, 0);
                                [formatRangeStack addObject:[NSValue valueWithRange:currentRange]];
                            }
                        }
                        
                        // save the current, uninteresting character
                        [textWithoutTokens appendString:currentCharacter];
                    }
                }
                
            // no open tokens
            }else{
                // nothing to do and this is not a newline character
                if (![currentCharacter isEqualToString:@"\n"]) {
                    // the last character was not a potential escape
                    if (![lastCharacter isEqualToString:@"\\"]) {
                        [textWithoutTokens appendString:currentCharacter];
                    
                    // the last cahracter was a potential escape
                    }else{
                        // the current token is escapable
                        if ([characterFormaters rangeOfString:currentCharacter].location != NSNotFound) {
                            // remove the escape character
                            [textWithoutTokens deleteCharactersInRange:NSMakeRange([textWithoutTokens length]-1, 1)];
                            // TODO: check that this is working as intended
                            skipCount += 1;
                        }
                        [textWithoutTokens appendString:currentCharacter];
                    }
                
                // we have a newline character
                }else{
                    // this is not the second character (remove initial newline)
                    if (![lastCharacter isEqualToString:@""]) {
                        // the format stack is not empty
                        if ([formatTypeStack count] > 0) {
                            // the last delimiter was a header marker
                            if ([headerFormaters rangeOfString:[formatTypeStack lastObject]].location != NSNotFound) {
                                currentRange = [[formatRangeStack lastObject] rangeValue];
                                
                                currentRange.length = i - (currentRange.location + skipCount);
                                
                                [formatTypes addObject:[formatTypeStack lastObject]];
                                [formatRanges addObject:[NSValue valueWithRange:currentRange]];
                                
                                [formatTypeStack removeLastObject];
                                [formatRangeStack removeLastObject];
                            }
                        }
                        
                        [textWithoutTokens appendString:currentCharacter];
                    }
                }
            }
            
            // clear the current token
            [currentToken setString:@""];
        }
        
        prevCharacter = lastCharacter;
        lastCharacter = currentCharacter;
    }
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:textWithoutTokens];
    
    entireString = NSMakeRange(0, [attributedString length]);
    NSDictionary *currentTypeStyle = styleSheet[@"default"];
    NSString *currentFontFace = currentTypeStyle[@"font"];
    NSNumber *currentFontSize = currentTypeStyle[@"size"];
    NSNumber *currentFontColor = currentTypeStyle[@"color"];
    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
    currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
    
    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
    
    [attributedString addAttribute:NSFontAttributeName value:currentFont range:entireString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB([currentFontColor integerValue]) range:entireString];
    
    if ([currentParagraphAlign isEqualToNumber:@1]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
    }
    
    for (NSInteger i = 0; i < [formatRanges count]; i++) {
        currentRange = [[formatRanges objectAtIndex:i] rangeValue];
        //NSLog(@"|%@|", [textWithoutTokens substringWithRange:currentRange]);
        
        // handle headers
        if ([headerFormaters rangeOfString:[formatTypes objectAtIndex:i]].location != NSNotFound) {
            if ([[formatTypes objectAtIndex:i] isEqualToString:@"#"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"h1"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                if ([currentParagraphAlign isEqualToNumber:@1]) {
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                }
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"##"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"h2"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                if ([currentParagraphAlign isEqualToNumber:@1]) {
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                }
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"###"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"h3"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                if ([currentParagraphAlign isEqualToNumber:@1]) {
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                }
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"####"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"h4"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                if ([currentParagraphAlign isEqualToNumber:@1]) {
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                }
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"#####"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"h5"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                if ([currentParagraphAlign isEqualToNumber:@1]) {
                    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                    paragraph.alignment = NSTextAlignmentCenter;
                    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                }
            }else{
                NSDictionary *currentTypeStyle = styleSheet[@"bullet"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                NSNumber *currentParagraphMargin = currentTypeStyle[@"margin"];
                NSNumber *currentParagraphIndent = currentTypeStyle[@"indent"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                
                // DONE: bullet points are not showing properly on the second screen?
                //       the spacing needed changed for the larger font sizes
                NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                paragraph.firstLineHeadIndent = [currentParagraphMargin floatValue];
                paragraph.headIndent = [currentParagraphIndent floatValue];
                //paragraph.tabStops = [NSArray arrayWithObjects:@10];
                [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
            }
        
        // handle character formating
        }else{
            if ([[formatTypes objectAtIndex:i] isEqualToString:@"**"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"bold"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"//"]) {
                NSDictionary *currentTypeStyle = styleSheet[@"italic"];
                NSString *currentFontFace = currentTypeStyle[@"font"];
                NSNumber *currentFontSize = currentTypeStyle[@"size"];
                currentFontSize = [NSNumber numberWithDouble:(floor([currentFontSize integerValue] * [fontScale doubleValue]))];
                
                UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"__"]) {
                [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:currentRange];
            }else if ([[formatTypes objectAtIndex:i] isEqualToString:@"--"]) {
                // TODO: the strikethrough is not working
                [attributedString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:2] range:currentRange];
            }
        }
    }
    
    return attributedString;
}

@end
