//
//  CoachDataRpt.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDataRpt.h"

@implementation DataReport

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"product_name"]) {
            self.productName = dic[@"product_name"];
        }
        if (dic[@"order_count"]) {
            self.orderCount = [dic[@"order_count"] intValue];
        }
        if (dic[@"order_amount"]) {
            self.orderAmount = [dic[@"order_amount"] intValue];
        }
        if (dic[@"teach_count"]) {
            self.teachCount = [dic[@"teach_count"] intValue];
        }
    }
    return self;
}

@end

@implementation CoachDataRpt

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"order_count"]) {
            self.orderCount = [dic[@"order_count"] intValue];
        }
        if (dic[@"order_amount"]) {
            self.orderAmount = [dic[@"order_amount"] intValue];
        }
        if (dic[@"teach_count"]) {
            self.teachCount = [dic[@"teach_count"] intValue];
        }
        if (dic[@"data_list"]) {
            NSArray *arr = dic[@"data_list"];
            if (arr.count > 0) {
                NSMutableArray *mutArr = [NSMutableArray array];
                for (id obj in arr) {
                    DataReport *drpt = [[DataReport alloc] initWithDic:obj];
                    [mutArr addObject:drpt];
                }
                self.dataList = mutArr;
            }
        }
    }
    return self;
}

@end
