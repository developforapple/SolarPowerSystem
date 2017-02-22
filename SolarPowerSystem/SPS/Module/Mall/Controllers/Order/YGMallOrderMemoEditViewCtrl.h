//
//  YGMallOrderMemoEditViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class YGMallOrderModel;

/**
 修改订单用户留言
 */
@interface YGMallOrderMemoEditViewCtrl : BaseNavController
@property (strong, nonatomic) YGMallOrderModel *order;
@property (copy, nonatomic) void (^memoDidChanged)(YGMallOrderModel *order);
@end
