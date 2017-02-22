//
//  PublicCourseDetail.h
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseModel.h"

// ************** 报名类 ***************//
@interface JoinModel : NSObject

@property (nonatomic,assign) int memberId;
@property (nonatomic,strong) NSString *displayName;
@property (nonatomic,assign) int memberLevel;
@property (nonatomic,assign) int gender;
@property (nonatomic,assign) int handicap;
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *headImage;
@property (nonatomic,strong) NSString *joinTime;

- (id)initWithDic:(id)data;

@end

// ************* 公开课详情类 ***************//
@interface PublicCourseDetail : PublicCourseModel

@property (nonatomic,strong) NSString *productIntro;
@property (nonatomic,strong) NSString *productDetail;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,strong) NSArray *pictureList;// 课程图片
@property (nonatomic,strong) NSArray *joinList; // 报名列表
@property (nonatomic,assign) int commentCount;
@property (nonatomic,strong) NSArray *commentList;
@property (nonatomic,assign) int coachId;
@property (nonatomic,strong) NSString *displayName;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *headImage;
@property (nonatomic,assign) int coachLevel;
@property (nonatomic,assign) float starLevel;

@property (nonatomic,strong) NSString *shareTitle;
@property (nonatomic,strong) NSString *shareContent;
@property (nonatomic,strong) NSString *shareImage;
@property (nonatomic,strong) NSString *shareUrl;

- (id)initWithDic:(id)data;

@end
