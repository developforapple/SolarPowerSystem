//
//  ReservationModel.h
//  Golf
// new DataPicker("1","待上课"),
// new DataPicker("2","已完成"),
// new DataPicker("3","未到场"),
// new DataPicker("4","已取消"),
// new DataPicker("5","待确认"),
// new DataPicker("6","待评价"),
//
//  Created by 黄希望 on 15/5/18.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReservationModel : NSObject

@property (nonatomic,assign) int reservationId; // 预约id
@property (nonatomic,copy) NSString *reservationTime; // "2015-05-21 12:00:00",
@property (nonatomic,copy) NSString *reservationDate;
@property (nonatomic,copy) NSString *reservationWeekname;

@property (nonatomic,assign) int periodId; // 课时Id
@property (nonatomic,assign) int classId;// 新的课程Id
@property (nonatomic,assign) int reservationStatus;  //预约状态
@property (nonatomic,assign) int productId; //产品ID
@property (nonatomic,copy) NSString *productName; // "产品名称",
@property (nonatomic,assign) int coachId; //教练ID
@property (nonatomic,assign) int memberId; //用户ID
@property (nonatomic,copy) NSString *nickName; // "用户姓名",
@property (nonatomic,copy) NSString *headImage; // :"用户头像URL"，
@property (nonatomic,copy) NSString *teachingSite; // :"教学场地",
@property (nonatomic,copy) NSString *address; // "详细地址",
@property (nonatomic,assign) float distance; // 距离
@property (nonatomic) int publicClassId;//公开课id
@property (nonatomic) int commentId;
@property (nonatomic,copy) NSString *commentContent;
@property (nonatomic) float starLevel;
@property (nonatomic) BOOL canCancel;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,copy) NSString *replyContent;
@property (nonatomic,copy) NSString *replyTime;

// 经纬度
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;

- (id)initWithDic:(id)data;

- (NSString *)getReplyContentIfNotNull;

@end
