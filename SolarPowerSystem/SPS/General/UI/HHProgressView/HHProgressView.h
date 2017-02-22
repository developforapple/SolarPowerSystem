//
//  HHProgressView.h
//  HHProgressView
//
//  Created by zengcatch on 15/3/22.
//  Copyright © 2015年 yizhixiang. All rights reserved.
//

/**
 *  进度条视图
 *
 使用方法：
 
 1.使用代码或者xib初始化完毕后，可以设置自己想要的样式【具体见外观部分的注释】
 
 2.支持使用UIAppearance设置统一样式:
 HHProgressView *appearance = [HHProgressView appearance];
 [appearance setUsesRoundedCorners:YES];
 [appearance setProgress:0];
 [appearance setBarBorderWidth:2.0];
 [appearance setBarBorderColor:[UIColor cyanColor]];
 [appearance setBarInnerBorderWidth:0];
 [appearance setBarInnerBorderColor:nil];
 [appearance setBarInnerPadding:2.0];
 [appearance setBarFillColor:[UIColor cyanColor]];
 [appearance setBarBackgroundColor:[UIColor whiteColor]];
 
 */
#import <UIKit/UIKit.h>

@interface HHProgressView : UIView

/**
 *  当前进度
 */
@property (nonatomic) CGFloat progress;

#pragma mark -- 外观部分

/**
 外框宽度
 
 默认2.0f
 */
@property (nonatomic) CGFloat barBorderWidth UI_APPEARANCE_SELECTOR;

/**
 外框颜色
 
 默认 darkGrayColor
 */
@property (nonatomic, strong) UIColor *barBorderColor UI_APPEARANCE_SELECTOR;

/**
 内部框的大小
 
 默认为0
 */
@property (nonatomic) CGFloat barInnerBorderWidth UI_APPEARANCE_SELECTOR;

/**
 内部框的颜色
 
 默认为nil
 */
@property (nonatomic) UIColor *barInnerBorderColor UI_APPEARANCE_SELECTOR;

/**
 内部与外框的间距
 
 默认为2
 */
@property (nonatomic) CGFloat barInnerPadding UI_APPEARANCE_SELECTOR;

/**
 填充色
 
 默认 defaultBarColor
 */
@property (nonatomic,strong) UIColor *barFillColor UI_APPEARANCE_SELECTOR;

/**
 背景色
 
 默认为白色
 */
@property (nonatomic,strong) UIColor *barBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 是否使用圆角
 
 UIAppearance 不能使用BOOL 所以使用NSInteger代替
 默认为YES
 */
@property (nonatomic) NSInteger usesRoundedCorners UI_APPEARANCE_SELECTOR;


+ (UIColor *)defaultBarColor;


@end
