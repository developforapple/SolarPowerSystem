//
//  searchClubModel.m
//  Golf
//
//  Created by 黄希望 on 12-7-25.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "SearchClubModel.h"

@implementation SearchClubModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"club_id"]){
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if([dic objectForKey:@"club_name"]){
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if([dic objectForKey:@"province_id"]){
        self.provinceId = [[dic objectForKey:@"province_id"] intValue];
    }
    if([dic objectForKey:@"city_id"]){
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if ([dic objectForKey:@"club_image"]) {
        self.clubImage = [dic objectForKey:@"club_image"];
    }
    if ([dic objectForKey:@"address"]) {
        self.address = [dic objectForKey:@"address"];
    }
    if ([dic objectForKey:@"longitude"]) {
        self.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    }
    if ([dic objectForKey:@"latitude"]) {
        self.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    }
    return self;
}

- (id)initWithClubId:(int)clubId clubName:(NSString *)clubName{
    self = [super init];
    if(self) {
        self.clubId = clubId;
        self.clubName = clubName;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.clubId = [aDecoder decodeIntForKey:@"club_id"];
        self.clubName = [aDecoder decodeObjectForKey:@"club_name"];
        self.provinceId = [aDecoder decodeIntForKey:@"province_id"];
        self.cityId = [aDecoder decodeIntForKey:@"city_id"];
        self.clubImage = [aDecoder decodeObjectForKey:@"club_image"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        self.latitude = [aDecoder decodeDoubleForKey:@"latitude"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_clubId forKey:@"club_id"];
    [aCoder encodeObject:_clubName forKey:@"club_name"];
    [aCoder encodeInt:_provinceId forKey:@"province_id"];
    [aCoder encodeInt:_cityId forKey:@"city_id"];
    [aCoder encodeObject:_clubImage forKey:@"club_image"];
    [aCoder encodeObject:_address forKey:@"address"];
    [aCoder encodeDouble:_longitude forKey:@"longitude"];
    [aCoder encodeDouble:_latitude forKey:@"latitude"];
}

- (id)copyWithZone:(NSZone *)zone {
    SearchClubModel *copy = [[[self class] allocWithZone:zone] init];
    copy.clubName = [self.clubName copyWithZone:zone];
    copy.clubId = self.clubId;
    copy.provinceId = self.provinceId;
    copy.cityId = self.cityId;
    copy.clubImage = [self.clubImage copyWithZone:zone];
    copy.address = [self.address copyWithZone:zone];
    copy.longitude = self.longitude;
    copy.latitude = self.latitude;
    return copy;
}

@end
