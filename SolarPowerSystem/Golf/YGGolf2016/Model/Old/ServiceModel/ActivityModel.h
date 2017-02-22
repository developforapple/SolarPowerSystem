//
//  ActivityModel.h
//  Golf
//
//  Created by user on 12-11-30.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject <NSCoding,NSCopying>

@property (nonatomic) int activityId;
@property (nonatomic) int activityAction;
@property (nonatomic) int actionId;
@property (nonatomic,copy) NSString *activityName;
@property (nonatomic,copy) NSString *activityPicture;
@property (nonatomic,copy) NSString *activityPage;
@property (nonatomic,copy) NSString *activityIntro;
@property (nonatomic,copy) NSString *actionDate;
@property (nonatomic,copy) NSString *actionTime;
@property (nonatomic,copy) NSString *beginDate;
@property (nonatomic,copy) NSString *endDate;

@property (nonatomic,copy) NSString *dataType;
@property (nonatomic) int dataId;
@property (nonatomic) int subType;
@property (nonatomic,copy) NSString *dataExtra;

@property (nonatomic) int areaShape; //区域形状 1:长形 2:方形
@property (nonatomic) int combineMode; //0正常，1复合

- (id)initWithDic:(id)data;

@end
