//
//  DDSegmentScrollView.h
//  JuYouQu
//
//  Created by appleDeveloper on 15/12/17.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDSegmentScrollView : UIControl

// 默认 MainTintColor
+ (void)setDefaultNormalColor:(UIColor *)color;
// 默认 MainHighlightColor
+ (void)setDefaultHighlightColor:(UIColor *)color;

// 默认15号
@property (strong, nonatomic) UIFont *normalFont;
// 默认15号
@property (assign, nonatomic) IBInspectable CGFloat normalFontSize;
// 放大倍率 默认 1.4
@property (assign, nonatomic) IBInspectable CGFloat highlightScale;
// 默认 MainTintColor
@property (strong, nonatomic) IBInspectable UIColor *normalColor;
// 默认 MainHighlightColor
@property (strong, nonatomic) IBInspectable UIColor *highlightColor;
// 圆角边框的颜色。默认为 normalColor 40%
@property (strong, nonatomic) IBInspectable UIColor *normalBorderColor;
// 圆角边框的高亮颜色。默认为 highlightColor 40%
@property (strong, nonatomic) IBInspectable UIColor *highlightBorderColor;
// 是否显示指示器。默认YES
@property (assign, nonatomic) IBInspectable BOOL showIndicator;
// 是否显示标题的圆角边框 默认NO
@property (assign, nonatomic) IBInspectable BOOL showTitleBorder;
// 标题最小高度。默认为字体高度
@property (assign, nonatomic) IBInspectable CGFloat titleMinimumHeight;
// 是否显示最下边的长横线。默认YES
@property (assign, nonatomic) IBInspectable BOOL showLineView;
// 横线颜色。默认 e6e6e6
@property (strong, nonatomic) IBInspectable UIColor *lineViewColor;
// 最小单元间隔。默认 32
@property (assign, nonatomic) IBInspectable CGFloat unitSpacing;
// 指示器的偏移量。默认 {0,0}
@property (assign, nonatomic) IBInspectable CGPoint indicatorOffset;
// 默认为NO。如果设为YES，将待高斯模糊效果。
@property (assign, nonatomic) IBInspectable BOOL translucent;

@property (assign, readonly, nonatomic) NSUInteger lastIndex;

@property (assign, nonatomic) NSUInteger currentIndex;

@property (strong, nonatomic) NSArray <NSString *>*titles;

@end
