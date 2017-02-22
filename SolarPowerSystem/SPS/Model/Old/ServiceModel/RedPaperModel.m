//
//  RedPaperModel.m
//  Golf
//
//  Created by 黄希望 on 14-8-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "RedPaperModel.h"

@implementation RedPaperSubModel


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"phone_num"]) {
        self.phoneNum = [dic objectForKey:@"phone_num"];
    }
    if ([dic objectForKey:@"create_time"]) {
        self.createTime = [dic objectForKey:@"create_time"];
    }
    if ([dic objectForKey:@"coupon_amount"]) {
        self.couponAmount = [[dic objectForKey:@"coupon_amount"] intValue] / 100;
    }
    return self;
}

@end

@implementation RedPaperModel

@synthesize redPacketId,expireDate,beginDate,totalAmount,totalQuantity,usedAmount,usedQuantity,shareTitle,shareContent,shareUrl,usedList;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"redpacket_id"]) {
        self.redPacketId = [[dic objectForKey:@"redpacket_id"] intValue];
    }
    if ([dic objectForKey:@"expire_date"]) {
        self.expireDate = [dic objectForKey:@"expire_date"];
    }
    if ([dic objectForKey:@"begin_date"]) {
        self.beginDate = [dic objectForKey:@"begin_date"];
    }
    if ([dic objectForKey:@"total_amount"]) {
        self.totalAmount = [[dic objectForKey:@"total_amount"] intValue]/100;
    }
    if ([dic objectForKey:@"total_quantity"]) {
        self.totalQuantity = [[dic objectForKey:@"total_quantity"] intValue];
    }
    if ([dic objectForKey:@"used_amount"]) {
        self.usedAmount = [[dic objectForKey:@"used_amount"] intValue] /100 ;
    }
    if ([dic objectForKey:@"used_quantity"]) {
        self.usedQuantity = [[dic objectForKey:@"used_quantity"] intValue];
    }
    if ([dic objectForKey:@"share_title"]) {
        self.shareTitle = [dic objectForKey:@"share_title"] ;
    }
    if ([dic objectForKey:@"share_content"]) {
        self.shareContent = [dic objectForKey:@"share_content"] ;
    }
    if ([dic objectForKey:@"URL_SHARE"]) {
        self.shareUrl = [dic objectForKey:@"URL_SHARE"] ;
    }
    if ([dic objectForKey:@"used_list"]) {
        NSArray *array = [dic objectForKey:@"used_list"];
        if (array&&array.count>0) {
            NSMutableArray *mut = [NSMutableArray array];
            for (id obj in array) {
                RedPaperSubModel *m = [[RedPaperSubModel alloc] initWithDic:obj];
                [mut addObject:m];
            }
            self.usedList = mut;
        }
    }
    return self;
}

@end
