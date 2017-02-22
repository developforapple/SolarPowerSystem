//
//  NSAttributedString+Units.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "NSAttributedString+Units.h"
#import <YYText/YYText.h>

@implementation NSAttributedString (Units)

+ (YYTextLayout *)layoutOfOriginString:(NSString *)originString
                       highlightString:(NSString *)highlightString1
                      normalAttributes:(NSDictionary *)normalAttributes
                   highlightAttributes:(NSDictionary *)highlightAttributes
                          maximumLines:(NSUInteger)maximumLines
                           perferWidth:(CGFloat)preferWidth
                          clipWordsLen:(NSUInteger)clipWordsLen
                           lineSpacing:(CGFloat)lineSpacing
{
    
    // 防止异常的数据导致的崩溃
    @try {
        
        NSString *highlightString = [highlightString1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //
        //  Step1：创建内容容器
        //
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(preferWidth, MAXFLOAT)];
        container.truncationType = YYTextTruncationTypeEnd;
        container.maximumNumberOfRows = maximumLines;
        YYTextLayout *layout;
        
        if (!highlightString || highlightString.length == 0) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
            text.yy_lineSpacing = lineSpacing;
            layout = [YYTextLayout layoutWithContainer:container text:text];
            return layout;
        }
        
        // 开始创建布局
        NSRange highlightRange = [originString rangeOfString:highlightString options:NSCaseInsensitiveSearch];
        if (highlightRange.location != NSNotFound) {
            
            NSString *clipString;
        
            if (clipWordsLen != 0) {
                //
                // Step2：将原始文本内容缩减到大概的最终显示范围，减少计算量。为关键词左右各 clipWordsLen 个字的范围。头尾字数不足时范围将缩小。
                //
                
                
                // 关键词左侧部分是否是裁剪过的
                BOOL breakHead = NO;
                
                NSInteger clipLoc,clipLen,clipHighlightLoc;
                
                // 确定裁剪后的文本范围和关键词位置
                if (highlightRange.location > clipWordsLen) {
                    clipLoc = highlightRange.location - clipWordsLen;
                    clipLen = clipWordsLen + highlightRange.length + clipWordsLen;
                    clipHighlightLoc = clipWordsLen;
                    breakHead = YES;
                }else{
                    clipLoc = 0;
                    clipLen = highlightRange.location + highlightRange.length + clipWordsLen;
                    clipHighlightLoc = highlightRange.length;
                }
                
                NSUInteger originLength = originString.length;
                if (clipLoc + clipLen > originLength) {
                    clipLen = originLength - clipLoc;
                }
                NSRange clipRange = NSMakeRange(clipLoc, clipLen);
                
                // 裁剪后的文本内容
                clipString = [originString substringWithRange:clipRange];
                if (breakHead) {
                    clipString = [clipString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"…"];
                }
            }else{
                
                // 使用原始字符串
                clipString = originString;
                
            }
            
            // 关键词的新位置
            NSRange clipHighlightRange = [clipString rangeOfString:highlightString options:NSCaseInsensitiveSearch];
            
    
            //
            // Step3：添加属性
            //
            
            NSMutableAttributedString *clipAttString = [[NSMutableAttributedString alloc] initWithString:clipString attributes:normalAttributes];
            NSRange r = clipHighlightRange;
            // 有可能关键词出现了多次
            while (r.location != NSNotFound) {
                [clipAttString setAttributes:highlightAttributes range:r];
                NSUInteger loc = r.location + r.length;
                NSUInteger len = clipString.length - loc;
                r = [clipString rangeOfString:highlightString options:NSCaseInsensitiveSearch range:NSMakeRange(loc,len)];
            }
            [clipAttString yy_setLineSpacing:lineSpacing range:clipAttString.yy_rangeOfAll];
            [clipAttString yy_setAlignment:NSTextAlignmentJustified range:clipAttString.yy_rangeOfAll];
            
            
            
            //
            //  Step4：创建布局。
            //
            //  规则是：如果当前可见区域将内容完全显示了，或者关键词的显示位置在可见区域的前 3/4 时，不需要调整。
            //         否则，当关键词的显示位置在当前可见区域的后 1/4 时，缩减可见区域的前 3/4，从而将关键词的位置前移。
            //
            
            
            layout = [YYTextLayout layoutWithContainer:container text:clipAttString];
            NSRange visibleRange = layout.visibleRange;
            
            // 是否完全显示。当显示区域的长度和文本长度一致时，即表示内容完全显示了。
            BOOL fullVisible = visibleRange.length == clipAttString.length;
            
            // 关键词的位置是位于前 3/4 还是位于后 1/4
            BOOL goodPosition = clipHighlightRange.location < visibleRange.length*3/4;
            
            if (!fullVisible && !goodPosition) {
                // 需要调整位置
                
                // 移动到 第 1/4 个长度
                NSInteger moveLen = visibleRange.length/4;
                
                NSInteger newLoc = clipHighlightRange.location - moveLen;
                NSRange newRange = NSMakeRange(newLoc, clipAttString.length - newLoc);
                
                // 对头部进行裁剪
                NSMutableAttributedString *newClipAttString = [[NSMutableAttributedString alloc] initWithAttributedString:[clipAttString attributedSubstringFromRange:newRange]];
                [newClipAttString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"…"];
                
                // 更新布局
                layout = [YYTextLayout layoutWithContainer:container text:newClipAttString];
            }
        
        }else{
            
            //
            //  不需要显示关键词时
            //
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
            [attributedString yy_setLineSpacing:lineSpacing range:attributedString.yy_rangeOfAll];
            [attributedString yy_setAlignment:NSTextAlignmentJustified range:attributedString.yy_rangeOfAll];
            layout = [YYTextLayout layoutWithContainer:container text:attributedString];
        }

        // 测试
        // TEST
//        YYLabel *label = [[YYLabel alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        label.backgroundColor = [UIColor whiteColor];
//        label.textLayout = layout;
//        [[UIApplication sharedApplication].keyWindow addSubview:label];
//        
//        label.userInteractionEnabled = YES;
//        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer * sender) {
//            [sender.view removeFromSuperview];
//        }]];
        
        
        //
        //  结果
        //
        return layout;
        
    } @catch (NSException *exception) {
        return nil;
    }
}

+(YYTextLayout *) simpleLayoutOfOriginString:(NSString *)originString
                             highlightString:(NSString *)highlightString
                            normalAttributes:(NSDictionary *)normalAttributes
                         highlightAttributes:(NSDictionary *)highlightAttributes
                                  textShadow:(YYTextShadow *)textShadow
                                maximumLines:(NSUInteger)maximumLines
                                 perferWidth:(CGFloat)preferWidth
                                 lineSpacing:(CGFloat)lineSpacing
{
    @try {
        
        highlightString = [highlightString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(preferWidth, MAXFLOAT)];
        container.truncationType = YYTextTruncationTypeEnd;
        container.maximumNumberOfRows = maximumLines;
        YYTextLayout *layout;
        
        if (!highlightString || highlightString.length == 0) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
            if (textShadow) {
                text.yy_textShadow = textShadow;
            }
            text.yy_lineSpacing = lineSpacing;
            layout = [YYTextLayout layoutWithContainer:container text:text];
            return layout;
        }
        
        NSRange highlightRange = [originString rangeOfString:highlightString options:NSCaseInsensitiveSearch];
        
        if (highlightRange.location != NSNotFound) { // 有需要高亮的字
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
            if (textShadow) {
                attributedString.yy_textShadow = textShadow;
            }
            
            [attributedString setAttributes:highlightAttributes range:highlightRange];
            [attributedString yy_setLineSpacing:lineSpacing range:attributedString.yy_rangeOfAll];
            [attributedString yy_setAlignment:NSTextAlignmentJustified range:attributedString.yy_rangeOfAll];
            layout = [YYTextLayout layoutWithContainer:container text:attributedString];
            
        } else {
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
            if (textShadow) {
                attributedString.yy_textShadow = textShadow;
            }
            [attributedString yy_setLineSpacing:lineSpacing range:attributedString.yy_rangeOfAll];
            [attributedString yy_setAlignment:NSTextAlignmentJustified range:attributedString.yy_rangeOfAll];
            layout = [YYTextLayout layoutWithContainer:container text:attributedString];
        }
        
        return layout;
        
    } @catch (NSException *exception) {
        return nil;
    }
}

+(YYTextLayout *) simpleLayoutOfOriginString:(NSString *)originString
                            normalAttributes:(NSDictionary *)normalAttributes
                                maximumLines:(NSUInteger)maximumLines
                                 perferWidth:(CGFloat)preferWidth
                                 lineSpacing:(CGFloat)lineSpacing
                                   alignment:(NSTextAlignment) alignment
                                  textShadow:(YYTextShadow *)textShadow
{
    @try {
        
        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(preferWidth, MAXFLOAT)];
        container.truncationType = YYTextTruncationTypeEnd;
        container.maximumNumberOfRows = maximumLines;
        YYTextLayout *layout;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originString attributes:normalAttributes];
        [attributedString yy_setLineSpacing:lineSpacing range:attributedString.yy_rangeOfAll];
        [attributedString yy_setAlignment:alignment range:attributedString.yy_rangeOfAll];
        if (textShadow) {
            attributedString.yy_textShadow = textShadow;
        }
        layout = [YYTextLayout layoutWithContainer:container text:attributedString];

        return layout;
        
    } @catch (NSException *exception) {
        return nil;
    }
}


+(NSDictionary *)attributes:(UIFont *)font color:(UIColor *)color
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = font;
    dict[NSForegroundColorAttributeName] = color;
    return dict;
}

+(YYTextShadow *)shadowColor:(UIColor *) color offset:(CGSize) offset radius:(CGFloat) radius
{
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = color;
    shadow.offset = offset;
    shadow.radius = radius;
    
    return shadow;
}

@end

