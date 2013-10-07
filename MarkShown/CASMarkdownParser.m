//
//  CASMarkdownParser.m
//  MarkShown
//
//  Created by Christopher Stoll on 9/30/13.
//  Copyright (c) 2013 Christopher Stoll. All rights reserved.
//

#import "CASMarkdownParser.h"

@implementation CASMarkdownParser

NSMutableAttributedString *attributedString;
NSRange entireString;
NSRange subStringRange;

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown withStyleSheet:(NSDictionary *)styleSheet {
    NSString *workingText = [[NSString alloc] initWithFormat:@"\n%@ ", markdown];
    NSString *formatDelimiters = @"#/_*";
    NSString *headerFormaters = @"#####";
    NSString *characterFormaters = @"/_*";
    
    NSMutableArray *formatTypeStack = [NSMutableArray array];
    NSMutableArray *formatRangeStack = [NSMutableArray array];
    
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
                if ([characterFormaters rangeOfString:currentToken].location != NSNotFound) {
                    [textWithoutTokens appendString:currentToken];
                    [textWithoutTokens appendString:currentCharacter];
                    // reduce skip count since these are not signifigant
                    skipCount -= [currentToken length];
                
                // we have an open formating mark
                }else{
                    // we have a heading formating mark
                    if ([headerFormaters rangeOfString:currentToken].location != NSNotFound) {
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
                            // push the formating mark onto the stack
                            NSString *tokenToSave = [[NSString alloc] initWithString:currentToken];
                            [formatTypeStack addObject:tokenToSave];
                            
                            // push the range onto the stack
                            // length equals -1 until we get the closing mark
                            currentRange = NSMakeRange(i-skipCount, -1);
                            [formatRangeStack addObject:[NSValue valueWithRange:currentRange]];
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
                        // the last delimiter was a header marker
                        if ([headerFormaters rangeOfString:[formatTypeStack lastObject]].location != NSNotFound) {
                            currentRange = [[formatRangeStack lastObject] rangeValue];
                            
                            // the length is -1, so it's not closed
                            if (currentRange.length == -1) {
                                currentRange.length = i - (currentRange.location + skipCount) + [currentToken length];
                                
                                [formatRangeStack replaceObjectAtIndex:([formatRangeStack count] - 1) withObject:[NSValue valueWithRange:currentRange]];
                                //
                                // TODO: push finished itmes onto a different stack to account for nested tags
                                //
                            }
                        }
                        
                        [textWithoutTokens appendString:currentCharacter];
                    }
                }
            }
            
            // clear the current token
            [currentToken setString:@""];
        }
        
        lastCharacter = currentCharacter;
    }
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:textWithoutTokens];
    NSString *defaultFontFace = styleSheet[@"defaultFont"];
    NSNumber *defaultFontSize = styleSheet[@"defaultSize"];
    UIFont *defaultFont = [UIFont fontWithName:defaultFontFace size:[defaultFontSize floatValue]];
    [attributedString addAttribute:NSFontAttributeName value:defaultFont range:entireString];
    
    for (NSInteger i = 0; i < [formatRangeStack count]; i++) {
        currentRange = [[formatRangeStack objectAtIndex:i] rangeValue];
        
        if (currentRange.length != -1) {
            // handle headers
            if ([headerFormaters rangeOfString:[formatTypeStack objectAtIndex:i]].location != NSNotFound) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:currentRange];
            
            // handle character formating
            }else{
                if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"//"]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:currentRange];
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"__"]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:currentRange];
                }else if ([[formatTypeStack objectAtIndex:i] isEqualToString:@"**"]) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:currentRange];
                }
            }
        }
    }
    
    return attributedString;
}

@end
