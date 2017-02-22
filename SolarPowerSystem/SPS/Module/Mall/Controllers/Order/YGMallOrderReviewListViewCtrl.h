//
//  YGMallOrderReviewListViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class YGMallOrderModel;

/**
 订单中商品的评价列表
 */
@interface YGMallOrderReviewListViewCtrl : BaseNavController
@property (assign, nonatomic) NSInteger orderId;

// 订单的全部商品均已评价后的回调
@property (copy, nonatomic) void (^didReviewedOrder)(NSInteger orderId);
@end
