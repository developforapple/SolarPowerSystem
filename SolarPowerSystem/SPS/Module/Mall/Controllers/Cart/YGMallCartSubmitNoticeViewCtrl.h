//
//  YGMallCartSubmitNoticeViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

@class YGMallCart;

/**
 显示弹出框，提示用户一些商品无法进行合并支付。需要用户进行选择。
 */
@interface YGMallCartSubmitNoticeViewCtrl : YGBasePopViewController

@property (strong, nonatomic) YGMallCart *cart;

// 用户选择某个类型时的回调
@property (copy, nonatomic) void (^didChoiceCommodities)(NSArray *commodities);
// 用户点击确定提交时的回调
@property (copy, nonatomic) void (^willSubmitCommodity)(NSInteger type);

@end
