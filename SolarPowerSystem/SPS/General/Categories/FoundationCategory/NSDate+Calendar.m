//
//  NSDate+Calendar.m
//  QuizUp
//
//  Created by Normal on 16/5/9.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import "NSDate+Calendar.h"

NSCalendar *calendar(){
    static NSCalendar *kCalendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        kCalendar.timeZone = [NSTimeZone localTimeZone];
    });
    return kCalendar;
}

@implementation NSDate (Calendar)


+ (NSTimeInterval)secondOfWeek
{
    return 7 * [self secondOfDay];
}

+ (NSTimeInterval)secondOfDay
{
    return 24 * [self secondOfHour];
}

+ (NSTimeInterval)secondOfHour
{
    return 60 * [self secondOfMinute];
}

+ (NSTimeInterval)secondOfMinute
{
    return 60.f;
}

+ (NSString *)localStringOfWeekday:(NSUInteger)weekday
{
    static NSArray *weekdayLocal;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        weekdayLocal = @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    });
    if (weekday > 7 || weekday == 0) {
        return nil;
    }
    return weekdayLocal[weekday-1];
}

// iOS8 ONLY
- (NSInteger)componentOfUnit:(NSCalendarUnit)unit
{
    return [calendar() component:unit fromDate:self];
}

- (NSInteger)year
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitYear];
    }
    return [calendar() components:NSCalendarUnitYear fromDate:self].year;
}
- (NSUInteger)month
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitMonth];
    }
    return [calendar() components:NSCalendarUnitMonth fromDate:self].month;
}
- (NSUInteger)day
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitDay];
    }
    return [calendar() components:NSCalendarUnitDay fromDate:self].day;
}
- (NSUInteger)hour
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitHour];
    }
    return [calendar() components:NSCalendarUnitHour fromDate:self].hour;
}
- (NSUInteger)minute
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitMinute];
    }
    return [calendar() components:NSCalendarUnitMinute fromDate:self].minute;
}
- (NSUInteger)second
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitSecond];
    }
    return [calendar() components:NSCalendarUnitSecond fromDate:self].second;
}
- (NSUInteger)weekday
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitWeekday];
    }
    return [calendar() components:NSCalendarUnitWeekday fromDate:self].weekday;
}
- (NSUInteger)weekOfYear
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitWeekOfYear];
    }
    return [calendar() components:NSCalendarUnitWeekOfYear fromDate:self].weekOfYear;
}
- (NSUInteger)weekOfMonth
{
    if (iOS8) {
        return [self componentOfUnit:NSCalendarUnitWeekOfMonth];
    }
    return [calendar() components:NSCalendarUnitWeekOfMonth fromDate:self].weekOfMonth;
}

- (NSString *)weekdayDesc
{
    NSUInteger weekday = [self weekday];
    static NSString *list[] = {@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"};
    if (weekday <= 7) {
        return list[weekday-1];
    }
    return nil;
}

- (NSString *)weekdatDesc2
{
    NSUInteger weekday = [self weekday];
    static NSString *list[] = {@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"};
    if (weekday <= 7) {
        return list[weekday-1];
    }
    return nil;
}

- (NSDate *)zeroOclockDate
{
    NSInteger year;
    NSUInteger month,day;
    [self year:&year month:&month day:&day];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    components.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDate *date = [calendar() dateFromComponents:components];
    return date;
}

- (NSDate *)zeroMinuteDate
{
    NSInteger year;
    NSUInteger month,day,hour;
    [self year:&year month:&month day:&day];
    [self hour:&hour minute:NULL second:NULL];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = hour;
    components.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    NSDate *date = [calendar() dateFromComponents:components];
    return date;
}

- (void)year:(NSInteger *)year
       month:(NSUInteger *)month
         day:(NSUInteger *)day
{
    NSDateComponents *components = [calendar() components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    if (year != NULL) *year = components.year;
    if (month != NULL) *month = components.month;
    if (day != NULL) *day = components.day;
}

- (void)hour:(NSUInteger *)hour
      minute:(NSUInteger *)minute
      second:(NSUInteger *)second
{
    NSDateComponents *components = [calendar() components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];
    if (hour != NULL) *hour = components.hour;
    if (minute != NULL) *minute = components.minute;
    if (second != NULL) *second = components.second;
}

@end

@implementation NSDate (Desc)

- (NSString *)customDescription
{
    NSString *desc;
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:self];
    if (interval < -60.f) {
        desc = @"来自未来";
    }else if ([self isToday]){
        //今天
        CGFloat hours = interval/60/60;
        if (hours < 1.f) {
            desc = @"刚刚";
        }else{
            desc = [NSString stringWithFormat:@"%d小时前",(int)hours];
        }
    }else if([self isYesterday]){
        //昨天
        desc = @"昨天";
    }else{
        desc = [NSString stringWithFormat:@"%ld-%ld",(long)self.month,(long)self.day];
    }
    return desc;
}

- (NSString *)customDescriptionForChatMessage
{
    // 旧代码
    
    /**
     http://docs.alibaba-inc.com/display/526proj/005IM
     
     1、时间戳显示最后一条消息的时间，如果消息已经被清空，时间戳则消失；
     2、时间戳格式：一分钟之内（刚刚），今天的（上午/下午 小时:分钟），昨天，前天，n月n日（6月30日），一年之前的 年/月/日（14/6/30）
     */
    
    NSDate *date = self;
    
    NSParameterAssert(date);
    
    NSString * simpleString = nil;
    
    NSDate *nowDate = [NSDate date];
    
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSTimeInterval nowTimeInterval = [nowDate timeIntervalSince1970];
    
    if (nowTimeInterval-timeInterval <= 60)
    {
        // 刚刚
        simpleString = NSLocalizedString(@"刚刚", nil);
        return simpleString;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    
    NSDateComponents *dateComps = [calendar components:unitFlags fromDate:date];
    NSDateComponents *nowComps = [calendar components:unitFlags fromDate:nowDate];
    
    NSDate *ymdDate = [calendar dateFromComponents:dateComps];
    NSDate *nowYmdDate = [calendar dateFromComponents:nowComps];
    
    NSDateComponents *finalComps = [calendar components:unitFlags fromDate:ymdDate toDate:nowYmdDate options:0];
    
    if (finalComps.era == 0
        && finalComps.year == 0
        && finalComps.month == 0
        && finalComps.day == 0)
    {
        // 今天 直接显示 时:分
        static NSDateFormatter *timeFormatter = nil;
        if (!timeFormatter)
        {
            timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateStyle:NSDateFormatterNoStyle];
            [timeFormatter setTimeStyle:NSDateFormatterShortStyle]; // 这种方式自动显示成类似status bar上的时间风格，包括24小时制以及非24小时时中午上下午前置，英文AM/PM后置
        }
        
        simpleString = [timeFormatter stringFromDate:date];
        return simpleString;
    }
    
    if (finalComps.era == 0
        && finalComps.year == 0
        && finalComps.month == 0
        && finalComps.day == 1)
    {
        // 昨天
        simpleString = @"昨天";
        return simpleString;
    }
    
    if (finalComps.era == 0
        && finalComps.year == 0
        && finalComps.month == 0
        && finalComps.day == 2)
    {
        // 前天
        simpleString = @"前天";
        return simpleString;
    }
    
    if (finalComps.era == 0
        && finalComps.year == 0)
    {
        // 一年内 显示 x月x日
        static NSDateFormatter *shortDateFormatter = nil;
        if (!shortDateFormatter)
        {
            shortDateFormatter = [[NSDateFormatter alloc] init];
            shortDateFormatter.dateFormat = @"M月d日";
        }
        
        simpleString = [shortDateFormatter stringFromDate:date];
        return simpleString;
    }
    
    // 超过一年的，显示年/月/日
    static NSDateFormatter *mediumDateFormatter = nil;
    if (!mediumDateFormatter)
    {
        mediumDateFormatter = [[NSDateFormatter alloc] init];
        mediumDateFormatter.dateFormat = @"yyyy年M月d日";
    }
    
    simpleString = [mediumDateFormatter stringFromDate:date];
    
    return simpleString;
}

@end
