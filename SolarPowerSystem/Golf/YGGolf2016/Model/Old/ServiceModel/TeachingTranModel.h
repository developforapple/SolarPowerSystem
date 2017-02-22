//
//  TeachingTranModel.h
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeachingCoachModel.h"

// ***** 教学提交订单成功返回数据 ***** //
@interface TeachingTranModel : NSObject

// 订单属性
@property (nonatomic,assign) int orderId;
@property (nonatomic,assign) int orderState;
@property (nonatomic,assign) int tranId;
@property (nonatomic,strong) NSString *payXml;

- (id)initWithDic:(id)data;

@end
