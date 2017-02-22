//
//  TeachingTranModel.m
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingTranModel.h"

@implementation TeachingTranModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"order_id"]) {
            self.orderId = [dic[@"order_id"] intValue];
        }
        if (dic[@"order_state"]) {
            self.orderState = [dic[@"order_state"] intValue];
        }
        if (dic[@"tran_id"]) {
            self.tranId = [dic[@"tran_id"] intValue];
        }
        if (dic[@"pay_xml"]) {
            self.payXml = dic[@"pay_xml"];
        }
    }
    return self;
}

@end
