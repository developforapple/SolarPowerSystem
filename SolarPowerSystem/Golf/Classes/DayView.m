//
//  DayView.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "DayView.h"
#import "CalendarClass.h"

@interface DayView (){
    BOOL _isScrolling;
}

@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *priceLabel;

@property (nonatomic,assign) BOOL disable;

@end

@implementation DayView

- (void)setDay:(Day *)day{
    _day = day;
    
    NSDate *today = [CalendarClass dateForToday];
    NSInteger days = [CalendarClass daysOfFromDate:today endDate:_day.date];
    _disable = ([_day.date compare:today] < 0 || days > 59) ? YES : NO;
    
    if (_day) {
        if ([_day.date compare:today] == 0) {
            _dateLabel.text = @"今天";
        }else if ([_day.date timeIntervalSinceDate:today]==24*3600){
            _dateLabel.text = @"明天";
        }else{
            _dateLabel.text = [NSString stringWithFormat:@"%tu",_day.day];
        }
        if (_day.holidayName.length>0 && _day.holidayName.length<4) {
            _dateLabel.text = _day.holidayName;
        }
        _priceLabel.text = @"";
        if (_hasPrice) {
            _priceLabel.text = _day.price>=0 ? [NSString stringWithFormat:@"¥%d",_day.price] : @"";
        }
        
        [self handleColor];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_scrolling && _scrolling()) {
        return;
    }
    if (self.disable) {
        return;
    }
    _day.selected = YES;
    if (_day.selectBlock) {
        _day.selectBlock (_day.date);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_scrolling && _scrolling()) {
        return;
    }
    if (self.disable) {
        return;
    }
    if (_day.selectEndBlock) {
        _day.selectEndBlock(_day.date);
    }
}

- (void)handleColor{
    if (_day.selected) {
        self.backgroundColor = [UIColor colorWithHexString:@"249df3"];
        [self selectColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
        [self normalColor];
    }
    // 过期或超过60天
    if (self.disable) {
        [self disableColor];
    }
}

// 已禁用
- (void)disableColor{
    _dateLabel.textColor = K_DT_DISABLE_COLOR;
    _priceLabel.textColor = K_DT_DISABLE_COLOR;
}

// 已选中
- (void)selectColor{
    _dateLabel.textColor = [UIColor whiteColor];
    if (_hasPrice) {
        _priceLabel.textColor = [UIColor whiteColor];
    }
}

// 可用未选中
- (void)normalColor{
    if (self.tag == 1 || self.tag == 7) {
        _dateLabel.textColor = K_DT_WEEKEND_COLOR;
    }else{
        _dateLabel.textColor = K_DT_DATE_COLOR;
    }
    if (_hasPrice) {
        _priceLabel.textColor = _day.specialOffer==1 ? K_DT_CP_COLOR : K_DT_OP_COLOR;
    }
}

@end
