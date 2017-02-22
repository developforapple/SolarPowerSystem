//
//  TeachingSubmitInfo.m
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingSubmitInfo.h"

@implementation TeachingSubmitInfo

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"order_id"]) {
            self.orderId = [dic[@"order_id"] intValue];
        }
        if (dic[@"order_time"]) {
            self.orderTime = dic[@"order_time"];
        }
        if (dic[@"order_state"]) {
            self.orderState = [dic[@"order_state"] intValue];
        }
        if (dic[@"order_total"]) {
            self.orderTotal = [dic[@"order_total"] intValue] / 100;
        }
        if (dic[@"product_id"]) {
            self.productId = [dic[@"product_id"] intValue];
        }
        if (dic[@"academy_id"]) {
            self.academyId = [dic[@"academy_id"] intValue];
        }
        if (dic[@"class_type"]) {
            self.classType = [dic[@"class_type"] intValue];
        }
    }
    return self;
}
@end
