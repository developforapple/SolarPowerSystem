//
//  SpecialOfferModel.m
//  Golf
//
//  Created by user on 13-1-17.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import "SpecialOfferModel.h"
#import "Utilities.h"

@implementation SpecialOfferModel
@synthesize clubId = _clubId;
@synthesize clubName = _clubName;
@synthesize originalPrice = _originalPrice;
@synthesize currentPrice = _currentPrice;
@synthesize weekDay = _weekDay;
@synthesize beginDate = _beginDate;
@synthesize beginTime = _beginTime;
@synthesize endDate = _endDate;
@synthesize endTime = _endTime;
@synthesize isOfficial = _isOfficial;
@synthesize payType = _payType;
@synthesize shortName = _shortName;


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"club_id"]) {
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if ([dic objectForKey:@"original_price"]) {
        self.originalPrice = [[dic objectForKey:@"original_price"] intValue]/100;
    }
    if ([dic objectForKey:@"current_price"]) {
        self.currentPrice = [[dic objectForKey:@"current_price"] intValue]/100;
    }
    if ([dic objectForKey:@"week_day"]) {
        self.weekDay = [[dic objectForKey:@"week_day"] intValue];
    }
    if ([dic objectForKey:@"is_official"]) {
        self.isOfficial = [[dic objectForKey:@"is_official"] intValue];
    }
    if ([dic objectForKey:@"pay_type"]) {
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
    }
    if ([dic objectForKey:@"club_name"]) {
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if ([dic objectForKey:@"begin_date"]) {
        self.beginDate = [dic objectForKey:@"begin_date"];
    }
    if ([dic objectForKey:@"end_date"]) {
        self.endDate = [dic objectForKey:@"end_date"];
    }
    if ([dic objectForKey:@"begin_time"]) {
        self.beginTime = [dic objectForKey:@"begin_time"];
    }
    if ([dic objectForKey:@"end_time"]) {
        self.endTime = [dic objectForKey:@"end_time"];
    }
    if ([dic objectForKey:@"short_name"]) {
        self.shortName = [dic objectForKey:@"short_name"];
    }
    return self;
}

+ (NSString *)weekWithIndex:(NSInteger)index{
    switch (index) {
        case 1:
            return @"每周日优惠";
            break;
        case 2:
            return @"每周一优惠";
            break;
        case 3:
            return @"每周二优惠";
            break;
        case 4:
            return @"每周三优惠";
            break;
        case 5:
            return @"每周四优惠";
            break;
        case 6:
            return @"每周五优惠";
            break;
        case 7:
            return @"每周六优惠";
            break;
            
        default:
            break;
    }
    return nil;
}

+ (NSString *)stringwithObject:(SpecialOfferModel *)model index:(NSInteger)index{
    if ([model.beginDate isEqualToString:model.endDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [formatter dateFromString:model.endDate];
        [formatter setDateFormat:@"MM月dd日"];
        NSString *dateStr = [formatter stringFromDate:date];
        return dateStr;
    }
    
    NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
    NSDate *bg = [Utilities getDateFromString:model.beginDate];
    NSDate *ed = [Utilities getDateFromString:model.endDate];
    
    NSDate *theBgDate = [Utilities getTheDay:bg withNumberOfDays:0];
    
    NSDate *theEdDate = [Utilities getTheDay:ed withNumberOfDays:0];
    if ([theBgDate timeIntervalSinceDate:today] < 0) {
        if ([theEdDate timeIntervalSinceDate:today] > 3600*24*7) {
            return model.weekDay>0 ? [self weekWithIndex:model.weekDay] : @"每周固定优惠";
        }
        else{
            NSInteger todayIndex = [Utilities weekDayByDate:today];
            NSInteger index = model.weekDay-todayIndex;
            NSDate *returnDate;
            if (index > 0) {
                returnDate = [Utilities getTheDay:today withNumberOfDays:index];
            }
            else{
                returnDate = [Utilities getTheDay:today withNumberOfDays:7+index];
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM月dd日"];
            NSString *returnStr = [formatter stringFromDate:returnDate];
            return returnStr;
        }
    }else{
        if ([theEdDate timeIntervalSinceDate:theBgDate] > 3600*24*7) {
            return model.weekDay>0 ? [self weekWithIndex:model.weekDay] : @"每周固定优惠";
        }else{
            //            NSInteger todayIndex = [Utilities weekDayByDate:theBgDate];
            //            NSInteger index = model.weekDay-todayIndex;
            //            NSDate *returnDate;
            //            if (index > 0) {
            //                returnDate = [Utilities getTheDay:theBgDate withNumberOfDays:index];
            //            }
            //            else{
            //                returnDate = [Utilities getTheDay:theBgDate withNumberOfDays:7+index];
            //            }
            //            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //            [formatter setDateFormat:@"MM月dd日"];
            //            NSString *returnStr = [formatter stringFromDate:returnDate];
            //            [formatter release];
            //            return returnStr;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM月dd日"];
            NSString *b = [formatter stringFromDate:theBgDate];
            NSString *e = [formatter stringFromDate:theEdDate];
            return [NSString stringWithFormat:@"%@-%@",b,e];
        }
    }
}

@end
