//
//  TwoButtonView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "TwoButtonView.h"

@implementation TwoButtonView


- (IBAction)btnAction1:(id)sender {
    if (_blockReturn) {
        [[BaiduMobStat defaultStat] logEvent:@"btnTimetableReserve" eventLabel:@"我的时间表预约按钮点击"];
        [MobClick event:@"btnTimetableReserve" label:@"我的时间表预约按钮点击"];
        NSMutableDictionary *nd = [[NSMutableDictionary alloc] initWithDictionary:_data];
        [nd setObject:@"subscribe" forKey:@"type"];
        _blockReturn(nd);
    }
}


- (IBAction)btnAction2:(id)sender {
    if (_blockReturn) {
        [[BaiduMobStat defaultStat] logEvent:@"btnTimetableTimeClose" eventLabel:@"我的时间表关闭预约点击"];
        [MobClick event:@"btnTimetableTimeClose" label:@"我的时间表关闭预约点击"];
        NSMutableDictionary *nd = [[NSMutableDictionary alloc] initWithDictionary:_data];
        [nd setObject:@"close" forKey:@"type"];
        _blockReturn(nd);
    }
}

@end
