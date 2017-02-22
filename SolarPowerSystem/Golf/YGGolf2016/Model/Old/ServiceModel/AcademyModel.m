//
//  AcademyModel.m
//  Golf
//
//  Created by 黄希望 on 14-3-3.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "AcademyModel.h"

@implementation AcademyModel


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"academy_id"]) {
        self.academyId = [[dic objectForKey:@"academy_id"] intValue];
    }
    if ([dic objectForKey:@"coach_count"]) {
        self.coachCount = [[dic objectForKey:@"coach_count"] intValue];
    }
    if ([dic objectForKey:@"academy_name"]) {
        self.academyName = [dic objectForKey:@"academy_name"];
    }
    if ([dic objectForKey:@"address"]) {
        self.address = [dic objectForKey:@"address"];
    }
    if (dic[@"short_address"]) {
        self.shortAddress = dic[@"short_address"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"photo_image"]) {
        self.photoImage = [dic objectForKey:@"photo_image"] ;
    }
    if ([dic objectForKey:@"signature"]) {
        self.signature = [dic objectForKey:@"signature"] ;
    }
    if ([dic objectForKey:@"introduction"]) {
        self.introduction = [dic objectForKey:@"introduction"];
    }
    if ([dic objectForKey:@"link_phone"]) {
        self.linkPhone = [dic objectForKey:@"link_phone"] ;
    }
    if ([dic objectForKey:@"album"]) {
        self.albumList = [dic objectForKey:@"album"] ;
    }
    if ([dic objectForKey:@"distance"]) {
        self.distance = [[dic objectForKey:@"distance"] floatValue];
    }
    if ([dic objectForKey:@"longitude"]) {
        self.longitude = [[dic objectForKey:@"longitude"] floatValue];
    }
    if ([dic objectForKey:@"latitude"]) {
        self.latitude = [[dic objectForKey:@"latitude"] floatValue];
    }
    if ([dic objectForKey:@"teaching_site"]) {
        self.teachingSite = [dic objectForKey:@"teaching_site"];
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
    self.virtualCourseFlag = [dic[@"virtual_course_flag"] boolValue];
    
    return self;
}

@end
