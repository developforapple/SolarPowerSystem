//
//  ClubModel.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "ClubModel.h"

@implementation ClubModel


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"club_id"] > 0){
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if([dic objectForKey:@"city_id"] > 0){
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if([dic objectForKey:@"club_name"]) {
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if([dic objectForKey:@"short_name"]) {
        self.shortName = [dic objectForKey:@"short_name"];
    }
    if([dic objectForKey:@"club_image"]) {
        self.clubImage = [dic objectForKey:@"club_image"];
    }
    if([dic objectForKey:@"club_photo"]) {
        self.clubPhoto = [dic objectForKey:@"club_photo"];
    }
    if([dic objectForKey:@"longitude"]){
        self.longitude = [[dic objectForKey:@"longitude"] floatValue];
    }
    if([dic objectForKey:@"latitude"]){
        self.latitude = [[dic objectForKey:@"latitude"] floatValue];
    }
    if([dic objectForKey:@"remote"]){
        self.remote = [dic objectForKey:@"remote"];
    }
    if([dic objectForKey:@"introduction"]){
        self.introduction = [dic objectForKey:@"introduction"];
    }
    if([dic objectForKey:@"club_facility"]){
        self.clubFacility = [dic objectForKey:@"club_facility"];
    }
    if([dic objectForKey:@"publicnotice"]){
        self.publicNotice = [dic objectForKey:@"publicnotice"];
    }    
    if([dic objectForKey:@"address"]){
        self.address = [dic objectForKey:@"address"];
    }
    if([dic objectForKey:@"short_address"]){
        self.shortAddress = [dic objectForKey:@"short_address"];
    }
    if([dic objectForKey:@"tee_date"]){
        self.teeDate = [dic objectForKey:@"tee_date"];
    }
    if([dic objectForKey:@"min_price"]){
        self.minPrice = [[dic objectForKey:@"min_price"] intValue]/100;
    }
    if([dic objectForKey:@"min_time_price"]){
        self.minTimePrice = [[dic objectForKey:@"min_time_price"] intValue];
        if(self.minTimePrice>0) {
            self.minTimePrice = self.minTimePrice / 100;
        }
    }
    if([dic objectForKey:@"min_package_price"]){
        self.minPackagePrice = [[dic objectForKey:@"min_package_price"] intValue]/100;
    }
    if([dic objectForKey:@"phone"]){
        self.phone = [dic objectForKey:@"phone"];
    }
    if([dic objectForKey:@"traffic_guide"]){
        self.trafficGuide = [dic objectForKey:@"traffic_guide"];
    }
    if([dic objectForKey:@"build_date"]){
        self.buildDate = [dic objectForKey:@"build_date"];
    }
    if([dic objectForKey:@"designer"]){
        self.designer = [dic objectForKey:@"designer"];
    }
    if([dic objectForKey:@"course_kind"]){
        self.courseKind = [dic objectForKey:@"course_kind"];
    }
    if([dic objectForKey:@"course_data"]){
        self.courseData = [dic objectForKey:@"course_data"];
    }
    if([dic objectForKey:@"fairway_length"]){
        self.fairwayLength = [dic objectForKey:@"fairway_length"];
    }
    if([dic objectForKey:@"fairway_grass_seed"]){
        self.fairwayGrass = [dic objectForKey:@"fairway_grass_seed"];
    }
    if([dic objectForKey:@"fairway_intro"]){
        self.fairwayIntro = [dic objectForKey:@"fairway_intro"];
    }
    if([dic objectForKey:@"green_grass_seed"]){
        self.greenGrass = [dic objectForKey:@"green_grass_seed"];
    }
    if([dic objectForKey:@"course_area"]){
        self.courseArea = [dic objectForKey:@"course_area"];
    }
    if([dic objectForKey:@"is_official"] > 0){
        self.isOfficial = [[dic objectForKey:@"is_official"] intValue];
    }
    if([dic objectForKey:@"closure"]){
        self.closure = [[dic objectForKey:@"closure"] intValue];
    }
    if ([dic objectForKey:@"pay_type"]) {
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
    }
    if ([dic objectForKey:@"city_name"]) {
        self.cityName = [dic objectForKey:@"city_name"];
    }
    if([dic objectForKey:@"time_min_price"]){
        if ([[dic objectForKey:@"time_min_price"] intValue] == -1) {
            self.timeMinPrice = [[dic objectForKey:@"time_min_price"] intValue];
        }
        else{
            self.timeMinPrice = [[dic objectForKey:@"time_min_price"] intValue]/100;
        }
    }
    if ([dic objectForKey:@"time_end_time"]) {
        self.endTime = [dic objectForKey:@"time_end_time"];
    }
    if ([dic objectForKey:@"time_start_time"]) {
        self.startTime = [dic objectForKey:@"time_start_time"];
    }
    
    if([dic objectForKey:@"comment_count"]){
        self.commentCount = [[dic objectForKey:@"comment_count"] intValue];
    }
    if([dic objectForKey:@"total_level"]){
        self.totalLevel = ceil([[dic objectForKey:@"total_level"] floatValue]*100.0/5.0);
    }
    if([dic objectForKey:@"grass_level"]){
        self.grassLevel = ceil([[dic objectForKey:@"grass_level"] floatValue]*100.0/5.0);
    }
    if([dic objectForKey:@"service_level"]){
        self.serviceLevel = ceil([[dic objectForKey:@"service_level"] floatValue]*100.0/5.0);
    }
    if([dic objectForKey:@"difficulty_level"]){
        self.difficultyLevel = ceil([[dic objectForKey:@"difficulty_level"] floatValue]*100.0/5.0);
    }
    if([dic objectForKey:@"scenery_level"]){
        self.sceneryLevel = ceil([[dic objectForKey:@"scenery_level"] floatValue]*100.0/5.0);
    }
    if([dic objectForKey:@"course_type"]){
        self.clubHoleNum = [[dic objectForKey:@"course_type"] intValue];
    }
    if([dic objectForKey:@"give_yunbi"]){
        self.giveYunbi = [[dic objectForKey:@"give_yunbi"] intValue]/100;
    }
    if ([dic objectForKey:@"club_manager"]) {
        self.clubManagerData = [dic objectForKey:@"club_manager"];
    }
    if ([dic objectForKey:@"topic_count"]) {
        self.topicCount = [[dic objectForKey:@"topic_count"] intValue];
    }
    if ([dic objectForKey:@"topic_list"]) {
        NSArray *list = [dic objectForKey:@"topic_list"];
        if (list.count>0) {
            self.topicData = [[TopicModel alloc] initWithDic:list[0]];
        }
    }
    return self;
}

+ (NSArray*) initWithArray: (id) data{
    if (!data || ![data isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSArray* array = (NSArray*) data;
    NSMutableArray* resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary* record in array) {
        ClubModel* model = [[ClubModel alloc] initWithDic:record];
        [resultArray addObject:model];
    }
    return resultArray;
}

@end
