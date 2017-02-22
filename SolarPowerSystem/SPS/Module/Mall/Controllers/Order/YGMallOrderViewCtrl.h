//
//  YGMallOrderViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "YGMallOrderModel.h"

@interface YGMallOrderViewCtrl : BaseNavController

@property (strong, nonatomic) YGMallOrderModel *order;
@property (assign, nonatomic) NSInteger orderId;

// 是否是提交退款申请的订单
@property (assign, nonatomic) BOOL isApplyRefund;

- (void)refreshOrderInfo;

@property (copy, nonatomic) void (^didSubmitOrderCallback)(void);

@end
