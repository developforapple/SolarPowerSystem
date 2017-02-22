//
//  WeekChooseView.m
//  Golf
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "WeekChooseView.h"
#import "Utilities.h"
@interface WeekChooseView ()
@property(nonatomic,strong) NSMutableArray *weekArr;
@property(nonatomic,strong) NSMutableArray *dateArr;
@property(nonatomic,strong) NSMutableArray *weekTag;
@end

@implementation WeekChooseView
@synthesize mondayBtn,tuesdayBtn,wednesdayBtn,thursdayBtn,fridayBtn,saturdayBtn,sundayBtn,scrollView;
@synthesize delegate = _delegate;

-(NSMutableArray *)weekArr{
    if (_weekArr == nil) {
        _weekArr = [NSMutableArray array];
    }
    return _weekArr;
}

-(NSMutableArray *)dateArr{
    if (_dateArr == nil) {
        _dateArr = [NSMutableArray array];
    }
    return _dateArr;
}

-(NSMutableArray *)weekTag{
    if (_weekTag == nil) {
        _weekTag = [NSMutableArray array];
    }
    return _weekTag;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self getWeekTime];
}


- (void)getWeekTime
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:nowDate];
    // 获取今天是周几
    //    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
    
    for (int i = 0; i < 7; i ++) {
        NSDateComponents *firstDayComp = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit  fromDate:nowDate];
#pragma clang diagnostic pop
        
        [firstDayComp setDay:day + i];
        NSDate *dayOfWeek = [calendar dateFromComponents:firstDayComp];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd日"];
        NSString *day = [formatter stringFromDate:dayOfWeek];
        [self.dateArr addObject:day];
        NSInteger weekDay = [Utilities weekDayByDate:dayOfWeek];
        [self.weekTag addObject:@(weekDay)];
        NSString *weekStr = [[NSString alloc] init];
        if (weekDay == 1) {
            weekStr = @"周日";
        }
        if (weekDay == 2) {
            weekStr = @"周一";
        }
        if (weekDay == 3) {
            weekStr = @"周二";
        }
        if (weekDay == 4) {
            weekStr = @"周三";
        }
        if (weekDay == 5) {
            weekStr = @"周四";
        }
        if (weekDay == 6) {
            weekStr = @"周五";
        }
        if (weekDay == 7) {
            weekStr = @"周六";
        }
        [self.weekArr addObject:weekStr];
    }
    
    self.lableThirdDay.text = self.dateArr[2];
    self.lableFourthDay.text = self.dateArr[3];
    self.lableFifthDay.text = self.dateArr[4];
    self.lableSixthDay.text = self.dateArr[5];
    self.lableSeventhDay.text = self.dateArr[6];
    
    [self.mondayBtn setTitle:self.weekArr[0] forState:0];
    self.mondayBtn.tag = [self.weekTag[0] integerValue];
    
    [self.tuesdayBtn setTitle:self.weekArr[1] forState:0];
    self.tuesdayBtn.tag = [self.weekTag[1] integerValue];
    
    [self.wednesdayBtn setTitle:self.weekArr[2] forState:0];
    self.wednesdayBtn.tag = [self.weekTag[2] integerValue];
    
    [self.thursdayBtn setTitle:self.weekArr[3] forState:0];
    self.thursdayBtn.tag = [self.weekTag[3] integerValue];
    
    [self.fridayBtn setTitle:self.weekArr[4] forState:0];
    self.fridayBtn.tag = [self.weekTag[4] integerValue];
    
    [self.saturdayBtn setTitle:self.weekArr[5] forState:0];
    self.saturdayBtn.tag = [self.weekTag[5] integerValue];
    
    [self.sundayBtn setTitle:self.weekArr[6] forState:0];
    self.sundayBtn.tag = [self.weekTag[6] integerValue];
}
- (IBAction)pressWeekBtn:(id)sender{
    NSArray *array = [self subviews];
    if (array) {
        for (UIView *view in array){
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button setTitleColor:[UIColor colorWithHexString:@"333333"] forState:0];
            }
        }
    }
    
    UIButton *btn = (UIButton *)sender;
    [btn setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.2];
    CGPoint pt = self.scrollView.center;
    pt.x = btn.center.x;
    self.scrollView.center = pt;
    [UIView commitAnimations];
    
    if ([_delegate respondsToSelector:@selector(weekChooseViewDelegateWithIndex:)]) {
        [_delegate weekChooseViewDelegateWithIndex:btn.tag];
    }
}

- (void)setWeekWithIndex:(NSInteger)index{
    self.weekIndex = index;
    NSArray *array = [self subviews];
    if (array) {
        for (UIView *view in array){
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (view.tag == self.weekIndex) {
                    [button setTitleColor:[UIColor colorWithHexString:@"249df3"] forState:UIControlStateNormal];
                    self.scrollViewConstraint.constant = -(Device_Width / 7);
                    [UIView animateWithDuration:0.2 animations:^{
                        [self layoutIfNeeded];
                    }];
                }else{
                    [button setTitleColor:[UIColor colorWithHexString:@"333333"] forState:0];
                }
            }
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


@end
