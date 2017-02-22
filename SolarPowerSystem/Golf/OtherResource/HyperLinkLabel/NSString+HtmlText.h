//
//  NSString+HtmlText.h
//  Golf
//
//  Created by 黄希望 on 15/8/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HtmlText)

+ (void)plainTextWithText:(NSString*)aText callBack:(void(^)(NSString *plainText,NSArray *urls,NSArray *urlRanges))callBack;

@end
