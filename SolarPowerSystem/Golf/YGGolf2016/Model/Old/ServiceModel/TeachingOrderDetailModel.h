//
//  TeachingOrderDetailModel.h
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderModel.h"

@interface Reservation : NSObject

@property (nonatomic,assign) int reservationId;             //预约ID
@property (nonatomic,strong) NSString *reservationTime;     //预约时间 "2015-06-02 12:00:00"
@property (nonatomic,assign) int reservationStatus;         //1:待上课 2：已完成 3：已过期 4：已取消
@property (nonatomic,assign) int commentStatus;             //0:未评 1：已评

- (id)initWithDic:(id)data;

@end

@interface TeachingOrderDetailModel : TeachingOrderModel

@property (nonatomic,assign) int remainHour;               //剩余课时数
@property (nonatomic,assign) int classId;
@property (nonatomic,assign) int publicClassId;             //公开课ID，大于0为公开课，不允许取消预约
@property (nonatomic,strong) NSString *teachingSite;        //教学地点
@property (nonatomic) float distance;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *teachingDate;
@property (nonatomic,strong) NSString *teachingTime;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,strong) NSArray *reservationList;

- (id)initWithDic:(id)data;

@end
