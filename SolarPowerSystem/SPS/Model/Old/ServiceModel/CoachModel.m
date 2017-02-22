//
//  CoachModel.m
//  Golf
//
//  Created by 黄希望 on 14-2-19.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "CoachModel.h"

@implementation CoachModel

@synthesize coachId;
@synthesize coachName;
@synthesize headImage;
@synthesize photoImage;
@synthesize gender;
@synthesize age;
@synthesize praiseCount;
@synthesize coachLevel;
@synthesize seniority;
@synthesize classFee;
@synthesize semesterFee;
@synthesize semesterDuration;
@synthesize currentStatus;
@synthesize distance;
@synthesize checkinDescription;


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
    if ([dic objectForKey:@"coach_name"]) {
        self.coachName = [dic objectForKey:@"coach_name"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"photo_image"]) {
        self.photoImage = [dic objectForKey:@"photo_image"];
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
    return self;
}


@end
