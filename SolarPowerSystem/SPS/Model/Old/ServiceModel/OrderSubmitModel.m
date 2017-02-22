//
//  OrderSubmitModel.m
//  Golf
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "OrderSubmitModel.h"

@implementation OrderSubmitModel
@synthesize orderId = _orderId;
@synthesize payTotal = _payTotal;
@synthesize payType = _payType;
@synthesize tranId = _tranId;
@synthesize payXML = _payXml;
@synthesize orderCreateTime = _orderCreateTime;
@synthesize priceContent = _priceContent;
@synthesize orderState = _orderState;


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
    if([dic objectForKey:@"order_create_time"]){
        self.orderCreateTime = [dic objectForKey:@"order_create_time"];
    } 
    if([dic objectForKey:@"pay_type"]){
        self.payType = (PayTypeEnum)[[dic objectForKey:@"pay_type"] intValue];
    }
    if([dic objectForKey:@"order_total"]){
        self.payTotal = [[dic objectForKey:@"order_total"] intValue]/100;
    }
    if([dic objectForKey:@"pay_xml"]){
        self.payXML = [dic objectForKey:@"pay_xml"];
    }
    if([dic objectForKey:@"tran_id"]){
        self.tranId = [[dic objectForKey:@"tran_id"] intValue];
    }
    if([dic objectForKey:@"price_content"]){
        self.priceContent = [dic objectForKey:@"price_content"];
    }
    if ([dic objectForKey:@"order_state"]) {
        self.orderState = [[dic objectForKey:@"order_state"] intValue];
    }
    return self;
}


@end
