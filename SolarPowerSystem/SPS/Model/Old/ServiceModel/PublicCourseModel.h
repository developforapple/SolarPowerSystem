//
//  PublicCourseModel.h
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicCourseModel : NSObject

@property (nonatomic,assign) int publicClassId;
@property (nonatomic,assign) int productId;//产品ID
@property (nonatomic,strong) NSString *productName;//产品名称
@property (nonatomic,strong) NSString *productImage; //图片
@property (nonatomic,assign) double distance;//距离当前位置多少公里
@property (nonatomic,strong) NSString *teachingSite; // "西丽练习场",      //教学地点
@property (nonatomic,strong) NSString *shortAddress;
@property (nonatomic,strong) NSString *openDate; // 上课日期
@property (nonatomic,strong) NSString *openTime; // 上课时间
@property (nonatomic,assign) int sellingPrice; //价格
@property (nonatomic,assign) int personLimit;//名额限制
@property (nonatomic,assign) int personJoin;//已报名人数
@property (nonatomic,strong) NSString *blockTime; // 结束
@property (nonatomic,assign) int classStatus; // 报名状态

- (id)initWithDic:(id)data;

@end
