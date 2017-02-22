//
//  CalendarClass.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarClass : NSObject

// 获取当前日期
+ (NSDate *)dateForToday;

// 北京时间 yyyy-MM-dd
+ (NSDate *)dateForStandardToday;

// 北京时间 yyyy-MM-dd HH:mm:ss
+ (NSDate *)dateForStandardTodayAll;

// 获取date当前月的第一天是星期几
+ (NSInteger)weekdayOfFirstDayInDate:(NSDate*)aDate;

// 获取date当前月的总天数
+ (NSInteger)totalDaysInMonthOfDate:(NSDate *)date;

// 获取date的上个月日期
+ (NSDate *)previousMonthDate:(NSDate*)aDate;

// 获取date的下个月日期
+ (NSDate *)nextMonthDate:(NSDate*)aDate;

// 两个日期之间的间隔天数
+ (NSInteger)daysOfFromDate:(NSDate*)fromDate endDate:(NSDate*)endDate;

// 返回格式化后的日期
+ (NSString*)getformatStringBy:(NSCalendarUnit)calendarUnit date:(NSDate*)date;

@end
