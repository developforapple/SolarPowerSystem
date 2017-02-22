//
//  ClubSpreeModel.m
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubSpreeModel.h"

@implementation ClubSpreeModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if (dic[@"spree_id"]) {
        self.spreeId = [dic[@"spree_id"] intValue];
    }
    if (dic[@"spree_name"]) {
        self.spreeName = dic[@"spree_name"];
    }
    if (dic[@"city_id"]) {
        self.cityId = [dic[@"city_id"] intValue];
    }
    if (dic[@"club_id"]) {
        self.clubId = [dic[@"club_id"] intValue];
    }
    if (dic[@"club_name"]) {
        self.clubName = dic[@"club_name"];
    }
    if (dic[@"club_photo"]) {
        self.clubPhoto = dic[@"club_photo"];
    }
    if (dic[@"remote"]) {
        self.remote = [dic[@"remote"] floatValue];
    }
    if (dic[@"longitude"]) {
        self.longitude = [dic[@"longitude"] doubleValue];
    }
    if (dic[@"latitude"]) {
        self.latitude = [dic[@"latitude"] doubleValue];
    }
    if (dic[@"original_price"]) {
        self.originalPrice = [dic[@"original_price"] intValue] / 100;
    }
    if (dic[@"current_price"]) {
        self.currentPrice = [dic[@"current_price"] intValue] / 100;
    }
    if (dic[@"stock_quantity"]) {
        self.stockQuantity = [dic[@"stock_quantity"] intValue];
    }
    if (dic[@"sold_quantity"]) {
        self.soldQuantity = [dic[@"sold_quantity"] intValue];
    }
    if (dic[@"min_buy_quantity"]) {
        self.minBuyQuantity = [dic[@"min_buy_quantity"] intValue];
    }
    if (dic[@"pay_type"]) {
        self.payType = [dic[@"pay_type"] intValue];
    }
    if (dic[@"prepay_amount"]) {
        self.prepayAmount = [dic[@"prepay_amount"] intValue] / 100;
    }
    if (dic[@"spree_time"]) {
        self.spreeTime = dic[@"spree_time"];
    }
    if (dic[@"tee_date"]) {
        self.teeDate = dic[@"tee_date"];
    }
    if (dic[@"start_time"]) {
        self.startTime = dic[@"start_time"];
    }
    if (dic[@"end_time"]) {
        self.endTime = dic[@"end_time"];
    }
    if (dic[@"give_yunbi"]) {
        self.giveYunbi = [dic[@"give_yunbi"] intValue] / 100;
    }
    if (dic[@"price_content"]) {
        self.priceContent = dic[@"price_content"];
    }
    if (dic[@"description"]) {
        self.description_ = dic[@"description"];
    }
    if (dic[@"cancel_note"]) {
        self.cancelNote = dic[@"cancel_note"];
    }
    if (dic[@"agent_id"]) {
        self.agentId = [dic[@"agent_id"] intValue];
    }
    if (dic[@"agent_name"]) {
        self.agentName = dic[@"agent_name"] ;
    }
    if (dic[@"has_invoice"]) {
        self.hasInvoice = [dic[@"has_invoice"] integerValue];
    }
    return self;
}

@end
