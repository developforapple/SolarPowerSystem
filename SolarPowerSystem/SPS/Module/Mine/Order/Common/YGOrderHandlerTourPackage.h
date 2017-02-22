//
//  YGOrderHandlerTourPackage.h
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"

typedef NS_ENUM(NSUInteger, YGOrderTourPackageAction) {
    YGOrderTourPackageAction_Base = YGOrderTypeCourse<<5,
    
    YGOrderTourPackageAction_Cancel,        //支付了的订单进入退款流程
    YGOrderTourPackageAction_Refund,        //取消订单。未支付的订单直接取消
    YGOrderTourPackageAction_Delete,        //删除订单
    YGOrderTourPackageAction_Pay,           //支付
    YGOrderTourPackageAction_Rebooking,     //再次预定
};

@interface YGOrderHandlerTourPackage : YGOrderHandler

+ (NSString *)actionTitleString:(YGOrderTourPackageAction)actionType;

// 会自动判断order类型是 OrderModel 还是 TravelPackageOrder。
// 两种order 都只包含 id status packageid 三个内容
+ (instancetype)handlerWithOrder:(id)order;

@property (strong, nonatomic) OrderModel *oldOrder;

- (void)handleAction:(YGOrderTourPackageAction)actionType;

@end
