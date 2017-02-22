//
//  CoachBaseinfo.h
//  Golf
//
//  Created by 黄希望 on 15/6/17.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachBaseinfo : NSObject

@property (nonatomic,strong) NSString *headImageUrl;
@property (nonatomic,strong) UIImage *headImage; // 头像
@property (nonatomic,strong) NSString *headImageData; // 二进制头像
@property (nonatomic,strong) NSString *nickName; // 名字
@property (nonatomic,assign) int gender; // 性别
@property (nonatomic,assign) int age; // 年龄
@property (nonatomic,strong) NSString *birthday; // 生日
@property (nonatomic,assign) int academyId;
@property (nonatomic,strong) NSString *academyName; // 所属学院
@property (nonatomic,assign) int seniority; // 教龄
@property (nonatomic,strong) NSString *personalProfile; // 个人简介
@property (nonatomic,strong) NSString *achievement;  // 所获成就
@property (nonatomic,strong) NSString *teachHarvest;  // 教学成果

@end
