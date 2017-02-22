//
//  NSString+Utils.h
//  QuizUp
//
//  Created by Normal on 16/4/8.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (NSRange)rangeOfURL:(NSString *)string;

+ (NSAttributedString *)attributedStringByAddUnderlineForURLInString:(NSString *)string;

@end
