//
//  CoachTimetable.h
//  Golf
//
//  Created by 廖瀚卿 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachTimetable : NSObject


@property (nonatomic,copy) NSString *date;
@property (nonatomic) int classCount;
@property (nonatomic,strong) NSMutableArray *timeList;


- (id)initWithDic:(id)data;

@end



@interface TimeList : NSObject

@property (nonatomic,copy) NSString *time;
@property (nonatomic) int classType;
@property (nonatomic) int personCount;
@property (nonatomic) int publicClassId;
@property (nonatomic,strong) NSMutableArray *reservationList;

- (id)initWithDic:(id)data;

@end

