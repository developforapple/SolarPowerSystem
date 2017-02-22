//
//  OrderModel.h
//  Golf
//
//  Created by 青 叶 on 11-11-27.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OrderStatusEnum) {
    /** 预订完成 **/
    OrderStatusNew = 1,
    /** 完成消费 **/
    OrderStatusSuccess = 2,
    /** 未到场 **/
    OrderStatusNotPresent = 3,
    /** 已取消 **/
    OrderStatusCancel = 4,
    /**等待确认**/
    OrderStatusWaitEnsure = 5,
    /**等待支付**/
    OrderStatusWaitPay = 6,
    /**申请撤销**/
    OrderStatusSendRepeal = 7,
    /**已经撤销**/
    OrderStatusRepeal = 8,
};

@interface OrderModel : NSObject
@property(nonatomic) int orderId;
@property(nonatomic) int agentId;
@property(nonatomic) int clubId;
@property(nonatomic) int orderTotal;  // 总价 单位 元
@property(nonatomic) OrderStatusEnum orderStatus;
@property(nonatomic) PayTypeEnum payType;
@property(nonatomic) int memberNum;
@property(nonatomic) int realPrice;   //price      单价
@property(nonatomic) int payTotal;   //order_total 已支付
@property(nonatomic) int packageId;
@property(nonatomic) int yunbi;
@property(nonatomic) int absentNum;
@property(nonatomic,copy) NSString *teetimeTime;
@property(nonatomic,copy) NSString *teetimeDate;
@property(nonatomic,copy) NSString *unFreezeTime;
@property(nonatomic,copy) NSString *orderCreateTime;
@property(nonatomic,copy) NSString *clubName;
@property(nonatomic,copy) NSString *packageName;
/**
 order_type＝3表示是旅游套餐订单
 */
@property (nonatomic,assign) int orderType;

// 7.4 新增。时间戳
@property (nonatomic,assign) NSTimeInterval orderTime;

- (id)initWithDic:(id)data;

@end
