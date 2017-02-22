//
//  OrderDetailModel.h
//  Golf
//
//  Created by 青 叶 on 11-11-27.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderModel.h"

@interface OrderDetailModel : OrderModel
@property(nonatomic,copy) NSString *courseName;
@property(nonatomic,copy) NSString *payState;
@property(nonatomic) BOOL isAllowCancel;
@property(nonatomic) int normalCancelBookHours;
@property(nonatomic) int holidayCancelBookHours;
@property(nonatomic,copy) NSString *linkPhone;
@property(nonatomic,copy) NSString *agentName;
@property(nonatomic,copy) NSString *memberName;
@property(nonatomic,copy) NSString *mobilePhone;
@property(nonatomic,copy) NSString *address;
@property(nonatomic,copy) NSString *payTime;
@property(nonatomic,copy) NSString *priceContent;
@property(nonatomic) float latitude;
@property(nonatomic) float longitude;

@property(nonatomic,copy) NSString *specName;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *trafficGuid;

@property(nonatomic,copy) NSString *userMemo;

@property (nonatomic) int returnAmount;
@property (nonatomic) int absentNum;

- (id)initWithDic:(id)data;

@end
