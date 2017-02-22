//
//  SearchCityModel.m
//  Golf
//
//  Created by Dejohn Dong on 12-1-30.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "SearchCityModel.h"

@implementation SearchCityModel
@synthesize cityId;
@synthesize provinceId;
@synthesize cityName;
@synthesize isHotCity;
@synthesize firstLetter;
@synthesize pinYin;
@synthesize simplePin;
@synthesize longitude;
@synthesize latitude;
@synthesize supportCoach;
@synthesize tempCityName;
@synthesize supportPackage;
@synthesize clubCount;

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super init]) {
        cityId = [aDecoder decodeIntForKey:@"cityId"];
        provinceId = [aDecoder decodeIntForKey:@"provinceId"];
        cityName = [aDecoder decodeObjectForKey:@"cityName"];
        firstLetter = [aDecoder decodeObjectForKey:@"firstLetter"];
        isHotCity = [aDecoder decodeBoolForKey:@"isHotCity"];
        simplePin = [aDecoder decodeObjectForKey:@"simplePin"];
        pinYin = [aDecoder decodeObjectForKey:@"pinYin"];
        longitude = [aDecoder decodeFloatForKey:@"longitude"];
        latitude = [aDecoder decodeFloatForKey:@"latitude"];
        supportCoach = [aDecoder decodeIntForKey:@"supportCoach"];
        supportPackage = [aDecoder decodeIntForKey:@"supportPackage"];
        tempCityName = [aDecoder decodeObjectForKey:@"tempCityName"];
        clubCount = [aDecoder decodeIntForKey:@"club_count"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:cityId forKey:@"cityId"];
    [aCoder encodeInt:provinceId forKey:@"provinceId"];
    [aCoder encodeObject:cityName forKey:@"cityName"];
    [aCoder encodeObject:firstLetter forKey:@"firstLetter"];
    [aCoder encodeBool:isHotCity forKey:@"isHotCity"];
    [aCoder encodeObject:simplePin forKey:@"simplePin"];
    [aCoder encodeObject:pinYin forKey:@"pinYin"];
    [aCoder encodeFloat:longitude forKey:@"longitude"];
    [aCoder encodeFloat:latitude forKey:@"latitude"];
    [aCoder encodeInt:supportCoach forKey:@"supportCoach"];
    [aCoder encodeInt:supportPackage forKey:@"supportPackage"];
    [aCoder encodeObject:tempCityName forKey:@"tempCityName"];
    [aCoder encodeInt:clubCount forKey:@"club_count"];
}

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary* dic = (NSDictionary*) data;
    if([dic objectForKey:@"city_id"]){
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if([dic objectForKey:@"province_id"]){
        self.provinceId = [[dic objectForKey:@"province_id"] intValue];
    }
    if([dic objectForKey:@"city_name"]){
        self.cityName = [dic objectForKey:@"city_name"];
    }
    if([dic objectForKey:@"is_hot_city"]){
        self.isHotCity = [[dic objectForKey:@"is_hot_city"] boolValue];
    }
    if([dic objectForKey:@"first_letter"]){
        self.firstLetter = [dic objectForKey:@"first_letter"];
    }
    if([dic objectForKey:@"simple_pin"]){
        self.simplePin = [dic objectForKey:@"simple_pin"];
    }
    if([dic objectForKey:@"pinyin"]){
        self.pinYin = [dic objectForKey:@"pinyin"];
    }
    if([dic objectForKey:@"longitude"]){
        self.longitude = [[dic objectForKey:@"longitude"] floatValue];
    }
    if([dic objectForKey:@"latitude"]){
        self.latitude = [[dic objectForKey:@"latitude"] floatValue];
    }
    if ([dic objectForKey:@"support_coach"]) {
        self.supportCoach = [[dic objectForKey:@"support_coach"] floatValue];
    }
    if ([dic objectForKey:@"support_package"]) {
        self.supportPackage = [[dic objectForKey:@"support_package"] floatValue];
    }
    if ([dic objectForKey:@"club_count"]) {
        self.clubCount = [[dic objectForKey:@"club_count"] intValue];
    }
    return self;
}

+ (SearchCityModel *)getCityModelWithCityId:(int)cityId{
    
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    
    if (localArray) {
        for (id obj in localArray) {
            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
            if (model.cityId == cityId) {
                return model;
            }
        }
    }
    return nil;
}

@end
