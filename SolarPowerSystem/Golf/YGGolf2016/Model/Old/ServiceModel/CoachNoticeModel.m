//
//  CoachNoticeModel.m
//  Golf
//
//  Created by 黄希望 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachNoticeModel.h"

@implementation CoachNoticeModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    
    if (dic[@"msg_id"]) {
        self.msgId = [dic[@"msg_id"] intValue];
    }
    if (dic[@"member_id"]) {
        self.memberId = [dic[@"member_id"] intValue];
    }
    if (dic[@"msg_type"]) {
        self.msgType = [dic[@"msg_type"] intValue];
    }
    if (dic[@"relative_id"]) {
        self.relativeId = [dic[@"relative_id"] intValue];
    }
    if (dic[@"head_image"]) {
        self.headImage = dic[@"head_image"];
    }
    if (dic[@"display_name"]) {
        self.displayName = dic[@"display_name"];
    }
    if (dic[@"msg_time"]) {
        self.msgTime = dic[@"msg_time"];
    }
    
    if (dic[@"msg_content"]) {
        NSString *content = dic[@"msg_content"];
        NSRange range = [content rangeOfString:@"\n"];
        if (range.location != NSNotFound) {
            NSArray *arr = [content componentsSeparatedByString:@"\n"];
            self.valueOne = arr[0];
            self.valueTwo = arr[1];
        }else{
            self.valueOne = content;
        }
    }
    
    // 新加字段
    self.msgTitle = dic[@"msgTitle"];
    self.msgContent = dic[@"msg_content"];
    self.periodId = [dic[@"periodId"] integerValue];
    self.classId = [dic[@"periodId"] integerValue];
    
    return self;
}

- (void)dealloc
{
    self.headImage = nil;
    self.displayName = nil;
    self.valueOne = nil;
    self.valueTwo = nil;
    self.msgTime = nil;
    self.msgTitle = nil;
    self.msgContent = nil;
}

@end
