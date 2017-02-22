//
//  NSCalendar+YGCategory.m
//  Golf
//
//  Created by bo wang on 2017/2/15.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "NSCalendar+YGCategory.h"

static BOOL isEaster(int iYear, int iMonth, int iDay){
    NSDictionary *easterDays = @{@2017:@416,
                                 @2018:@401,
                                 @2019:@412,
                                 @2020:@414};
    return [@(iMonth*100+iDay) isEqualToNumber:easterDays[@(iYear)]];
}

static BOOL isMothersDay(int iYear, int iMonth, int iDay){
    NSDictionary *days = @{@2017:@514,
                           @2018:@513,
                           @2019:@512,
                           @2020:@510,
                           @2021:@509};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

static BOOL isFathersDay(int iYear, int iMonth, int iDay){
    NSDictionary *days = @{@2017:@618,
                           @2018:@617,
                           @2019:@616,
                           @2020:@621,
                           @2021:@620};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

static BOOL isThanksgivingDay(int iYear, int iMonth, int iDay){
    NSDictionary *days = @{@2017:@1123,
                           @2018:@1122,
                           @2019:@1128,
                           @2020:@1126,
                           @2021:@1125};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

static BOOL isQingMingDay(int iYear, int iMonth , int iDay){
    NSDictionary *days = @{@2017:@404,
                           @2018:@405,
                           @2019:@405,
                           @2020:@404,
                           @2021:@404};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

static BOOL isDongZhiDay(int iYear, int iMonth , int iDay){
    NSDictionary *days = @{@2017:@1222,
                           @2018:@1222,
                           @2019:@1222,
                           @2020:@1221,
                           @2021:@1221};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

static BOOL isChuXiDay(int iYear, int iMonth , int iDay){
    NSDictionary *days = @{@2017:@127,
                           @2018:@215,
                           @2019:@204,
                           @2020:@124,
                           @2021:@211};
    return [@(iMonth*100+iDay) isEqualToNumber:days[@(iYear)]];
}

@implementation NSCalendar (YGCategory)

+ (instancetype)gregorianCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

+ (instancetype)chineseCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    });
    return calendar;
}

- (NSDateComponents *)firstDayOfYear:(NSInteger)year month:(NSInteger)month
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = 1;
    NSDate *firstMonthDate = [self dateFromComponents:components];
    components = [self components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:firstMonthDate];
    return components;
}

- (NSDateComponents *)lastDayOfYear:(NSInteger)year month:(NSInteger)month
{
    NSDateComponents *nextMonthFirstDay = [[NSDateComponents alloc] init];
    nextMonthFirstDay.year = year;
    nextMonthFirstDay.month = month + 1;
    nextMonthFirstDay.day = 1;
    NSDate *lastMonthDate = [[self dateFromComponents:nextMonthFirstDay] dateByAddingDays:-1];
    NSDateComponents *components = [self components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:lastMonthDate];
    return components;
}

- (NSDateComponents *)dateComponentsOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = day;
    NSDate *firstMonthDate = [self dateFromComponents:components];
    components = [self components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:firstMonthDate];
    return components;
}

- (NSInteger)numberOfReferredMonthFrom:(NSDateComponents *)from to:(NSDateComponents *)to
{
    NSDateComponents *fromCopy = [from copy];
    NSDate *dateOfLastDayMonth = [self dateFromComponents:to];
    
    NSInteger numberOfMonth = 1;
    while(1){
        fromCopy.month++;
        NSDate *date = [self dateFromComponents:fromCopy];
        if ([date compare:dateOfLastDayMonth] == NSOrderedDescending) {
            break;
        }else{
            numberOfMonth++;
        }
        if (numberOfMonth == 1000000) {
            break;
        }
    }
    return numberOfMonth;
}

// 公历节日
- (NSArray *)GregorianHolidaysOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    // 当前self不是公历时，转换年月日至公历
    if (![self.calendarIdentifier isEqualToString:NSCalendarIdentifierGregorian]) {
        NSDateComponents *components = [self dateComponentsOfYear:year month:month day:day];
        NSDate *date = [self dateFromComponents:components];
        [GregorianCalendar getEra:NULL year:&year month:&month day:&day fromDate:date];
    }
    
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{@101:@[@"元旦"],
                 @214:@[@"情人节"],
                 @308:@[@"妇女节"],
                 @501:@[@"劳动节"],
                 @504:@[@"青年节"],
                 @601:@[@"儿童节"],
                 @701:@[@"建党节"],
                 @801:@[@"建军节"],
                 @910:@[@"教师节"],
                 @1001:@[@"国庆节"],
                 @1101:@[@"万圣节"],
                 @1225:@[@"圣诞节"]
                };
    });
    
    NSMutableArray *holidays = [NSMutableArray array];
    NSNumber *gId = @(month * 100 + day);
    NSArray *gHolidays = dict[gId];
    [holidays addObjectsFromArray:gHolidays];
    
    // 复活节
    if (isEaster(year, month, day)) {
        [holidays addObject:@"复活节"];
    }else
    
    //母亲节
    if (isMothersDay(year, month, day)) {
        [holidays addObject:@"母亲节"];
    }else
    
    // 父亲节
    if (isFathersDay(year, month, day)) {
        [holidays addObject:@"父亲节"];
    }else
    
    // 感恩节
    if (isThanksgivingDay(year, month, day)) {
        [holidays addObject:@"感恩节"];
    }
    
    return holidays;
}

// 农历节日
+ (NSArray *)ChineseHolidaysOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSMutableArray *holidays = [NSMutableArray array];
    
    NSInteger cMonth,cDay;
    NSDateComponents *components = [GregorianCalendar dateComponentsOfYear:year month:month day:day];
    NSDate *date = [GregorianCalendar dateFromComponents:components];
    [ChineseCalendar getEra:NULL year:NULL month:&cMonth day:&cDay fromDate:date];
    
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{@101:@[@"春节"],
                 @115:@[@"元宵节"],
                 @505:@[@"端午节"],
                 @707:@[@"七夕"],
                 @715:@[@"中元节"],
                 @815:@[@"中秋节"],
                 @909:@[@"重阳节"]};
    });
    NSNumber *cId = @(cMonth * 100 + cDay);
    NSArray *cHolidays = dict[cId];
    [holidays addObjectsFromArray:cHolidays];
    
    if (holidays.count == 0) {
        if (isQingMingDay(year, month, day)) {
            [holidays addObject:@"清明节"];
        }else if (isDongZhiDay(year, month, day)){
            [holidays addObject:@"冬至"];
        }else if (isChuXiDay(year, month, day)){
            [holidays addObject:@"除夕"];
        }
    }
    return holidays;
}

@end
