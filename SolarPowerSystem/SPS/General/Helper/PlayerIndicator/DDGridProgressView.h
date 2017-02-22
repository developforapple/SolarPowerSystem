//
//  DDGridProgressView.h
//  JuYouQu
//
//  Created by Normal on 16/2/17.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDGridProgressView : UIProgressView

@property (nonatomic) UIColor *backColor;           //背景颜色。默认RGB 12 7 33
@property (nonatomic) UIColor *gridColor;           //格子颜色。默认白色

@property (nonatomic) NSUInteger numberOfGrids;     //格子数量。默认1。1个格子，0个分隔线。
@property (nonatomic) CGFloat gridSeparateLineWidth;//格子的分割线宽度。 默认1.
@property (nonatomic) UIColor *gridSeparateLineColor;//格子的分隔线颜色。默认同backColor;
@property (nonatomic) CGFloat borderWidth;          //外边框宽度。默认1。为0时不显示外边框。
@property (nonatomic) UIColor *borderColor;         //外边框颜色。默认同backColor;

@property (nonatomic) BOOL jumpUpdate;              //默认为YES。是否是跳跃式的更新进度条

@end
