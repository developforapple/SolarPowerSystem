//
//  DayViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "DayViewCell.h"
#import "DayView.h"

@interface DayViewCell()

@property (nonatomic,strong) IBOutletCollection(DayView) NSArray *dayViews;

@end

@implementation DayViewCell

- (void)setDays:(NSArray *)days{
    
    for (DayView *dv in _dayViews) {
        dv.scrolling = _scrolling;
        dv.hidden = YES;
        dv.hasPrice = _hasPrice;
    }
    
    _days = days;
    for (Day *day in _days) {
        DayView *dv = _dayViews[day.weekDay];
        dv.day = day;
        dv.hidden = NO;
    }
}

@end
