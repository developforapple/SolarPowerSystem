//
//  CoachDetailModel.m
//  Golf
//
//  Created by 黄希望 on 14-2-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "CoachDetailModel.h"

@implementation CoachDetailModel
@synthesize headImage;
@synthesize photoImage;
@synthesize academyName;
@synthesize signaure;
@synthesize bestGrade;
@synthesize oftenGoPlace;
@synthesize careerAchievement;
@synthesize teachingAchievement;
@synthesize teachingSpecialty;
@synthesize introduction;
@synthesize praised;
@synthesize memberId;
@synthesize msgCount;
@synthesize phoneNum;
@synthesize albumList;
@synthesize academyId;
@synthesize linkPhone;
@synthesize headImageData;
@synthesize photoImageData;
@synthesize birthday;
@synthesize headSaveImage;
@synthesize photoSaveImage;
@synthesize commodityList;


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
    if ([dic objectForKey:@"academy_id"]) {
        self.academyId = [[dic objectForKey:@"academy_id"] intValue];
    }
    if ([dic objectForKey:@"coach_name"]) {
        self.coachName = [dic objectForKey:@"coach_name"];
    }
    if ([dic objectForKey:@"gender"]) {
        self.gender = [[dic objectForKey:@"gender"] intValue];
    }
    if ([dic objectForKey:@"age"]) {
        self.age = [[dic objectForKey:@"age"] intValue];
    }
    if ([dic objectForKey:@"praise_count"]) {
        self.praiseCount = [[dic objectForKey:@"praise_count"] intValue];
    }
    if ([dic objectForKey:@"coach_level"]) {
        self.coachLevel = [[dic objectForKey:@"coach_level"] intValue]-1;
    }
    if ([dic objectForKey:@"seniority"]) {
        self.seniority = [[dic objectForKey:@"seniority"] intValue];
    }
    if ([dic objectForKey:@"member_id"]) {
        self.memberId = [[dic objectForKey:@"member_id"] intValue];
    }
    if ([dic objectForKey:@"msg_count"]) {
        self.msgCount = [[dic objectForKey:@"msg_count"] intValue];
    }
    if ([dic objectForKey:@"class_fee"]) {
        self.classFee = [[dic objectForKey:@"class_fee"] intValue];
    }
    if ([dic objectForKey:@"semester_fee"]) {
        self.semesterFee = [[dic objectForKey:@"semester_fee"] intValue];
    }
    if ([dic objectForKey:@"semester_duration"]) {
        self.semesterDuration = [[dic objectForKey:@"semester_duration"] intValue];
    }
    if ([dic objectForKey:@"current_status"]) {
        self.currentStatus = [[dic objectForKey:@"current_status"] intValue];
    }
    if ([dic objectForKey:@"distance"]) {
        self.distance = [[dic objectForKey:@"distance"] floatValue];
    }
    if ([dic objectForKey:@"checkin_description"]) {
        self.checkinDescription = [dic objectForKey:@"checkin_description"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"photo_image"]) {
        self.photoImage = [dic objectForKey:@"photo_image"];
    }
    if ([dic objectForKey:@"academy_name"]) {
        self.academyName = [dic objectForKey:@"academy_name"];
    }
    if ([dic objectForKey:@"signature"]) {
        self.signaure = [dic objectForKey:@"signature"];
    }
    if ([dic objectForKey:@"best_grade"]) {
        self.bestGrade = [[dic objectForKey:@"best_grade"] intValue];
    }
    if ([dic objectForKey:@"often_go_place"]) {
        self.oftenGoPlace = [dic objectForKey:@"often_go_place"];
    }
    if ([dic objectForKey:@"career_achievement"]) {
        self.careerAchievement = [dic objectForKey:@"career_achievement"];
    }
    if ([dic objectForKey:@"teaching_achievement"]) {
        self.teachingAchievement = [dic objectForKey:@"teaching_achievement"];
    }
    if ([dic objectForKey:@"teaching_specialty"]) {
        self.teachingSpecialty = [dic objectForKey:@"teaching_specialty"];
    }
    if ([dic objectForKey:@"introduction"]) {
        self.introduction = [dic objectForKey:@"introduction"];
    }
    if ([dic objectForKey:@"phone_num"]) {
        self.phoneNum = [dic objectForKey:@"phone_num"];
    }
    if ([dic objectForKey:@"praised"]) {
        self.praised = [[dic objectForKey:@"praised"] boolValue];
    }
    if ([dic objectForKey:@"birthday"]) {
        self.birthday = [dic objectForKey:@"birthday"];
    }
    if ([dic objectForKey:@"album"]) {
        self.albumList = [dic objectForKey:@"album"];
    }
    if ([dic objectForKey:@"commodity_list"]) {
        NSArray *array = [dic objectForKey:@"commodity_list"];
        if (array && array.count>0) {
            NSMutableArray *mutArray = [NSMutableArray array];
            for (id obj in array) {
                CommodityInfoModel *m = [[CommodityInfoModel alloc] initWithDic:obj];
                [mutArray addObject:m];
            }
            self.commodityList = mutArray;
        }
    }
    return self;
}

@end
