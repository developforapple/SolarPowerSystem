//
//  TimeTableModel.m
//  Golf
//
//  Created by 黄希望 on 15/11/2.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TimeTableModel.h"

@implementation TimeTableModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)data;
    if (dic[@"time"]) {
        self.time = dic[@"time"];
    }
    self.minPrice = -1;
    if (dic[@"min_price"]) {
        self.minPrice = [dic[@"min_price"] intValue] / 100;
    }
    if (dic[@"special_offer"]) {
        self.specialOffer = [dic[@"special_offer"] intValue];
    }
    return self;
}

@end
