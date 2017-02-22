//
//  TeachingOrderDetailModel.m
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderDetailModel.h"

@implementation Reservation

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"reservation_id"]) {
            self.reservationId = [dic[@"reservation_id"] intValue];
        }
        if (dic[@"reservation_time"]) {
            self.reservationTime = dic[@"reservation_time"];
        }
        if (dic[@"reservation_status"]) {
            self.reservationStatus = [dic[@"reservation_status"] intValue];
        }
        if (dic[@"comment_status"]) {
            self.commentStatus = [dic[@"comment_status"] intValue];
        }
        
    }
    return self;
}

@end

@implementation TeachingOrderDetailModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super initWithDic:data];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"class_hour"]) {
            self.classHour = [dic[@"class_hour"] intValue];
        }
        if (dic[@"give_yunbi"]) {
            self.giveYunbi = [dic[@"give_yunbi"] intValue] /100;
        }
        if (dic[@"remain_hour"]) {
            self.remainHour = [dic[@"remain_hour"] intValue];
        }
        if (dic[@"class_id"]) {
            self.classId = [dic[@"class_id"] intValue];
        }
        if (dic[@"public_class_id"]) {
            self.publicClassId = [dic[@"public_class_id"] intValue];
        }
        if (dic[@"teaching_site"]) {
            self.teachingSite = dic[@"teaching_site"];
        }
        if (dic[@"distance"]) {
            self.distance = [dic[@"distance"] floatValue];
        }
        if (dic[@"address"]) {
            self.address = dic[@"address"];
        }
        if (dic[@"teaching_date"]) {
            self.teachingDate = dic[@"teaching_date"];
        }
        if (dic[@"teaching_time"]) {
            self.teachingTime = dic[@"teaching_time"];
        }
        if (dic[@"longitude"]) {
            self.longitude = [dic[@"longitude"] doubleValue];
        }
        if (dic[@"latitude"]) {
            self.latitude = [dic[@"latitude"] doubleValue];
        }
        if (dic[@"reservation_list"]) {
            NSArray *arr = dic[@"reservation_list"];
            if (arr.count > 0) {
                NSMutableArray *aa = [NSMutableArray array];
                for (id obj in arr) {
                    Reservation *re = [[Reservation alloc] initWithDic:obj];
                    [aa addObject:re];
                }
                self.reservationList = aa;
            }
        }
    }
    return self;
}

@end
