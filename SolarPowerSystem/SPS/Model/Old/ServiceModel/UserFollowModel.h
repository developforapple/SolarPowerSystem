//
//  UserFollowModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserFollowModel : NSObject

@property (nonatomic) int memberId;
@property (nonatomic) int handicap;
@property (nonatomic) int gender;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic) int memberLevel;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic) int isFollowed;
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *followTime;
@property (nonatomic, strong) NSString *originalName;//lyf 加
@property (strong, nonatomic) NSString *mobilePhone;//lyf 加

@property (nonatomic) int possibleType; // //潜在类型 1：二度人脉 2：附近的人 3：热门用户
@property (nonatomic) int sameFriendNum; //共同好友数，当possible_type=1时有意义

- (id)initWithDic:(id)data;

@end
