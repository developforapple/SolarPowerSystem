//
//  AcademyModel.h
//  Golf
//
//  Created by 黄希望 on 14-3-3.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AcademyModel : NSObject

@property (nonatomic) int academyId;
@property (nonatomic) int coachCount;
@property (nonatomic,copy) NSString *academyName;
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *shortAddress;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *photoImage;
@property (nonatomic,copy) NSString *signature;
@property (nonatomic,copy) NSString *introduction;
@property (nonatomic,copy) NSString *linkPhone;
@property (nonatomic,strong) NSArray *albumList;
@property (nonatomic) float distance;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic,copy) NSString *teachingSite;
@property (nonatomic,copy) NSMutableArray *publicClassList;

// 是否支持App订场。v7.1加
@property (assign, nonatomic) BOOL virtualCourseFlag;

- (id)initWithDic:(id)data;


@end
