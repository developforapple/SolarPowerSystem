//
//  SimpleCityModel.m
//  Golf
//
//  Created by user on 13-2-28.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import "SimpleCityModel.h"

@implementation SimpleCityModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary* dic = (NSDictionary*) data;
    if([dic objectForKey:@"province_id"]){
        self.provinceId = [[dic objectForKey:@"province_id"] intValue];
    }
    if([dic objectForKey:@"city_id"]){
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if([dic objectForKey:@"name"]){
        self.name = [dic objectForKey:@"name"];
    }
    if([dic objectForKey:@"pinyin"]){
        self.pinYin = [dic objectForKey:@"pinyin"];
    }
    if([dic objectForKey:@"club_name"]){
        self.clubName = [dic objectForKey:@"club_name"];
    }
    return self;
}


@end
