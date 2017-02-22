//
//  TeachingCoachModel.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingCoachModel.h"
#import "TeachProductDetail.h"
#import "CoachDetailCommentModel.h"
#import "PublicCourseModel.h"
#import "MemberClassModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation TeachingCoachModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"coach_id"]) {
        self.coachId = [[dic objectForKey:@"coach_id"] intValue];
    }
    if ([dic objectForKey:@"display_name"]) {
        self.displayName = [dic objectForKey:@"display_name"];
    }
    if ([dic objectForKey:@"nick_name"]) {
        self.nickName = [dic objectForKey:@"nick_name"];
    }
    // 用户名称备注
    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.coachId];
    if ([remarkName isNotBlank]) {
        self.nickName = remarkName;
    }
    
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"coach_level"]) {
        self.coachLevel = [[dic objectForKey:@"coach_level"] intValue];
    }
    if ([dic objectForKey:@"star_level"]) {
        self.starLevel = [[dic objectForKey:@"star_level"] floatValue];
    }
    if ([dic objectForKey:@"teaching_count"]) {
        self.teachingCount = [[dic objectForKey:@"teaching_count"] intValue];
    }

    if ([dic objectForKey:@"class_fee"]) {
        self.classFee = [[dic objectForKey:@"class_fee"] intValue] / 100;
    }
    if ([dic objectForKey:@"distance"]) {
        self.distance = [[dic objectForKey:@"distance"] floatValue];
    }
    if ([dic objectForKey:@"teaching_site"]) {
        self.teachingSite = [dic objectForKey:@"teaching_site"];
    }
    if (dic[@"address"]) {
        self.address = dic[@"address"];
    }
    if (dic[@"academy_id"]) {
        self.academyId = [dic[@"academy_id"] intValue];
    }
    if (dic[@"seniority"]){
        self.seniority = [dic[@"seniority"] intValue];
    }
    if (dic[@"introduction"]) {
        self.introduction = dic[@"introduction"];
    }
    if (dic[@"career_achievement"]) {
        self.careerAchievement = dic[@"career_achievement"];
    }
    if (dic[@"teaching_achievement"]) {
        self.teachingAchievement = dic[@"teaching_achievement"];
    }
    if (dic[@"comment_count"]) {
        self.commentCount = [dic[@"comment_count"] intValue];
    }
    if (dic[@"academy_name"]) {
        self.academyName = dic[@"academy_name"];
    }
    if (dic[@"longitude"]) {
        self.longitude = [dic[@"longitude"] doubleValue];
    }
    if (dic[@"latitude"]) {
        self.latitude = [dic[@"latitude"] doubleValue];
    }
    if (dic[@"is_followed"]) {
//        self.followed = (f == 1 || f == 4)? YES:NO;
        self.isFollowed = [dic[@"is_followed"] intValue];
    }
    if (dic[@"short_address"]) {
        self.shortAddress = dic[@"short_address"];
    }
    
    
    if (dic[@"class_list"]) {
        NSArray *arr = [dic objectForKey:@"class_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                MemberClassModel *m = [[MemberClassModel alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.classList = list;
        }
    }
    
    if (dic[@"product_list"]) {
        NSArray *arr = [dic objectForKey:@"product_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                TeachProductDetail *m = [[TeachProductDetail alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.productList = list;
        }
    }
    if (dic[@"comment_list"]) {
        NSArray *arr = [dic objectForKey:@"comment_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                CoachDetailCommentModel *m = [[CoachDetailCommentModel alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.commentList = list;
        }
    }
    if (dic[@"public_class_list"]) {
        NSArray *arr = [dic objectForKey:@"public_class_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                PublicCourseModel *m = [[PublicCourseModel alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.publicClassList = list;
        }
    }
    
    return self;
}

-(void)setIsFollowed:(int)f{
    self.followed = (f == 1  || f == 4)? YES:NO;
    _isFollowed = f;
}

@end
