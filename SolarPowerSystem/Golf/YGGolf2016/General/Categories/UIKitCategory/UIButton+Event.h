//
//  UIButton+LW.h
//  Laiwang
//
//  Created by Lings on 13-11-29.
//  Copyright (c) 2013年 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Event)

/**
 *  扩大按钮的点击范围（insets必须不被button的superview给挡住）
 */
@property(nonatomic, assign) UIEdgeInsets hitEdgeInsets;

@end
