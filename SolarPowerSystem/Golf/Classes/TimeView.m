//
//  TimeView.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TimeView.h"
#import "CalendarClass.h"
#import "DayView.h"

@interface TimeView()

@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *priceLabel;

@property (nonatomic,assign) BOOL disable;

@end

@implementation TimeView

- (void)setTime:(Time *)time{
    _time = time;
    _disable = NO;
    
    NSDate *today = [CalendarClass dateForToday];
    
    if ([_time.date compare:today] < 0) {
        _disable = YES;
    }else if ([_time.date compare:today] == 0){
        NSString *tt = [Utilities getCurrentTimeWithFormatter:@"HH:mm"];
        NSInteger currentMin = [self minutesWithTeetime:tt];
        NSInteger theMin = [self minutesWithTeetime:_time.teetime];
        if (theMin < currentMin) {
            _time.selected = NO;
            _disable = YES;
        }
    }
    
    if (_time) {
        [_timeLabel setText:_time.teetime];
        if (_hasPrice) {
            _priceLabel.text = _time.price>=0 ? [NSString stringWithFormat:@"¥%d",_time.price] : @"";
        }
    }
    [self handleColor];
}

- (NSInteger)minutesWithTeetime:(NSString*)teetime{
    if (!teetime) {
        return 0;
    }
    NSArray *arr = [teetime componentsSeparatedByString:@":"];
    NSInteger h = [arr[0] integerValue];
    NSInteger m = [arr[1] integerValue];
    return h*60+m;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_scrolling && _scrolling()) {
        return;
    }
    if (self.disable) {
        return;
    }
    _time.selected = YES;
    if (_time.selectBlock) {
        _time.selectBlock (_time.teetime);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_scrolling && _scrolling()) {
        return;
    }
    if (self.disable) {
        return;
    }
    if (_time.selectEndBlock) {
        _time.selectEndBlock(_time.teetime);
    }
}

- (void)handleColor{
    if (_time.selected) {
        self.backgroundColor = [UIColor colorWithHexString:@"249df3"];
        [self selectColor];
    }else{
        self.backgroundColor = [UIColor whiteColor];
        [self normalColor];
    }
    
    if (self.disable) {
        [self disableColor];
    }
}

// 禁用
- (void)disableColor{
    _timeLabel.textColor = K_DT_DISABLE_COLOR;
    _priceLabel.textColor = K_DT_DISABLE_COLOR;
}

// 已选中
- (void)selectColor{
    _timeLabel.textColor = [UIColor whiteColor];
    if (_hasPrice) {
        _priceLabel.textColor = [UIColor whiteColor];
    }
}

// 可用未选中
- (void)normalColor{
    _timeLabel.textColor = K_DT_DATE_COLOR;
    if (_hasPrice) {
        _priceLabel.textColor = _time.specialOffer==1 ? K_DT_CP_COLOR : K_DT_OP_COLOR;
    }
}

@end
