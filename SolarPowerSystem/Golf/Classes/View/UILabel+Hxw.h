//
//  UILabel+Hxw.h
//  Table
//
//  Created by user on 13-4-24.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Hxw)

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor*)color font:(float)size;

+ (CGRect)doubleLabelsWithFrame:(CGRect)frame title:(NSString*)title text:(NSString*)text font:(float)fontSize lineBreak:(BOOL)lineBreak contentColor:(UIColor*)color forView:(UIView *)view;

+ (CGRect)labelColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view;

+ (CGRect)labelColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view contentColor:(UIColor*)color;

+ (CGRect)labelDoubleColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view;

+ (CGRect)labelDoubleColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view contentColor:(UIColor*)color;

@end
