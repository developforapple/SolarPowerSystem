//
//  YGOrderCommon.h
//  Golf
//
//  Created by bo wang on 2016/11/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGOrderCommon_h
#define YGOrderCommon_h

typedef NS_ENUM(NSUInteger, YGOrderType) {
    YGOrderTypeCourse = 3,      //球场
    YGOrderTypeMall = 1,        //商城
    YGOrderTypeTeaching = 2,    //教学订单
    YGOrderTypeTeachBooking = 4,//练习场订场
};

typedef NS_ENUM(NSUInteger, YGOrderUpdateMode) {
    YGOrderUpdateModeInsert, //增
    YGOrderUpdateModeReload, //改
    YGOrderUpdateModeRemove  //删
};

@protocol YGOrderModel <NSObject>
@required
- (NSTimeInterval)gp_timestamp;
- (NSInteger)gp_orderId;
@end

#import "OrderModel.h"
#import "TeachingOrderModel.h"
#import "YGMallOrderModel.h"
#import "YGThrift+Teaching.h"
#import "TravelPackageService.h"

@interface OrderModel (General)<YGOrderModel>@end
@interface YGMallOrderModel (General)<YGOrderModel>@end
@interface TeachingOrderModel (General)<YGOrderModel>@end
@interface VirtualCourseOrderBean (General)<YGOrderModel>@end
@interface TravelPackageOrder (General)<YGOrderModel>@end

// 订单类型是有效类型
FOUNDATION_EXTERN BOOL isValidOrderType(YGOrderType type);
// 订单类型的标题
FOUNDATION_EXTERN NSString * getOrderTitle(YGOrderType type);
// 订单类型的图标
FOUNDATION_EXTERN UIImage * getOrderIcon(YGOrderType type);
// 订单列表入口的提示
FOUNDATION_EXTERN NSString * getOrderEntranceNote(YGOrderType type);
// 判断order实例属于什么类型的订单. 不符合条件的参数返回NSNotFound
FOUNDATION_EXTERN YGOrderType typeOfOrder(id<YGOrderModel> order);
// order是否是type对应的order类型
FOUNDATION_EXTERN BOOL isValidOrderWithType(id order,YGOrderType type);
// 返回order类型对应的cellClass
FOUNDATION_EXTERN Class orderCellClassOfOrderType(YGOrderType type);
// 返回order类型对应的cell的identifier
FOUNDATION_EXTERN NSString *orderCellIdentifierOfOrderType(YGOrderType type);

#endif /* YGOrderCommon_h */
