//
//  CommodityCommentModel.m
//  Golf
//
//  Created by 黄希望 on 14-5-29.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "CommodityCommentModel.h"

@implementation CommodityCommentModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"member_id"]) {
        self.memberId = [[dic objectForKey:@"member_id"] intValue];
    }
    if ([dic objectForKey:@"member_rank"]) {
        self.memberLevel = [[dic objectForKey:@"member_rank"] intValue];
    }
    if ([dic objectForKey:@"display_name"]) {
        self.displayName = [dic objectForKey:@"display_name"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"mobile_phone"]) {
        self.mobilePhone = [dic objectForKey:@"mobile_phone"];
    }
    if ([dic objectForKey:@"comment_date"]) {
        self.commentDate = [dic objectForKey:@"comment_date"];
    }
    if ([dic objectForKey:@"comment_level"]) {
        self.commentLevel = [[dic objectForKey:@"comment_level"] intValue];
    }
    if ([dic objectForKey:@"comment_content"]) {
        self.commentContent = [dic objectForKey:@"comment_content"];
    }
    return self;
}

@end
