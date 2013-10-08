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

@implementation CASMarkdownParser

NSMutableAttributedString *attributedString;
NSRange entireString;
NSRange subStringRange;

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown withStyleSheet:(NSDictionary *)styleSheet {
    NSString *workingText = [[NSString alloc] initWithFormat:@"\n%@ ", markdown];
    NSString *formatDelimiters = @"#*/_-";
    NSString *headerFormaters = @"#####*-";
    NSString *characterFormaters = @"#*/_-";
    NSString *bulletListFormaters = @"*-";
    
    NSMutableArray *formatTypeStack = [NSMutableArray array];
    NSMutableArray *formatRangeStack = [NSMutableArray array];
    
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
        if ([formatDelimiters rangeOfString:currentCharacter].location != NSNotFound) {
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
                // a single occurance of these characters is not signifigant
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
                        // length equals -1 until we get the closing mark
                        currentRange = NSMakeRange(i-skipCount, -1);
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
                            
                            // the length -1, so it's not closed
                            if (currentRange.length == -1) {
                                currentRange.length = i - (currentRange.location + skipCount);
                                
                                [formatRangeStack replaceObjectAtIndex:([formatRangeStack count] - 1) withObject:[NSValue valueWithRange:currentRange]];
                                //
                                // TODO: push finished itmes onto a different stack to account for nested tags
                                //
                            }
                            
                        // this is the begin format mark
                        }else{
                            // a single occurance of these characters is not signifigant
                            // we're checking again because one may have slipped through due to bullet list checking
                            if ([characterFormaters rangeOfString:currentToken].location == NSNotFound) {
                                // push the formating mark onto the stack
                                NSString *tokenToSave = [[NSString alloc] initWithString:currentToken];
                                [formatTypeStack addObject:tokenToSave];
                                
                                // push the range onto the stack
                                // length equals -1 until we get the closing mark
                                currentRange = NSMakeRange(i-skipCount, -1);
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
                    [textWithoutTokens appendString:currentCharacter];
                
                // we have a newline character
                }else{
                    // this is not the second character (remove initial newline)
                    if (![lastCharacter isEqualToString:@""]) {
                        // the format stack is not empty
                        if ([formatTypeStack count] > 0) {
                            // the last delimiter was a header marker
                            if ([headerFormaters rangeOfString:[formatTypeStack lastObject]].location != NSNotFound) {
                                currentRange = [[formatRangeStack lastObject] rangeValue];
                                
                                // the length is -1, so it's not closed
                                if (currentRange.length == -1) {
                                    currentRange.length = i - (currentRange.location + skipCount);// + [currentToken length];
                                    
                                    [formatRangeStack replaceObjectAtIndex:([formatRangeStack count] - 1) withObject:[NSValue valueWithRange:currentRange]];
                                    //
                                    // TODO: push finished itmes onto a different stack to account for nested tags
                                    //
                                }
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
    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
    [attributedString addAttribute:NSFontAttributeName value:currentFont range:entireString];
    
    for (NSInteger i = 0; i < [formatRangeStack count]; i++) {
        currentRange = [[formatRangeStack objectAtIndex:i] rangeValue];
        
        if (currentRange.length != -1) {
            //NSLog(@"|%@|", [textWithoutTokens substringWithRange:currentRange]);
            
            // handle headers
            if ([headerFormaters rangeOfString:[formatTypeStack objectAtIndex:i]].location != NSNotFound) {
                if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"#"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"h1"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"##"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"h2"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"###"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"h3"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"####"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"h4"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"#####"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"h5"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
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
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    NSNumber *currentParagraphMargin = currentTypeStyle[@"margin"];
                    NSNumber *currentParagraphIndent = currentTypeStyle[@"indent"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.firstLineHeadIndent = [currentParagraphMargin floatValue];
                        paragraph.headIndent = [currentParagraphIndent floatValue];
                        //paragraph.tabStops = [NSArray arrayWithObjects:@10];
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }
            
            // handle character formating
            }else{
                if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"**"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"bold"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"//"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"italic"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"__"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"underline"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                    
                    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:currentRange];
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"--"]) {
                    NSDictionary *currentTypeStyle = styleSheet[@"underline"];
                    NSString *currentFontFace = currentTypeStyle[@"font"];
                    NSNumber *currentFontSize = currentTypeStyle[@"size"];
                    NSNumber *currentParagraphAlign = currentTypeStyle[@"align"];
                    UIFont *currentFont = [UIFont fontWithName:currentFontFace size:[currentFontSize floatValue]];
                    [attributedString addAttribute:NSFontAttributeName value:currentFont range:currentRange];
                    
                    if ([currentParagraphAlign isEqualToNumber:@1]) {
                        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
                        paragraph.alignment = NSTextAlignmentCenter;
                        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraph range:currentRange];
                    }
                    
                    // TODO: the strikethrough is not working
                    [attributedString addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:2] range:currentRange];
                }
            }
        }
    }
    
    return attributedString;
}

@end
