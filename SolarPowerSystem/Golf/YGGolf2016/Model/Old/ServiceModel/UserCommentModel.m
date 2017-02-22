//
//  UserCommentModel.m
//  Golf
//
//  Created by user on 13-6-20.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "UserCommentModel.h"

@implementation UserCommentModel


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"club_id"]) {
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if ([dic objectForKey:@"order_id"]) {
        self.orderId = [[dic objectForKey:@"order_id"] intValue];
    }
    if ([dic objectForKey:@"club_name"]) {
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if ([dic objectForKey:@"comment_count"]) {
        self.commentCount = [[dic objectForKey:@"comment_count"] intValue];
    }
    if ([dic objectForKey:@"total_level"]) {
        self.totalLevel = ceil([[dic objectForKey:@"total_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"mobile_phone"]) {
        self.mobilePhone = [dic objectForKey:@"mobile_phone"];
    }
    if ([dic objectForKey:@"comment_date"]) {
        self.commentDate = [dic objectForKey:@"comment_date"];
    }
    if ([dic objectForKey:@"grass_level"]) {
        self.grassLevel = ceil([[dic objectForKey:@"grass_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"service_level"]) {
        self.serviceLevel = ceil([[dic objectForKey:@"service_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"difficulty_level"]) {
        self.difficultyLevel = ceil([[dic objectForKey:@"difficulty_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"scenery_level"]) {
        self.sceneryLevel = ceil([[dic objectForKey:@"scenery_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"comment_content"]) {
        self.commentContent = [dic objectForKey:@"comment_content"];
    }
    if ([dic objectForKey:@"teetime_date"]) {
        self.teetimeDate = [dic objectForKey:@"teetime_date"];
    }
    return self;
}
@end
