//
//  NSDate+Calendar.h
//  QuizUp
//
//  Created by Normal on 16/5/9.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Calendar)

+ (NSTimeInterval)secondOfWeek;
+ (NSTimeInterval)secondOfDay;
+ (NSTimeInterval)secondOfHour;
+ (NSTimeInterval)secondOfMinute;
+ (NSString *)localStringOfWeekday:(NSUInteger)weekday;

- (NSInteger)year;
- (NSUInteger)month;
- (NSUInteger)day;
- (NSUInteger)hour;
- (NSUInteger)minute;
- (NSUInteger)second;
- (NSUInteger)weekday;      //从1开始。星期日=1 星期一=2
- (NSUInteger)weekOfYear;   //一年第几周
- (NSUInteger)weekOfMonth;  //一个月的第几周

- (NSString *)weekdayDesc;      //星期一 ......
- (NSString *)weekdatDesc2;     //周一 .....

//  UTC+8 时间
- (NSDate *)zeroOclockDate; //当前时间在当天0时0分0秒时的时间
//  UTC+8 时间
- (NSDate *)zeroMinuteDate; //当前时间在这个小时内的0分0秒时的时间

- (void)year:(NSInteger *)year
       month:(NSUInteger *)month
         day:(NSUInteger *)day;
- (void)hour:(NSUInteger *)hour
      minute:(NSUInteger *)minute
      second:(NSUInteger *)second;
@end

@interface NSDate (Desc)

- (NSString *)customDescription;

// 用于聊天的日期描述
- (NSString *)customDescriptionForChatMessage;

@end
