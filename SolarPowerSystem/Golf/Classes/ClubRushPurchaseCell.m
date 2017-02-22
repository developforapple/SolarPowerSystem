//
//  ClubRushPurchaseCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubRushPurchaseCell.h"

@implementation ClubRushPurchaseCell

- (IBAction)buttonClickAction:(id)sender{
    _timeInteval = [ClubRushPurchaseCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab];
    if (_timeInteval <= 0) {
        if (self.spreeBlock) {
            self.spreeBlock (_csm);
        }
    }else if (_timeInteval >= 600){ // 设置提醒
        _csm.hasSetted = !_csm.hasSetted;
        if (_callBlock) {
            _callBlock (_csm);
        }
    }
}

+ (NSTimeInterval)timeIntervalWithCompareResult:(NSString*)time timeInterGab:(NSTimeInterval)timeInterGab{
    if (!time) {
        return -1;
    }
    NSDate *today = [CalendarClass dateForStandardTodayAll];
    today = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([today timeIntervalSinceReferenceDate] + timeInterGab)];
    NSDate *dt = [Utilities getDateFromString:time WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    return [dt timeIntervalSinceDate:today];
}

@end
