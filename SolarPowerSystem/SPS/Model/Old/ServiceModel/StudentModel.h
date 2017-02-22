//
//  StudentModel.h
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentModel : NSObject

@property (nonatomic,assign) int memberId;          //用户ID
@property (nonatomic,strong) NSString *nickName;    // "用户昵称",
@property (nonatomic,strong) NSString *displayName;   // "用户备注名称",
@property (nonatomic,strong) NSString *headImage;   // "用户头像"
@property (nonatomic,assign) int remainHour;        //剩余课时
@property (nonatomic,assign) int waitHour;          //待上课课
@property (nonatomic,assign) int completeHour;      //已完成
@property (nonatomic,strong) NSString *mobilePhone;
@property (nonatomic,assign) int isFollowed;

- (id)initWithDic:(id)data;

@end
