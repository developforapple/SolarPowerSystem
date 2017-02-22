//
//  UserFollowModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "UserFollowModel.h"

@implementation UserFollowModel

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
    if ([dic objectForKey:@"display_name"]) {
        self.displayName = [dic objectForKey:@"display_name"];
        self.originalName = _displayName;
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"member_rank"]) {
        self.memberLevel = [[dic objectForKey:@"member_rank"] intValue];
    }
    if ([dic objectForKey:@"gender"]) {
        self.gender = [[dic objectForKey:@"gender"] intValue];
    }
    if ([dic objectForKey:@"handicap"]) {
        self.handicap = [[dic objectForKey:@"handicap"] intValue];
    }
    if ([dic objectForKey:@"birthday"]) {
        self.birthday = [dic objectForKey:@"birthday"];
    }
    if ([dic objectForKey:@"is_followed"]) {
        self.isFollowed = [[dic objectForKey:@"is_followed"] intValue];
    }
    if ([dic objectForKey:@"location"]) {
        self.location = [dic objectForKey:@"location"];
    }
    if ([dic objectForKey:@"possible_type"]) {
        self.possibleType = [[dic objectForKey:@"possible_type"] intValue];
    }
    if ([dic objectForKey:@"same_friend_num"]) {
        self.sameFriendNum = [[dic objectForKey:@"same_friend_num"] intValue];
    }
    if ([dic objectForKey:@"follow_time"]) {
        self.followTime = [dic objectForKey:@"follow_time"];
    }
    if (dic[@"mobile_phone"]) {
        self.mobilePhone = dic[@"mobile_phone"];
    }
    return self;
}

//-(instancetype)initWithCoder:(NSCoder *)aDecoder{//lyf 加 用于存储球友 //lyf 屏蔽
//    if (self = [super init])
//    {
//        self.memberId = [[aDecoder decodeObjectForKey:@"member_id"] intValue];
//        self.displayName = [aDecoder decodeObjectForKey:@"display_name"];
//        self.mobilePhone = [aDecoder decodeObjectForKey:@"mobile_phone"];
//        self.gender = [[aDecoder decodeObjectForKey:@"gender"] intValue];
//        self.headImage = [aDecoder decodeObjectForKey:@"head_image"];
//    }
//    return self;
//}
//
//-(void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:@(_memberId) forKey:@"member_id"];
//    [aCoder encodeObject:_displayName forKey:@"display_name"];
//    [aCoder encodeObject:_mobilePhone forKey:@"mobile_phone"];
//    [aCoder encodeObject:@(_gender) forKey:@"gender"];
//    [aCoder encodeObject:_headImage forKey:@"head_image"];
//}
@end
