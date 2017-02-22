//
//  CoachModel.h
//  Golf
//
//  Created by 黄希望 on 14-2-19.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachModel : NSObject

@property (nonatomic) int coachId;
@property (nonatomic,copy) NSString *coachName;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *photoImage;
@property (nonatomic) int gender;
@property (nonatomic) int age;
@property (nonatomic) int praiseCount;
@property (nonatomic) int coachLevel;
@property (nonatomic) int seniority;
@property (nonatomic) int classFee;
@property (nonatomic) int semesterFee;
@property (nonatomic) int semesterDuration;
@property (nonatomic) int currentStatus;
@property (nonatomic) float distance;
@property (nonatomic,copy) NSString *checkinDescription;

- (id)initWithDic:(id)data;

@end
