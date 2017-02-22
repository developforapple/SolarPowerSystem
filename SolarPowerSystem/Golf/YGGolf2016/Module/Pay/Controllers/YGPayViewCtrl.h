//
//  YGPayViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "YGPayment.h"

@class YGOrderHandler;

NS_ASSUME_NONNULL_BEGIN

/**
 支付界面。使用push显示。
 */
@interface YGPayViewCtrl : BaseNavController

/**
 支付内容
 */
@property (strong, nonatomic) YGPayment *payment;

/**
 订单操作处理类。在这里强引用，防止上一个控制器释放造成支付无法回调。
 */
@property (strong, nonatomic) __kindof YGOrderHandler *handler;

/**
 支付过程中的回调。
 成功：支付成功。
 失败：失败失败。
 取消：支付取消
 */
@property (copy, nullable, nonatomic) void (^payCallback)(YGPayStatus status,YGPayment *payment);

// 查看订单的操作
@property (copy, nullable, nonatomic) void (^showOrderAction)(NSInteger orderId);

// 点击返回按钮的操作，不设置时返回上一页
@property (copy, nullable, nonatomic) void (^popAction)(void);

// 返回首页的事件
@property (copy, nullable, nonatomic) void (^backHomeAction)(void);

@end

NS_ASSUME_NONNULL_END
