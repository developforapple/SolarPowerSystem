//
//  NSString+HtmlText.m
//  Golf
//
//  Created by 黄希望 on 15/8/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "NSString+HtmlText.h"


#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\

#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)

REGULAREXPRESSION(URLRegularExpression,@"(https?|golfapi)://[A-Za-z\\d\\.-_\\?&#=]*")

REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}")

REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")

//REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")

REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"(#[^#\\s]{2,20}#)", NSRegularExpressionCaseInsensitive)

REGULAREXPRESSION_OPTION(MemberFlagRegularExpression, @"(φ[^φ]{3,60}φ)", NSRegularExpressionCaseInsensitive)


#define kURLActionCount 5
NSString * const kURLActions[] = {@"memberFlag->",@"url->",@"poundSign->",@"phoneNumber->",@"email->"};

NSUInteger tempLength ;

@implementation NSString (HtmlText)

+ (void)plainTextWithText:(NSString*)aText callBack:(void(^)(NSString *plainText,NSArray *urls,NSArray *urlRanges))callBack{
    if (!aText || aText.length == 0) {
        if (callBack) {
            callBack (aText,nil,nil);
        }
        return;
    }
    
    NSMutableArray *urls = [NSMutableArray array];
    NSMutableArray *urlRanges = [NSMutableArray array];
    
    NSMutableString *plainText = [NSMutableString stringWithString:aText];
    NSMutableString *tpPlainText = [NSMutableString stringWithString:aText];
    
    NSRange stringRange = NSMakeRange(0, aText.length);
    NSRegularExpression * const regexps[] = {kMemberFlagRegularExpression(),kURLRegularExpression(),kPoundSignRegularExpression(),kPhoneNumerRegularExpression(),kEmailRegularExpression()};
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSUInteger i=0; i<kURLActionCount; i++) {
        
        NSString *urlAction = kURLActions[i];
        
        [results removeAllObjects];
        tempLength = 0;
        
        [regexps[i] enumerateMatchesInString:plainText options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            
            for (NSTextCheckingResult *record in results){
                if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
                    return;
                }
            }
            
            NSString *subString = [plainText substringWithRange:result.range];
            NSString *replaceString = nil;
            NSRange tpRange;
            
            if (Equal(urlAction, @"memberFlag->")){
                NSString *newString = [subString stringByReplacingOccurrencesOfString:@"φ" withString:@""] ;
                NSArray *arr = [newString componentsSeparatedByString:@"✖-░☭"];
                if (arr.count > 1) {
                    NSString *memberName = [arr firstObject];
                    
                    int memberId = [[arr lastObject] intValue];
                    if (memberId > 0) {
                        NSString *urlString = [NSString stringWithFormat:@"golfapi://?data_type=member&data_id=%d",memberId];
                        tpRange = NSMakeRange(result.range.location-tempLength, memberName.length);
                        NSURL *url = [NSURL URLWithString:urlString];
                        if (url) {
                            [urls addObject:url];
                            tempLength += (subString.length-memberName.length);
                            replaceString = memberName;
                        }
                    }
                }
            }else if (Equal(urlAction, @"url->")) {
                tpRange = NSMakeRange(result.range.location-tempLength, 4);
                NSURL *url = [NSURL URLWithString:subString];
                if (url) {
                    [urls addObject:url];
                    replaceString = @"查看链接";
                    tempLength += (subString.length - replaceString.length);
                }
            }else if (Equal(urlAction, @"poundSign->")){
                NSString *newString = [[subString stringByReplacingOccurrencesOfString:@"#" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                tpRange = result.range;
                NSURL *url = [NSURL URLWithString:[@"poundSign://?" stringByAppendingString:newString]];
                if (url) {
                    [urls addObject:url];
                    replaceString = subString;
                }
            }else {
                tpRange = result.range;
                NSURL *url = [NSURL URLWithString:subString];
                if (url) {
                    [urls addObject:url];
                    replaceString = subString;
                }
            }
            
            if (replaceString) {
                [tpPlainText replaceCharactersInRange:NSMakeRange(tpRange.location, result.range.length) withString:replaceString];
                [urlRanges addObject:[NSValue valueWithRange:tpRange]];
                NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:result.range replacementString:@""];
                
                [results addObject:aResult];
            }
        }];
        
        plainText = [NSMutableString stringWithString:tpPlainText];
        stringRange = NSMakeRange(0, plainText.length);
    }
    
    if (callBack) {
        callBack (plainText,urls,urlRanges);
    }
}

@end
