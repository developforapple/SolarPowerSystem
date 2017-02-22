//
//  UserDetailModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "UserDetailModel.h"

@implementation UserDetailModel


- (id)initWithDic:(id)data{
    self  = [super initWithDic:data];
    if(self) {
        NSDictionary *dic = (NSDictionary *)data;
        if ([dic objectForKey:@"is_followed"]) {
            self.isFollowed = [[dic objectForKey:@"is_followed"] intValue];
        }
        
        if ([dic objectForKey:@"image_list"]) {
            self.imageList = [dic objectForKey:@"image_list"];
        }
        if ([dic objectForKey:@"coach_level"]) {
            self.coachLevel = [dic[@"coach_level"] floatValue];
        }else{
            self.coachLevel = -2;
        }
        
        if (dic[@"seniority"]) {
            self.seniority = [dic[@"seniority"] intValue];
        }
        if (dic[@"followed_count"]) {
            self.followedCount = [dic[@"followed_count"] intValue];
        }
        if (dic[@"following_count"]) {
            self.followingCount = [dic[@"following_count"] intValue];
        }
        if (dic[@"academy_id"]) {
            self.academyId = [dic[@"academy_id"] intValue];
        }
        if (dic[@"academy_name"]) {
            self.academyName = dic[@"academy_name"];
        }
        if (dic[@"introduction"]) {
            self.introduction = dic[@"introduction"];
        }
        if (dic[@"career_achievement"]) {
            self.achievement = dic[@"career_achievement"];
        }
        if (dic[@"teaching_achievement"]) {
            self.teachHarvest = dic[@"teaching_achievement"];
        }
    }
    
    return self;
}

- (void)copyFromSession {
    if([LoginManager sharedManager].loginState) {
        self.displayName = [LoginManager sharedManager].session.displayName;
        self.nickName = [LoginManager sharedManager].session.nickName;
        self.headImage = [LoginManager sharedManager].session.headImage;
        self.gender = [LoginManager sharedManager].session.gender;
        self.birthday = [LoginManager sharedManager].session.birthday;
        self.signature = [LoginManager sharedManager].session.signature;
        self.handicap = [LoginManager sharedManager].session.handicap;
        self.personalTag = [LoginManager sharedManager].session.personalTag;
        self.location = [LoginManager sharedManager].session.location;
        self.latitude = [LoginManager sharedManager].session.latitude;
        self.longitude = [LoginManager sharedManager].session.longitude;
        self.loginTime = [LoginManager sharedManager].session.loginTime;
        self.memberLevel = [LoginManager sharedManager].session.memberLevel;        
    }
}

@end
