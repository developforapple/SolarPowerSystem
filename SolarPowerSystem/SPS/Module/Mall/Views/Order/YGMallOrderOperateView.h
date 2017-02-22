//
//  YGMallOrderOperateView.h
//  Golf
//
//  Created by bo wang on 2016/10/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallOrderModel.h"

typedef NS_ENUM(NSUInteger, YGMallOrderOperate) {
    YGMallOrderOperateCancel,       //取消订单
    YGMallOrderOperatePay,          //支付
    YGMallOrderOperateService,      //联系客服
    YGMallOrderOperateApplyRefund,  //申请退款
    YGMallOrderOperateCancelRefund, //取消申请退款
    YGMallOrderOperateReceived,       //确认收货
    YGMallOrderOperateDelete,         //删除订单
    YGMallOrderOperateReview,         //立即评价
    YGMallOrderOperateBuyAgain,       //再次购买
};

@interface YGMallOrderOperateView : UIView
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *middleBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@property (strong, readonly, nonatomic) YGMallOrderModel *order;
- (void)configureWithOrder:(YGMallOrderModel *)order;

// 每次操作均会回调。部分操作是直接在内部处理的。
@property (copy, nonatomic) void (^willOperateOrder)(YGMallOrderModel *order, YGMallOrderOperate operate);
// 有些操作是在内部处理，完成后将会进行回调。
@property (copy, nonatomic) void (^didOperatedOrder)(YGMallOrderModel *newOrder, YGMallOrderOperate operate);

@end
