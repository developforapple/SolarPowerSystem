//
//  PublicCourseDetail.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseDetail.h"
#import "CoachDetailCommentModel.h"


@implementation JoinModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"member_id"]) {
            self.memberId = [dic[@"member_id"] intValue];
        }
        if (dic[@"display_name"]) {
            self.displayName = dic[@"display_name"];
        }
        if (dic[@"member_rank"]) {
            self.memberLevel = [dic[@"member_rank"] intValue];
        }
        if (dic[@"gender"]) {
            self.gender = [dic[@"gender"] intValue];
        }
        if (dic[@"handicap"]) {
            self.handicap = [dic[@"handicap"] intValue];
        }
        if (dic[@"birthday"]) {
            self.birthday = dic[@"birthday"];
        }
        if (dic[@"head_image"]) {
            self.headImage = dic[@"head_image"];
        }
        if (dic[@"join_time"]) {
            self.joinTime = dic[@"join_time"];
        }
    }
    return self;
}

@end

@implementation PublicCourseDetail

- (id)initWithDic:(id)data{
    self = [super initWithDic:data];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"product_intro"]) {
            self.productIntro = dic[@"product_intro"];
        }
        if (dic[@"product_detail"]) {
            self.productDetail = dic[@"product_detail"];
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
        if (dic[@"comment_count"]) {
            self.commentCount = [dic[@"comment_count"] intValue];
        }
        if (dic[@"coach_id"]) {
            self.coachId = [dic[@"coach_id"] intValue];
        }
        if (dic[@"display_name"]) {
            self.displayName = dic[@"display_name"];
        }
        if (dic[@"nick_name"]) {
            self.nickName = dic[@"nick_name"];
        }
        if (dic[@"head_image"]) {
            self.headImage = dic[@"head_image"];
        }
        if (dic[@"coach_level"]) {
            self.coachLevel = [dic[@"coach_level"] intValue];
        }
        if (dic[@"star_level"]) {
            self.starLevel = [dic[@"star_level"] floatValue];
        }
        if (dic[@"picture_list"]) {
            self.pictureList = dic[@"picture_list"];
        }
        if (dic[@"share_title"]) {
            self.shareTitle = dic[@"share_title"];
        }
        if (dic[@"share_content"]) {
            self.shareContent = dic[@"share_content"];
        }
        if (dic[@"share_image"]) {
            self.shareImage = dic[@"share_image"];
        }
        if (dic[@"URL_SHARE"]) {
            self.shareUrl = dic[@"URL_SHARE"];
        }
        if (dic[@"join_list"]) {
            NSArray *list = dic[@"join_list"];
            if (list.count>0) {
                NSMutableArray *mut = [NSMutableArray array];
                for (id obj in list) {
                    JoinModel *model = [[JoinModel alloc] initWithDic:obj];
                    [mut addObject:model];
                }
                self.joinList = mut;
            }
        }
        if (dic[@"comment_list"]) {
            NSArray *list = dic[@"comment_list"];
            if (list.count>0) {
                NSMutableArray *mut = [NSMutableArray array];
                for (id obj in list) {
                    CoachDetailCommentModel *model = [[CoachDetailCommentModel alloc] initWithDic:obj];
                    [mut addObject:model];
                }
                self.commentList = mut;
            }
        }
    }
    return self;
}

@end
