//
//  UserNewsModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-16.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "UserNewsModel.h"

@implementation UserNewsModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"member_id"]) {
        self.memberId = [[dic objectForKey:@"member_id"] intValue];
    }
    if ([dic objectForKey:@"to_member_id"]) {
        self.toMemberId = [[dic objectForKey:@"to_member_id"] intValue];
    }
    if ([dic objectForKey:@"msg_id"]) {
        self.msgId = [[dic objectForKey:@"msg_id"] intValue];
    }
    if ([dic objectForKey:@"msg_type"]) {
        self.msgType = [[dic objectForKey:@"msg_type"] intValue];
    }
    if ([dic objectForKey:@"display_name"]) {
        self.displayName = [dic objectForKey:@"display_name"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"member_rank"]) {
        self.memberLevel = [[dic objectForKey:@"member_rank"] intValue];
    }
    if ([dic objectForKey:@"handicap"]) {
        self.handicap = [[dic objectForKey:@"handicap"] intValue];
    }
    if ([dic objectForKey:@"birthday"]) {
        self.birthday = [dic objectForKey:@"birthday"];
    }
    if ([dic objectForKey:@"gender"]) {
        self.gender = [[dic objectForKey:@"gender"] intValue];
    }
    if ([dic objectForKey:@"msg_time"]) {
        self.msgTime = [dic objectForKey:@"msg_time"];
    }
    if ([dic objectForKey:@"msg_content"]) {
        self.msgContent = [dic objectForKey:@"msg_content"];
    }
    if ([dic objectForKey:@"new_count"]) {
        self.newCount = [[dic objectForKey:@"new_count"] intValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.memberId = [aDecoder decodeIntForKey:@"member_id"];
        self.toMemberId = [aDecoder decodeIntForKey:@"to_member_id"];
        self.displayName = [aDecoder decodeObjectForKey:@"display_name"];
        self.headImage = [aDecoder decodeObjectForKey:@"head_image"];
        self.memberLevel = [aDecoder decodeIntForKey:@"member_rank"];
        self.handicap = [aDecoder decodeIntForKey:@"handicap"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.gender = [aDecoder decodeIntForKey:@"gender"];
        self.msgTime = [aDecoder decodeObjectForKey:@"msg_time"];
        self.msgContent = [aDecoder decodeObjectForKey:@"msg_content"];
        self.newCount = [aDecoder decodeIntForKey:@"new_count"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_memberId forKey:@"member_id"];
    [aCoder encodeInt:_toMemberId forKey:@"to_member_id"];
    [aCoder encodeObject:_displayName forKey:@"display_name"];
    [aCoder encodeObject:_headImage forKey:@"head_image"];
    [aCoder encodeInt:_memberLevel forKey:@"member_rank"];
    [aCoder encodeInt:_handicap forKey:@"handicap"];
    [aCoder encodeObject:_birthday forKey:@"birthday"];
    [aCoder encodeInt:_gender forKey:@"gender"];
    [aCoder encodeObject:_msgTime forKey:@"msg_time"];
    [aCoder encodeObject:_msgContent forKey:@"msg_content"];
    [aCoder encodeInt:_newCount forKey:@"new_count"];
}


- (id)copyWithZone:(NSZone *)zone {
    UserNewsModel *copy = [[[self class] allocWithZone:zone] init];
    copy.memberId = self.memberId;
    copy.toMemberId = self.toMemberId;
    copy.displayName = [self.displayName copyWithZone:zone];
    copy.headImage = [self.headImage copyWithZone:zone];
    copy.memberLevel = self.memberLevel;
    copy.handicap = self.handicap;
    copy.birthday = [self.birthday copyWithZone:zone];
    copy.gender = self.gender;
    copy.msgTime = [self.msgTime copyWithZone:zone];
    copy.msgContent = [self.msgContent copyWithZone:zone];
    copy.newCount = self.newCount;
    return copy;
}

@end
