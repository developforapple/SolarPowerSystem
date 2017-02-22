//
//  TeachingCoachModel.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeachingCoachModel : NSObject

@property (nonatomic) int coachId;//教练ID
@property (nonatomic,copy) NSString *displayName;//显示名
@property (nonatomic,copy) NSString *nickName;//“nick_name”:”张三”,//昵称
@property (nonatomic,copy) NSString *headImage;//“head_image”:”http://xxx.xxx/xxx.jpg“, //头像位置
@property (nonatomic) int coachLevel;//“coach_level”:2,  //2星
@property (nonatomic) float starLevel;//“start_level”:4,   //4星
@property (nonatomic) int teachingCount;//“teaching_count”:5,      //教学次数
@property (nonatomic) int classFee;//“class_fee”:500,         //课时费

@property (nonatomic) float distance;//距离当前位置多少公里
@property (nonatomic,copy) NSString *teachingSite;//“teaching_site”:"西丽练习场",      //教学地点

@property (nonatomic,copy) NSString *address; // "详细地址",
@property (nonatomic,copy) NSString *shortAddress;
@property (nonatomic,assign) int academyId; //  学院ID
@property (nonatomic) int seniority;//教龄
@property (nonatomic,copy) NSString *introduction;//简介
@property (nonatomic,copy) NSString *careerAchievement;//:"简介",
@property (nonatomic,copy) NSString *teachingAchievement;//":"教学成果",
@property (nonatomic) int commentCount;//":12，       //评论数
@property (nonatomic) BOOL followed;//是否关注
@property (nonatomic,assign) int isFollowed;
//@property (nonatomic) int remainHour;

@property (nonatomic,copy) NSString *academyName; // "大生高尔夫"
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,copy) NSMutableArray *productList;
@property (nonatomic,copy) NSMutableArray *commentList;
@property (nonatomic,copy) NSMutableArray *publicClassList;
@property (nonatomic,copy) NSMutableArray *classList;

@property (nonatomic) CGFloat cellHeight;

- (id)initWithDic:(id)data;

@end
