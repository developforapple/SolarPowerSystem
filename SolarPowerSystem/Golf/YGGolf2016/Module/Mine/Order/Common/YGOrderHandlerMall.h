//
//  YGOrderHandlerMall.h
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"

typedef NS_ENUM(NSUInteger, YGOrderMallAction) {
    YGOrderMallAction_Base = YGOrderTypeMall<<5,//占位
    YGOrderMallAction_Pay,      //立即支付
    YGOrderMallAction_Refund,   //申请退款
    YGOrderMallAction_Delete,   //删除
    YGOrderMallAction_Rebuy,    //重新购买
    YGOrderMallAction_Review,   //立即评价
    YGOrderMallAction_Received, //确认收货
    YGOrderMallAction_CancelRefund, //取消退款申请
};

/**
 商品订单的一些操作。全部使用通知进行回调。
 */
@interface YGOrderHandlerMall : YGOrderHandler

+ (NSString *)actionTitleString:(YGOrderMallAction)actionType;

/**
 处理预定义的一些操作
 */
- (void)handleAction:(YGOrderMallAction)actionType;

/**
 创建商品订单。
 */
- (void)create;

/**
 支付商品订单
 */
- (void)pay;

/**
 取消订单。当订单在待支付状态时可取消。
 */
- (void)cancel;

/**
 选择退款原因。不会修改order内的退款原因

 @param callback 回调
 */
- (void)selectRefundReason:(void (^)(NSString *reason))callback;

/**
 创建退款申请
 */
- (void)createRefund;

/**
 提交退款申请
 */
- (void)applyRefund;

/**
 创建取消退款申请
 */
- (void)createCancelRefund;

/**
 取消退款申请
 */
- (void)cancelRefund;

/**
 确认收货
 */
- (void)confirmReceived;

/**
 删除订单
 */
- (void)deleteOrder;

/**
 再次购买
 */
- (void)buyAgain;

/**
 评价订单商品
 */
- (void)review;

/**
 支付完成，查看订单。在“我的”tab中打开商城订单列表界面。其他tab返回首页。
 */
- (void)showOrderAfterPayment;

/**
 支付完成，返回首页。从不同的位置进入支付，有不同的返回位置
 */
- (void)backHomeAfterPayment;


@end
