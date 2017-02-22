//
//  YGOrderCommon.c
//  Golf
//
//  Created by bo wang on 2016/11/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#include "YGOrderCommon.h"
#import "YGOrderMallCell.h"
#import "YGOrderCourseCell.h"
#import "YGOrderTeachingCell.h"
#import "YGOrderTeachBookingCell.h"

BOOL isValidOrderType(YGOrderType type){
    return type==YGOrderTypeCourse || type==YGOrderTypeMall || type==YGOrderTypeTeaching || type==YGOrderTypeTeachBooking;
}

NSString * getOrderTitle(YGOrderType type){
     NSString *title;
     switch (type) {
         case YGOrderTypeMall: title = @"商城订单";break;
         case YGOrderTypeCourse: title = @"球场订单";break;
         case YGOrderTypeTeaching:title = @"教学订单";break;
         case YGOrderTypeTeachBooking:title = @"练习场订单";break;
     }
     return title;
}

UIImage * getOrderIcon(YGOrderType type){
    NSString *title;
    switch (type) {
        case YGOrderTypeMall: title = @"shangchengicon_";break;
        case YGOrderTypeCourse: title = @"qiuchangicon_";break;
        case YGOrderTypeTeaching:title = @"ic_jiaoxuedingdan";break;
        case YGOrderTypeTeachBooking:title = @"ic_teachbooking";break;
    }
    return [UIImage imageNamed:title];
}

NSString * getOrderEntranceNote(YGOrderType type){
    NSString *title;
    switch (type) {
        case YGOrderTypeMall: title = @"逛逛商城";break;
        case YGOrderTypeCourse: title = @"查看球场";break;
        case YGOrderTypeTeaching:title = @"查看课程";break;
        case YGOrderTypeTeachBooking:title = @"查看练习场";break;
    }
    return title;
}

YGOrderType typeOfOrder(id<YGOrderModel> order)
{
    if ([order isKindOfClass:[OrderModel class]] || [order isKindOfClass:[TravelPackageOrder class]]) {
        return YGOrderTypeCourse;
    }else if ([order isKindOfClass:[YGMallOrderModel class]]) {
        return YGOrderTypeMall;
    }else if ([order isKindOfClass:[TeachingOrderModel class]]){
        return YGOrderTypeTeaching;
    }else if ([order isKindOfClass:[VirtualCourseOrderBean class]]){
        return YGOrderTypeTeachBooking;
    }
    return NSNotFound;
}

BOOL isValidOrderWithType(id order,YGOrderType type){
    switch (type) {
        case YGOrderTypeMall: return [order isKindOfClass:[YGMallOrderModel class]];break;
        case YGOrderTypeCourse:{
            return [order isKindOfClass:[OrderModel class]] || [order isKindOfClass:[TravelPackageOrder class]];
        }   break;
        case YGOrderTypeTeaching:return [order isKindOfClass:[TeachingOrderModel class]];break;
        case YGOrderTypeTeachBooking:return [order isKindOfClass:[VirtualCourseOrderBean class]];break;
    }
    return NO;
}

Class orderCellClassOfOrderType(YGOrderType type)
{
    switch (type) {
        case YGOrderTypeCourse:return [YGOrderCourseCell class];break;
        case YGOrderTypeMall:return [YGOrderMallCell class];break;
        case YGOrderTypeTeaching:return [YGOrderTeachingCell class];break;
        case YGOrderTypeTeachBooking:return [YGOrderTeachBookingCell class];break;
    }
    return NULL;
}

NSString *orderCellIdentifierOfOrderType(YGOrderType type)
{
    switch (type) {
        case YGOrderTypeCourse:return kYGOrderCourseCell;break;
        case YGOrderTypeMall:return kYGOrderMallCell;break;
        case YGOrderTypeTeaching:return kYGOrderTeachingCell;break;
        case YGOrderTypeTeachBooking:return kYGOrderTeachBookingCell;break;
    }
    return nil;
}

@implementation OrderModel (General)
-  (NSTimeInterval)gp_timestamp
{
    return self.orderTime;
}

- (NSInteger)gp_orderId
{
    return self.orderId;
}
@end

@implementation YGMallOrderModel (General)
-  (NSTimeInterval)gp_timestamp
{
    return self.orderTime;
}

- (NSInteger)gp_orderId
{
    return self.order_id;
}
@end

@implementation TeachingOrderModel (General)
-  (NSTimeInterval)gp_timestamp
{
    return self.orderTimestamp;
}

- (NSInteger)gp_orderId
{
    return self.orderId;
}
@end

@implementation VirtualCourseOrderBean (General)
-  (NSTimeInterval)gp_timestamp
{
    return self.orderTime/1000.f;
}

- (NSInteger)gp_orderId
{
    return self.orderId;
}
@end

@implementation TravelPackageOrder (General)
- (NSTimeInterval)gp_timestamp
{
    return self.orderTime/1000.f;
}

- (NSInteger)gp_orderId
{
    return self.orderId;
}
@end
