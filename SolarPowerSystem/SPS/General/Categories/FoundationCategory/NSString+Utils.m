//
//  NSString+Utils.m
//  QuizUp
//
//  Created by Normal on 16/4/8.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (NSRange)rangeOfURL:(NSString *)string
{
    if (!string || string.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSString *pattern = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result) {
        return result.range;
    }
    return NSMakeRange(NSNotFound, 0);
}

+ (NSAttributedString *)attributedStringByAddUnderlineForURLInString:(NSString *)string
{
    if (!string || ![string isKindOfClass:[NSString class]] || string.length == 0) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    NSString *pattern = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *result = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    //    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    //    NSArray *result = [detector matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSMutableArray *stringBlocks = [NSMutableArray array];
    
    if (result.count == 0) {
        return nil;
    }else{
        NSInteger location = 0;
        
        for (NSTextCheckingResult *aResult in result) {
            NSRange range = aResult.range;
            NSString *URL = [string substringWithRange:range];
            
            NSRange lastRange = NSMakeRange(location, range.location - location);
            NSString *lastString  = [string substringWithRange:lastRange];
            
            [stringBlocks addObject:lastString];
            [stringBlocks addObject:URL];
            
            location = range.location + range.length;
        }
    }
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    for (NSInteger index = 0; index < stringBlocks.count; index++) {
        NSString *string = stringBlocks[index];
        
        if (index%2 != 0) {
            //是一个链接
            NSAttributedString *attributeURL =
            [[NSAttributedString alloc] initWithString:string
                                            attributes:@{NSForegroundColorAttributeName:RGBColor(97, 154, 207, 1),
                                                         NSUnderlineStyleAttributeName:@1}];
            [attrString appendAttributedString:attributeURL];
        }else{
            NSAttributedString *tmp = [[NSAttributedString alloc] initWithString:string];
            [attrString appendAttributedString:tmp];
        }
    }
    return attrString;
}

@end
