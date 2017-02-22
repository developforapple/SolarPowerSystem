//
//  OrderModel.m
//  Golf
//
//  Created by 青 叶 on 11-11-27.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "OrderModel.h"
#import "Utilities.h"

@implementation OrderModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"order_id"]){
        self.orderId = [[dic objectForKey:@"order_id"] intValue];
    }
    if([dic objectForKey:@"agent_id"]){
        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
    }
    if([dic objectForKey:@"club_id"]){
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if([dic objectForKey:@"package_id"]){
        self.packageId = [[dic objectForKey:@"package_id"] intValue];
    }
    if([dic objectForKey:@"club_name"]){
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if([dic objectForKey:@"package_name"]){
        self.packageName = [dic objectForKey:@"package_name"];
    }
    if([dic objectForKey:@"order_create_time"]){
        self.orderCreateTime = [dic objectForKey:@"order_create_time"];
    }
    if([dic objectForKey:@"pay_type"]){
        self.payType = (PayTypeEnum)[[dic objectForKey:@"pay_type"] intValue];
    }
    if([dic objectForKey:@"order_total"]){
        self.payTotal = [[dic objectForKey:@"order_total"] intValue]/100;
    }
    if([dic objectForKey:@"order_state"]){
        self.orderStatus = (OrderStatusEnum)[[dic objectForKey:@"order_state"] intValue];
    }
    if([dic objectForKey:@"teetime_time"]){
        self.teetimeTime = [dic objectForKey:@"teetime_time"];
    }
    if([dic objectForKey:@"teetime_date"]){
        self.teetimeDate = [dic objectForKey:@"teetime_date"];
    }
    if([dic objectForKey:@"unfreeze_time"]){
        self.unFreezeTime = [dic objectForKey:@"unfreeze_time"];
    }
    if([dic objectForKey:@"member_num"]){
        self.memberNum = [[dic objectForKey:@"member_num"] intValue];
    }
    if([dic objectForKey:@"absent_num"]){
        self.absentNum = [[dic objectForKey:@"absent_num"] intValue];
    }
    if([dic objectForKey:@"price"]){
        self.realPrice = [[dic objectForKey:@"price"] intValue] / 100;
    }
    if([dic objectForKey:@"give_yunbi"]){
        self.yunbi = [[dic objectForKey:@"give_yunbi"] intValue] / 100 * (self.memberNum-self.absentNum);
    }
    if ([dic objectForKey:@"order_type"]) {
        self.orderType = [[dic objectForKey:@"order_type"] intValue];
    }
    
    if (self.orderType == 3) {
        self.orderTotal = [dic[@"order_price"] intValue]/100;
    }else{
        self.orderTotal = self.realPrice * self.memberNum;
    }
    
    self.orderTime = [dic[@"orderTime"] longLongValue]/1000.f;
    
    return self;
}

@end
