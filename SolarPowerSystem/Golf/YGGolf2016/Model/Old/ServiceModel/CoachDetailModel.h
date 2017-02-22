//
//  CoachDetailModel.h
//  Golf
//
//  Created by 黄希望 on 14-2-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoachModel.h"

@interface CoachDetailModel : CoachModel

@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *photoImage;
@property (nonatomic) int academyId;
@property (nonatomic,copy) NSString *academyName;
@property (nonatomic,copy) NSString *signaure;
@property (nonatomic) int bestGrade;
@property (nonatomic) int memberId;
@property (nonatomic,copy) NSString *oftenGoPlace;
@property (nonatomic,copy) NSString *careerAchievement;
@property (nonatomic,copy) NSString *teachingAchievement;
@property (nonatomic,copy) NSString *teachingSpecialty;
@property (nonatomic,copy) NSString *introduction;
@property (nonatomic) BOOL praised;
@property (nonatomic) int msgCount;
@property (nonatomic,copy) NSString *phoneNum;
@property (nonatomic,copy) NSString *birthday;
@property (nonatomic,copy) NSString *linkPhone;
@property (nonatomic,copy) NSString *headImageData;
@property (nonatomic,copy) NSString *photoImageData;
@property (nonatomic,strong) UIImage *headSaveImage;
@property (nonatomic,strong) UIImage *photoSaveImage;
@property (nonatomic,strong) NSArray *albumList;
@property (nonatomic,strong) NSMutableArray *commodityList;

- (id)initWithDic:(id)data;


@end
