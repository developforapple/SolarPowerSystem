//
//  UserInfoModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-27.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject<NSCoding>

@property (nonatomic) int memberId;
@property (nonatomic,copy) NSString *displayName;
@property(nonatomic,copy) NSString *memberName;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic) int gender;
@property (nonatomic) int memberLevel;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *photeImage;
@property (nonatomic,copy) NSString *location;
@property (nonatomic) int handicap;
@property (nonatomic,copy) NSString *signature;
@property (nonatomic,copy) NSString *personalTag;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic,copy) NSString *loginTime;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

- (id)initWithDic:(id)data;

@end
