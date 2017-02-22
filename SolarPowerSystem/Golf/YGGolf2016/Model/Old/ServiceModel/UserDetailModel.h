//
//  UserDetailModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface UserDetailModel : UserInfoModel

@property (nonatomic) int isFollowed;
@property (nonatomic) int noDisturb;
@property (nonatomic) int memberFollow;
@property (nonatomic) int memberMessage;
@property (nonatomic) int topicPraise;
@property (nonatomic) int topicComment;
@property (nonatomic) float coachLevel;

@property (nonatomic) int seniority;
@property (nonatomic) int academyId;
@property (nonatomic,strong) NSString *academyName;
@property (nonatomic,strong) NSString *introduction;
@property (nonatomic,strong) NSString *achievement;
@property (nonatomic,strong) NSString *teachHarvest;

@property (nonatomic,strong) NSArray *imageList;

@property (nonatomic) int followedCount;//被关注数
@property (nonatomic) int followingCount;//关注数

- (id)initWithDic:(id)data;
- (void)copyFromSession;

@end

