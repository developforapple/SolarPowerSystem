//
//  OrderPayModel.m
//  Golf
//
//  Created by 黄希望 on 14-6-3.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "OrderPayModel.h"

NSString *PayTypeString(PayTypeEnum type){
    switch (type) {
        case PayTypeVip:return @"会员主场";break;
        case PayTypeDeposit:return @"球场现付";break;
        case PayTypeOnline:return @"全额预付";break;
        case PayTypeOnlinePart:return @"部分预付";break;
    }
    return @"默认";
}

@implementation OrderPayModel
@synthesize payXML,orderCreateTime,priceContent;

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
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
    if ([dic objectForKey:@"auto_confirm"]) {
        self.autoConfirm = [dic[@"auto_confirm"] intValue];
    }
    
    if (dic[@"share_title"]) {
        self.shareTitle = dic[@"share_title"];
    }
    if (dic[@"share_content"]) {
        self.shareContent = dic[@"share_content"];
    }
    if (dic[@"share_image"]) {
        self.shareImage = dic[@"share_image"];
    }
    if (dic[@"URL_SHARE"]) {
        self.shareUrl = dic[@"URL_SHARE"];
    }
    return self;
}


@end
