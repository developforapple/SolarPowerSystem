//
//  CoachTimetable.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachTimetable.h"
#import "ReservationModel.h"

@implementation CoachTimetable


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"date"]){
        self.date = [dic objectForKey:@"date"];
    }
    if([dic objectForKey:@"class_count"]){
        self.classCount = [[dic objectForKey:@"class_count"] intValue];
    }
    if([dic objectForKey:@"time_list"]){
        self.timeList = [[NSMutableArray alloc] init];
        NSArray *list = [dic objectForKey:@"time_list"];
        for (NSDictionary *nd in list) {
            TimeList *list = [[TimeList alloc] initWithDic:nd];
            [self.timeList addObject:list];
        }
    }
    return self;
}

@end



@implementation TimeList

-(id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"time"]) {
        self.time = [dic objectForKey:@"time"];
    }
    if ([dic objectForKey:@"class_type"]) {
        self.classType = [[dic objectForKey:@"class_type"] intValue];
    }
    if ([dic objectForKey:@"person_count"]) {
        self.personCount = [[dic objectForKey:@"person_count"] intValue];
    }
    if ([dic objectForKey:@"public_class_id"]) {
        self.publicClassId = [[dic objectForKey:@"public_class_id"] intValue];
    }
    if ([dic objectForKey:@"reservation_list"]) {
        NSArray *list = [dic objectForKey:@"reservation_list"];
        self.reservationList = [NSMutableArray array];
        for (NSDictionary *nd in list) {
            ReservationModel *m = [[ReservationModel alloc] initWithDic:nd];
            [self.reservationList addObject:m];
        }
    }
    return self;
}

@end



