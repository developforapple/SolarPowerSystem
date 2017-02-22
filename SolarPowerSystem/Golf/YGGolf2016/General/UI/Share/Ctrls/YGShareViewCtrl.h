//
//  YGShareViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/5/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"
#import "DDShareUnit.h"
#import "UIViewController+Storyboard.h"
#import "YGShareNoteInfo.h"

@interface YGShareViewCtrl : YGBasePopViewController

- (void)setBlurReferView:(__weak UIView *)view;

/*!
 *  @brief 显示哪些分享模块
 */
@property (strong, nonatomic) NSArray<DDShareUnit *> *shareUnits;

/*!
 *  @brief noteView的显示内容。为nil时隐藏noteView
 */
@property (strong, nonatomic) YGShareNoteInfo *noteInfo;

/*!
 *  @brief 云高社区按钮是否可见
 *
 *  @param yungaoCommunityVisible YES，可见。NO，隐藏。
 *  @param callback               按钮的回调
 */
- (void)setYungaoCommunityVisible:(BOOL)yungaoCommunityVisible
                         callback:(void (^)(void)) callback;

@end
