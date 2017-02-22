//
//  CalendarClass.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "CalendarClass.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@implementation CalendarClass

+ (NSDate *)dateForToday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateForStandardToday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    return [[calendar dateFromComponents:components] dateByAddingTimeInterval:8*3600];
}

+ (NSDate*)dateForStandardTodayAll{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    return [[calendar dateFromComponents:components] dateByAddingTimeInterval:8*3600];
}

+ (NSInteger)weekdayOfFirstDayInDate:(NSDate*)aDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

// 获取date当前月的总天数
+ (NSInteger)totalDaysInMonthOfDate:(NSDate *)date{
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 获取date的上个月日期
+ (NSDate *)previousMonthDate:(NSDate*)aDate{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:aDate options:NSCalendarMatchStrictly];
    return previousMonthDate;
}

// 获取date的下个月日期
+ (NSDate *)nextMonthDate:(NSDate*)aDate{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:aDate options:NSCalendarMatchStrictly];
    return previousMonthDate;
}

+ (NSInteger)daysOfFromDate:(NSDate*)fromDate endDate:(NSDate*)endDate{
    if (!fromDate || !endDate) {
        return 0;
    }
    return fabs(([endDate timeIntervalSince1970]-[fromDate timeIntervalSince1970]))/(3600*24);
}

+ (NSString*)getformatStringBy:(NSCalendarUnit)calendarUnit date:(NSDate*)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:calendarUnit fromDate:date];
    NSString *formatString = nil;
    switch (calendarUnit) {
        case NSCalendarUnitYear:
            formatString = [NSString stringWithFormat:@"%04d",(int)[dateComp year]];
            break;
        case NSMonthCalendarUnit:
            formatString = [NSString stringWithFormat:@"%02d",(int)[dateComp month]];
        case NSDayCalendarUnit:
            formatString = [NSString stringWithFormat:@"%02d",(int)[dateComp day]];
        case NSHourCalendarUnit:
            formatString = [NSString stringWithFormat:@"%02d",(int)[dateComp hour]];
        case NSMinuteCalendarUnit:
            formatString = [NSString stringWithFormat:@"%02d",(int)[dateComp minute]];
        case NSSecondCalendarUnit:
            formatString = [NSString stringWithFormat:@"%02d",(int)[dateComp second]];
        default:
            formatString = @"";
            break;
    }
    return formatString;
}

@end

#pragma clang diagnostic pop
