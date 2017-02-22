//
//  NSCalendar+YGCategory.h
//  Golf
//
//  Created by bo wang on 2017/2/15.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GregorianCalendar [NSCalendar gregorianCalendar]
#define ChineseCalendar [NSCalendar chineseCalendar]

@interface NSCalendar (YGCategory)

+ (instancetype)gregorianCalendar;
+ (instancetype)chineseCalendar;

// 某年某月的第一天
- (NSDateComponents *)firstDayOfYear:(NSInteger)year month:(NSInteger)month;
// 某年某月的最后一天
- (NSDateComponents *)lastDayOfYear:(NSInteger)year month:(NSInteger)month;
// 某年某月某日
- (NSDateComponents *)dateComponentsOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;


// 从一个日期到另外一个日期，出现的全部月份数量。
- (NSInteger)numberOfReferredMonthFrom:(NSDateComponents *)from to:(NSDateComponents *)to;

// 公历节日。
- (NSArray *)GregorianHolidaysOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
// 公历年月日对应的农历节日。
+ (NSArray *)ChineseHolidaysOfYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

