//
//  ReservationModel.m
//  Golf
//
//  Created by 黄希望 on 15/5/18.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ReservationModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation ReservationModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"reservation_id"]) {
            self.reservationId = [dic[@"reservation_id"] intValue];
        }
        if (dic[@"reservation_date"]) {
            self.reservationDate = dic[@"reservation_date"];
        }
        if (dic[@"reservation_time"]) {
            self.reservationTime = dic[@"reservation_time"];
        }
        if (dic[@"reservation_weekname"]) {
            self.reservationWeekname = dic[@"reservation_weekname"];
        }
        if (dic[@"reservation_status"]) {
            self.reservationStatus = [dic[@"reservation_status"] intValue];
        }
        if (dic[@"product_id"]) {
            self.productId = [dic[@"product_id"] intValue];
        }
        if (dic[@"product_name"]) {
            self.productName = dic[@"product_name"];
        }
        if (dic[@"coach_id"]) {
            self.coachId = [dic[@"coach_id"] intValue];
        }
        if (dic[@"member_id"]) {
            self.memberId = [dic[@"member_id"] intValue];
        }
        if (dic[@"nick_name"]) {
            self.nickName = dic[@"nick_name"];
        }
        
        // 用户名称备注
        NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.memberId];
        if ([remarkName isNotBlank]) {
            self.nickName = remarkName;
        }
        
        if (dic[@"create_time"]) {
            self.createTime = dic[@"create_time"];
        }
        if (dic[@"head_image"]) {
            self.headImage = dic[@"head_image"];
        }
        if (dic[@"teaching_site"]) {
            self.teachingSite = dic[@"teaching_site"];
        }
        if (dic[@"address"]) {
            self.address = dic[@"address"];
        }
        if (dic[@"longitude"]) {
            self.longitude = [dic[@"longitude"] doubleValue];
        }
        if (dic[@"latitude"]) {
            self.latitude = [dic[@"latitude"] doubleValue];
        }
        if (dic[@"distance"]) {
            self.distance = [dic[@"distance"] floatValue];
        }
        if (dic[@"comment_id"]) {
            self.commentId = [dic[@"comment_id"] intValue];
        }
        if (dic[@"public_class_id"]) {
            self.publicClassId = [dic[@"public_class_id"] intValue];
        }
        if (dic[@"star_level"]) {
            self.starLevel = [dic[@"star_level"] floatValue];
        }
        if (dic[@"comment_content"]) {
            self.commentContent = dic[@"comment_content"];
        }
        if (dic[@"can_cancel"]) {
            self.canCancel = [dic[@"can_cancel"] intValue] == 1 ? YES:NO;
        }
        if (dic[@"mobile_phone"]) {
            self.mobilePhone = dic[@"mobile_phone"];
        }
        if (dic[@"reply_content"]) {
            self.replyContent = dic[@"reply_content"];
        }
        if (dic[@"reply_time"]) {
            self.replyTime = dic[@"reply_time"];
        }
        if (dic[@"classId"]) {
            self.classId = [dic[@"classId"] intValue];
        }
        if (dic[@"period_id"]) {
            self.periodId = [dic[@"period_id"] intValue];
        }
    }
    return self;
}

-(NSString *)getReplyContentIfNotNull{
    if (self.replyContent != nil && self.replyContent.length > 0) {
        return [NSString stringWithFormat:@"[回复]%@",self.replyContent];
    }
    return @"";
}

@end
