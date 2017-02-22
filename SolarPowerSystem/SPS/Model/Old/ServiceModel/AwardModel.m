//
//  AwardModel.m
//  Golf
//
//  Created by 黄希望 on 14-7-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "AwardModel.h"

@implementation AwardModel
@synthesize awardType,totalAmount,totalQuantity,awardTitle,awardContent,awardUrl;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"award_type"]) {
        self.awardType = [[dic objectForKey:@"award_type"] intValue];
    }
    if ([dic objectForKey:@"total_amount"]) {
        self.totalAmount = [[dic objectForKey:@"total_amount"] intValue];
    }
    if ([dic objectForKey:@"total_quantity"]) {
        self.totalQuantity = [[dic objectForKey:@"total_quantity"] intValue];
    }
    if ([dic objectForKey:@"award_title"]) {
        self.awardTitle = [dic objectForKey:@"award_title"];
    }
    if ([dic objectForKey:@"award_content"]) {
        self.awardContent = [dic objectForKey:@"award_content"];
    }
    if ([dic objectForKey:@"award_url"]) {
        self.awardUrl = [dic objectForKey:@"award_url"];
    }
    return self;
}

@end
