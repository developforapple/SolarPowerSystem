//
//  YGFlashSaleModel.m
//  Golf
//
//  Created by bo wang on 2016/11/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGFlashSaleModel.h"
#import <YYModel/YYModel.h>

@interface YGFlashSaleModel () <YYModel>

@end

@implementation YGFlashSaleModel

- (id)initWithDic:(id)data
{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if (self) {
        self.selling_price = [data[@"selling_price"] integerValue]/100;
        self.quantity = [data[@"quantity"] integerValue];
        self.flash_time = [data[@"flash_time"] longLongValue]/1000.f;
        self.end_time = [data[@"end_time"] longLongValue]/1000.f;
        self.flash_id = [data[@"flash_id"] integerValue];
        self.flash_price = [data[@"flash_price"] integerValue]/100;
        self.flash_status = [data[@"flash_status"] integerValue];
        self.flash_text = data[@"flash_text"];
        self.flash_notice = [data[@"flash_notice"] boolValue];
        self.server_time = [data[@"server_time"] longLongValue]/1000.f;
        if (self.server_time < .1f) {
            self.server_time = [[NSDate date] timeIntervalSince1970];
        }
    }
    return self;
}

YYModelDefaultCode;

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    self.selling_price /= 100;
    self.flash_time /= 1000.f;
    self.end_time /= 1000.f;
    self.server_time /= 1000.f;
    self.flash_price /= 100;
    
    if (self.server_time < .1f) {
        self.server_time = [[NSDate date] timeIntervalSince1970];
    }
    
    return YES;
}

- (YGFlashSaleStatus)flashSaleStatus
{
    if (self.flash_time > self.server_time) {
        return YGFlashSaleStatusWaiting;
    }
    if (self.end_time <= self.server_time) {
        return YGFlashSaleStatusEnd;
    }
    return YGFlashSaleStatusStarted;
}

- (BOOL)canAuction
{
    return [self flashSaleStatus] == YGFlashSaleStatusStarted && self.quantity > 0;
}

@end
