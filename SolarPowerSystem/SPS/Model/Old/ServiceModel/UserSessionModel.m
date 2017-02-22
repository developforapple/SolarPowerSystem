//
//  UserSessionModel.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "UserSessionModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation UserSessionModel



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
        
        self.sessionId = [aDecoder decodeObjectForKey:@"session_id"];
        self.extraInfo = [aDecoder decodeObjectForKey:@"extra_info"];
        self.noDeposit = [[aDecoder decodeObjectForKey:@"no_deposit"] boolValue];
        self.coachId = [[aDecoder decodeObjectForKey:@"coach_id"] intValue];
        self.timPort = [[aDecoder decodeObjectForKey:@"timport"] intValue];
        self.timAddr = [aDecoder decodeObjectForKey:@"timaddr"];
    }
    return self;
}



- (void) encodeWithCoder: (NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.memberId) forKey:@"member_id"];
    [aCoder encodeObject:self.displayName forKey:@"display_name"];
    [aCoder encodeObject:self.memberName forKey:@"member_name"];
    [aCoder encodeObject:self.nickName forKey:@"nick_name"];
    [aCoder encodeObject:self.mobilePhone forKey:@"mobile_phone"];
    [aCoder encodeObject:@(self.gender) forKey:@"gender"];
    [aCoder encodeObject:@(self.memberLevel) forKey:@"member_level"];
    [aCoder encodeObject:self.headImage forKey:@"head_image"];
    [aCoder encodeObject:self.photeImage forKey:@"photo_image"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:@(self.handicap) forKey:@"handicap"];
    [aCoder encodeObject:self.personalTag forKey:@"personal_tag"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.loginTime forKey:@"login_time"];
    [aCoder encodeObject:@(self.longitude) forKey:@"longitude"];
    [aCoder encodeObject:@(self.latitude) forKey:@"latitude"];
    
    [aCoder encodeObject:_sessionId forKey:@"session_id"];
    [aCoder encodeObject:_extraInfo forKey:@"extra_info"];
    [aCoder encodeObject:@(_noDeposit) forKey:@"no_deposit"];
    [aCoder encodeObject:@(_coachId) forKey:@"coach_id"];
    [aCoder encodeObject:@(_timPort) forKey:@"timport"];
    [aCoder encodeObject:_timAddr forKey:@"timaddr"];
}


- (id)initWithDic:(id)data {
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if(self) {
        NSDictionary *dic = (NSDictionary *)data;
        if([dic objectForKey:@"session_id"]){
            self.sessionId = [dic objectForKey:@"session_id"];
        }
        if([dic objectForKey:@"extra_info"]) {
            self.extraInfo = [dic objectForKey:@"extra_info"];
        }
        if([dic objectForKey:@"no_deposit"]) {
            self.noDeposit = [[dic objectForKey:@"no_deposit"] boolValue];
        }
        if([dic objectForKey:@"coach_id"]){
            self.coachId = [[dic objectForKey:@"coach_id"] intValue];
        }
        
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
            self.gender = 2;
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
        if ([dic objectForKey:@"timport"]) {
            self.timPort = [[dic objectForKey:@"timport"] intValue];
        }
        if ([dic objectForKey:@"timaddr"]) {
            self.timAddr = [dic objectForKey:@"timaddr"];
        }
    }
    return self;
}

@end
