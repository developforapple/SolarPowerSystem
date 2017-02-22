//
//  UserSessionModel.h
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"
#import "Utilities.h"

@interface UserSessionModel : NSObject<NSCoding>

@property(nonatomic,copy) NSString *sessionId;
@property(nonatomic,copy) NSString *extraInfo;

@property(nonatomic) int coachId; //教练ID，0：不是教练(兼容旧版本)
@property(nonatomic) BOOL noDeposit;

@property (nonatomic) int memberId;
@property (nonatomic,copy) NSString *displayName;
@property(nonatomic,copy) NSString *memberName;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic) int gender;
@property (nonatomic) int memberLevel;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,strong) UIImage *imageHead;
@property (nonatomic,copy) NSString *photeImage;
@property (nonatomic,copy) NSString *location;
@property (nonatomic) int handicap;
@property (nonatomic,copy) NSString *signature;
@property (nonatomic,copy) NSString *personalTag;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic,copy) NSString *loginTime;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) int timPort;
@property (nonatomic,copy) NSString *timAddr;



- (id)initWithDic:(id)data;

@end
