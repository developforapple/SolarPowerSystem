//
//  YGMallOrderReviewEditViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class YGMallOrderCommodity;

@interface YGMallOrderReviewEditViewCtrl : BaseNavController
@property (strong, nonatomic) YGMallOrderCommodity *commodity;
@property (assign, nonatomic) NSInteger orderId;
@property (copy, nonatomic) void (^didReviewedCommodity)(NSInteger orderId,NSInteger commodityId);
@end
