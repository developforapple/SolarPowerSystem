//
//  CalendarPriceModel.m
//  Golf
//
//  Created by 黄希望 on 15/10/22.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "CalendarPriceModel.h"

@implementation CalendarPriceModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)data;

    if (dic[@"date"]) {
        self.date = dic[@"date"];
    }
    if (dic[@"holiday_name"]) {
        self.holidayName = dic[@"holiday_name"];
    }
    self.price = -1;
    if (dic[@"min_price"]) {
        self.price = [dic[@"min_price"] intValue] / 100;
    }
    if (dic[@"special_offer"]) {
        self.specialOffer = [dic[@"special_offer"] intValue];
    }
    return self;
}

@end
