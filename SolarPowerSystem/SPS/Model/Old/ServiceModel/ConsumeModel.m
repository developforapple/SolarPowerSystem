//
//  ConsumeModel.m
//  Golf
//
//  Created by 黄希望 on 14-8-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "ConsumeModel.h"

@implementation ConsumeModel

@synthesize tranId,tranTime,tranAmount,tranName,tranType,currBalance,description,relativeId,relativeType;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"tran_id"]) {
        self.tranId = [[dic objectForKey:@"tran_id"] intValue];
    }
    if ([dic objectForKey:@"tran_time"]) {
        self.tranTime = [dic objectForKey:@"tran_time"];
    }
    if ([dic objectForKey:@"tran_amount"]) {
        self.tranAmount= [[dic objectForKey:@"tran_amount"] intValue]/100;
    }
    if ([dic objectForKey:@"curr_balance"]) {
        self.currBalance = [[dic objectForKey:@"curr_balance"] intValue]/100;
    }
    if ([dic objectForKey:@"tran_type"]) {
        self.tranType = [[dic objectForKey:@"tran_type"] intValue];
    }
    if ([dic objectForKey:@"tran_name"]) {
        self.tranName = [dic objectForKey:@"tran_name"];
    }
    if ([dic objectForKey:@"description"]) {
        self.description = [dic objectForKey:@"description"];
    }
    if ([dic objectForKey:@"relative_type"]) {
        self.relativeType = [[dic objectForKey:@"relative_type"] intValue];
    }
    if ([dic objectForKey:@"relative_id"]) {
        self.relativeId = [[dic objectForKey:@"relative_id"] intValue];
    }
    return self;
}

@end
