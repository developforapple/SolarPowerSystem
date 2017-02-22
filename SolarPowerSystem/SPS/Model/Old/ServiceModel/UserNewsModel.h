//
//  UserNewsModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-16.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNewsModel : NSObject<NSCopying,NSCoding>

@property (nonatomic) int memberId;
@property (nonatomic) int toMemberId;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic) int memberLevel;
@property (nonatomic) int handicap;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic) int gender;
@property (nonatomic) int msgId;
@property (nonatomic) int msgType;
@property (nonatomic,copy) NSString *msgTime;
@property (nonatomic,copy) NSString *msgContent;
@property (nonatomic) int newCount;


- (id)initWithDic:(id)data;


@end
