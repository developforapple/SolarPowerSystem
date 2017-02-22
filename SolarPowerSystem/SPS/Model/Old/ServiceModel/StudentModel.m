//
//  StudentModel.m
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "StudentModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation StudentModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    
    if (dic[@"member_id"]) {
        self.memberId = [dic[@"member_id"] intValue];
    }
    if (dic[@"nick_name"]) {
        self.nickName = dic[@"nick_name"];
    }
    if (dic[@"remark_name"]) {
        self.displayName = dic[@"remark_name"];
        NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.memberId];
        if ([remarkName isNotBlank]) {
            self.displayName = remarkName;
        }
    }
    if (!(self.displayName && [self.displayName length] > 0)) {
        self.displayName = (self.nickName && [self.nickName length] > 0) ? self.nickName : @"";
    }
    
    if (dic[@"head_image"]) {
        self.headImage = dic[@"head_image"];
    }
    if (dic[@"remain_hour"]) {
        self.remainHour = [dic[@"remain_hour"] intValue];
    }
    if (dic[@"wait_hour"]) {
        self.waitHour = [dic[@"wait_hour"] intValue];
    }
    if (dic[@"complete_hour"]) {
        self.completeHour = [dic[@"complete_hour"] intValue];
    }
    if (dic[@"mobile_phone"]) {
        self.mobilePhone = dic[@"mobile_phone"];
    }
    if (dic[@"is_followed"]) {
        self.isFollowed = [dic[@"is_followed"] intValue];
    }
    return self;
}

@end
