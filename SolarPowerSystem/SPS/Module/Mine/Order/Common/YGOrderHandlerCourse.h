//
//  YGOrderHandlerCourse.h
//  Golf
//
//  Created by bo wang on 2016/12/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"

@class TravelPackageOrder;

typedef NS_ENUM(NSUInteger, YGOrderCourseAction) {
    YGOrderCourseAction_Base = YGOrderTypeCourse<<5, //占位用
    YGOrderCourseAction_Rebooking,  //重新预定
    YGOrderCourseAction_Pay,        //立即支付
    YGOrderCourseAction_Delete,     //删除
    YGOrderCourseAction_CancelRefund,   //撤销取消订单的申请
};

@interface YGOrderHandlerCourse : YGOrderHandler

+ (NSString *)actionTitleString:(YGOrderCourseAction)actionType;

// 旅行套餐order。
@property (strong, nonatomic) TravelPackageOrder *packageOrder;

/**
 处理预处理的一些操作
 */
- (void)handleAction:(YGOrderCourseAction)actionType;

/**
 支付球场订单
 */
- (void)pay;

/**
 删除球场订单
 */
- (void)deleteOrder;

// 以下为旅行套餐所使用
- (void)cancel;     //取消订单。结果为“已取消”或者“正在申请退款”
- (void)cancelRefund;   //取消申请退款

@end
