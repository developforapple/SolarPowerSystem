//
//  NSAttributedString+Units.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYTextLayout;
@class YYTextShadow;

@interface NSAttributedString (Units)

/*!
 *  @brief 创建一个文本布局。如果有关键词，总是高亮显示关键词，而不管它在哪个位置。
 *
 *  @param originString        原始字符串
 *  @param highlightString     高亮的字符串
 *  @param normalAttributes    普通文本样式
 *  @param highlightAttributes 高亮文本样式
 *  @param maximumLines        布局的最多行数
 *  @param preferWidth         布局的最大宽度
 *  @param clipWordsLen        确定布局前先对原始字符串进行一定的裁剪，从而减少布局范围。设为0时表示根据原始字符串来确定布局。如果不确定需要裁剪多少，可以设置为0.
 *  @param lineSpacing         行间距
 *  @return 布局实例
 */
+ (YYTextLayout *)layoutOfOriginString:(NSString *)originString
                       highlightString:(NSString *)highlightString
                      normalAttributes:(NSDictionary *)normalAttributes
                   highlightAttributes:(NSDictionary *)highlightAttributes
                          maximumLines:(NSUInteger)maximumLines
                           perferWidth:(CGFloat)preferWidth
                          clipWordsLen:(NSUInteger)clipWordsLen
                           lineSpacing:(CGFloat)lineSpacing;

/**
 *  创建一个文本布局。如果有关键词，高亮第一个关键字
 *
 *  @param originString        原始字符串
 *  @param highlightString     高亮的字符串
 *  @param normalAttributes    普通文本样式
 *  @param highlightAttributes 高亮文本样式
 *  @param textShadow          文字阴影
 *  @param maximumLines        布局的最多行数
 *  @param preferWidth         布局的最大宽度
 *  @param lineSpacing         行间距
 *
 *  @return 布局实例
 */
+(YYTextLayout *) simpleLayoutOfOriginString:(NSString *)originString
                       highlightString:(NSString *)highlightString
                            normalAttributes:(NSDictionary *)normalAttributes
                         highlightAttributes:(NSDictionary *)highlightAttributes
                                  textShadow:(YYTextShadow *)textShadow
                          maximumLines:(NSUInteger)maximumLines
                           perferWidth:(CGFloat)preferWidth
                                 lineSpacing:(CGFloat)lineSpacing;

/**
 *  创建一个文本布局
 *
 *  @param originString     原始字符串
 *  @param normalAttributes 普通文本样式
 *  @param maximumLines     布局的最多行数
 *  @param preferWidth      布局的最大宽度
 *  @param lineSpacing      行间距
 *  @param alignment        对齐方式
 *  @param textShadow          文字阴影
 *
 *  @return 布局实例
 */
+(YYTextLayout *) simpleLayoutOfOriginString:(NSString *)originString
                            normalAttributes:(NSDictionary *)normalAttributes
                                maximumLines:(NSUInteger)maximumLines
                                 perferWidth:(CGFloat)preferWidth
                                 lineSpacing:(CGFloat)lineSpacing
                                   alignment:(NSTextAlignment) alignment
                                  textShadow:(YYTextShadow *)textShadow;
/**
 *  创建一个字符样式字典
 *
 *  @param font  字体
 *  @param color 字体颜色
 *
 *  @return 字符样式字典
 */
+(NSDictionary *)attributes:(UIFont *)font color:(UIColor *)color;

/**
 *  创建一个阴影
 *
 *  @param color  阴影颜色
 *  @param offset 阴影偏移量
 *  @param radius 阴影半径
 *
 *  @return 返回一个应用对象
 */
+(YYTextShadow *)shadowColor:(UIColor *) color offset:(CGSize) offset radius:(CGFloat) radius;

@end
