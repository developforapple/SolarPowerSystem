//
//  UserInfoModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-27.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "UserInfoModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation UserInfoModel

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init])
    {
        self.memberId = [[aDecoder decodeObjectForKey:@"member_id"] intValue];
        self.displayName = [aDecoder decodeObjectForKey:@"display_name"];
        self.memberName = [aDecoder decodeObjectForKey:@"member_name"];
        self.nickName = [aDecoder decodeObjectForKey:@"nick_name"];
        self.mobilePhone = [aDecoder decodeObjectForKey:@"mobile_phone"];
        self.gender = [[aDecoder decodeObjectForKey:@"gender"] intValue];
        self.memberLevel = [[aDecoder decodeObjectForKey:@"member_level"] intValue];
        self.headImage = [aDecoder decodeObjectForKey:@"head_image"];
        self.photeImage = [aDecoder decodeObjectForKey:@"photo_image"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.handicap = [[aDecoder decodeObjectForKey:@"handicap"] intValue];
        self.signature = [aDecoder decodeObjectForKey:@"signature"];
        self.personalTag = [aDecoder decodeObjectForKey:@"personal_tag"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.loginTime = [aDecoder decodeObjectForKey:@"login_time"];
        self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
        self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(_memberId) forKey:@"member_id"];
    [aCoder encodeObject:_displayName forKey:@"display_name"];
    [aCoder encodeObject:_memberName forKey:@"member_name"];
    [aCoder encodeObject:_nickName forKey:@"nick_name"];
    [aCoder encodeObject:_mobilePhone forKey:@"mobile_phone"];
    [aCoder encodeObject:@(_gender) forKey:@"gender"];
    [aCoder encodeObject:@(_memberLevel) forKey:@"member_level"];
    [aCoder encodeObject:_headImage forKey:@"head_image"];
    [aCoder encodeObject:_photeImage forKey:@"photo_image"];
    [aCoder encodeObject:_location forKey:@"location"];
    [aCoder encodeObject:@(_handicap) forKey:@"handicap"];
    [aCoder encodeObject:_personalTag forKey:@"personal_tag"];
    [aCoder encodeObject:_birthday forKey:@"birthday"];
    [aCoder encodeObject:_loginTime forKey:@"login_time"];
    [aCoder encodeObject:@(_longitude) forKey:@"longitude"];
    [aCoder encodeObject:@(_latitude) forKey:@"latitude"];
}

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if(self) {
        
        NSDictionary *dic = (NSDictionary *)data;
        if ([dic objectForKey:@"member_id"]) {
            self.memberId = [[dic objectForKey:@"member_id"] intValue];
        }
        if ([dic objectForKey:@"display_name"]) {
            self.displayName = [dic objectForKey:@"display_name"];
            NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.memberId];
            if ([remarkName isNotBlank]) {
                self.displayName = remarkName;
            }
        }
        if([dic objectForKey:@"member_name"]) {
            self.memberName = [dic objectForKey:@"member_name"];
        }
        if ([dic objectForKey:@"nick_name"]) {
            self.nickName = [dic objectForKey:@"nick_name"];
        }
        if ([dic objectForKey:@"mobile_phone"]) {
            self.mobilePhone = [dic objectForKey:@"mobile_phone"];
        }
        if ([dic objectForKey:@"gender"]) {
            self.gender = [[dic objectForKey:@"gender"] intValue];
        }
        if ([dic objectForKey:@"member_rank"]) {
            self.memberLevel = [[dic objectForKey:@"member_rank"] intValue];
        }
        if ([dic objectForKey:@"head_image"]) {
            self.headImage = [dic objectForKey:@"head_image"];
        }
        if ([dic objectForKey:@"photo_image"]) {
            self.photeImage = [dic objectForKey:@"photo_image"];
        }
        if ([dic objectForKey:@"location"]) {
            self.location = [dic objectForKey:@"location"];
        }
        if ([dic objectForKey:@"handicap"]) {
            self.handicap = [[dic objectForKey:@"handicap"] intValue];
        }
        if ([dic objectForKey:@"signature"]) {
            self.signature = [dic objectForKey:@"signature"];
        }
        if ([dic objectForKey:@"personal_tag"]) {
            self.personalTag = [dic objectForKey:@"personal_tag"];
        }
        if ([dic objectForKey:@"birthday"]) {
            self.birthday = [dic objectForKey:@"birthday"];
        }
        if ([dic objectForKey:@"login_time"]) {
            self.loginTime = [dic objectForKey:@"login_time"];
        }
        if ([dic objectForKey:@"longitude"]) {
            self.longitude = [[dic objectForKey:@"longitude"] doubleValue];
        }
        if ([dic objectForKey:@"latitude"]) {
            self.latitude = [[dic objectForKey:@"latitude"] doubleValue];
        }
    }
    
    return self;
}

@end
