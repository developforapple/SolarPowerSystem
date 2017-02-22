//
//  TeachingOrderModel.m
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation TeachingOrderModel

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
        if (dic[@"price"]) {
            self.price = [dic[@"price"] intValue] / 100;
        }
        if (dic[@"order_total"]) {
            self.orderTotal = [dic[@"order_total"] intValue] / 100;
        }
        if (dic[@"give_yunbi"]) {
            self.giveYunbi = [dic[@"give_yunbi"] intValue] / 100;
        }
        if (dic[@"product_id"]) {
            self.productId = [dic[@"product_id"] intValue];
        }
        if (dic[@"product_name"]) {
            self.productName = dic[@"product_name"];
        }
        if (dic[@"academy_id"]) {
            self.academyId = [dic[@"academy_id"] intValue];
        }
        if (dic[@"class_type"]) {
            self.classType = [dic[@"class_type"] intValue];
        }
        if (dic[@"coach_id"]) {
            self.coachId = [dic[@"coach_id"] intValue];
        }
        if (dic[@"display_name"]) {
            self.displayName = dic[@"display_name"];
        }
        if (dic[@"nick_name"]) {
            self.nickName = dic[@"nick_name"];
        }
        if (dic[@"head_image"]) {
            self.headImage = dic[@"head_image"] ;
        }
        if (dic[@"class_hour"]) {
            self.classHour = [dic[@"class_hour"] intValue];
        }
        if (dic[@"link_phone"]) {
            self.linkPhone = dic[@"link_phone"];
        }
        if (dic[@"member_id"]) {
            self.memberId = [dic[@"member_id"] intValue];
        }
        
        self.orderTimestamp = [dic[@"orderTime"] longLongValue]/1000.f;
        
        // 用户名称备注
        NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.memberId];
        if ([remarkName isNotBlank]) {
            self.nickName = remarkName;
        }
        
        // 教练名称备注
        NSString *coachRemarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.coachId];
        if ([coachRemarkName isNotBlank]) {
            self.displayName = coachRemarkName;
        }
        
    }
    return self;
}

@end
