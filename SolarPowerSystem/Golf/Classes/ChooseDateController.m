//
//  ChooseDateController.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ChooseDateController.h"
#import "DayViewCell.h"
#import "DayViewHeadCell.h"
#import "CalendarClass.h"
#import "Day.h"
#import "YGBaseNavigationController.h"

@interface ChooseDateController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger _numberOfMonths;
    NSDate *_selectDate;
    BOOL _scrolling;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic,copy) void (^completion)(NSString *selectDate);
@property (nonatomic,strong) NSString *selectDateStr;
@property (nonatomic,strong) NSMutableArray *months;
@property (nonatomic,strong) NSDictionary *priceDic;
@property (nonatomic,assign) int clubId;

@end

@implementation ChooseDateController

+ (void)controllerWithTarget:(UIViewController*)target date:(NSString*)date clubId:(int)clubId completion:(void(^)(NSString *selectDate))completion{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BookTeetime" bundle:nil];
    ChooseDateController *vc = [sb instantiateViewControllerWithIdentifier:@"ChooseDateController"];
    vc.title = @"选择日期";
    vc.completion = completion;
    vc.selectDateStr = date;
    vc.clubId = clubId;
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    
    [target presentViewController:nav animated:YES completion:nil];
//    [vc initizationData];
    if (clubId > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ServerService clubPriceCalendar:clubId days:60 success:^(NSDictionary *dic) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    vc.priceDic = [NSDictionary dictionaryWithDictionary:dic];
                    [vc initizationData];
                });
            } failure:^(id error) {
            }];
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self leftButtonAction:@"取消"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    if (_months) {
//        self.tableView.hidden = NO;
//        self.loadingView.hidden = YES;
//    }else{
//    }
    self.tableView.hidden = YES;
    [self.loadingView startAnimating];
    [self initizationData];
}

- (void)initizationData{
    if (!self.months) {
        self.months = [NSMutableArray array];
    }
    NSString *day = [Utilities getDay1ByDate:[NSDate date]];
    _numberOfMonths = Equal(day, @"1") ? 2 : 3;
    [self handleData];
}

- (void)doLeftNavAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleData{
    NSDate *currentDate = [NSDate date];
    _selectDate = [Utilities getDateFromString:_selectDateStr];
    NSMutableArray *weeks = [NSMutableArray array];
    NSMutableArray *monthsArr = [NSMutableArray array];
    
    for (NSInteger m=0; m<_numberOfMonths; m++) {
        NSInteger firstWeekday = [CalendarClass weekdayOfFirstDayInDate:currentDate];
        NSInteger weekday = firstWeekday;
        NSInteger totalDaysOfMonth = [CalendarClass totalDaysInMonthOfDate:currentDate];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
        NSMutableArray *days = [NSMutableArray array];
        for (NSInteger i=0; i<42; i++) {
            if (i>=firstWeekday && i < totalDaysOfMonth + firstWeekday) {
                NSInteger index = i - firstWeekday + 1;
                NSDate *date = [self dateWithComponents:components Index:i firstWeekday:firstWeekday];
                Day *day = [self getDay:index date:date weekDay:weekday%7];
                weekday ++;
                [weeks addObject:day];
                if ((i+1)%7==0) {
                    [days addObject:[NSArray arrayWithArray:weeks]];
                    [weeks removeAllObjects];
                }
            }
            if (i==41 && weeks.count>0) {
                [days addObject:[NSArray arrayWithArray:weeks]];
                [weeks removeAllObjects];
            }
        }
        currentDate = [CalendarClass nextMonthDate:currentDate];
        [monthsArr addObject:days];
    }
    if (_months) {
        _months = monthsArr;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.loadingView removeFromSuperview];
            self.tableView.hidden = NO;
        });
    }
}

- (Day*)getDay:(NSInteger)dayNum date:(NSDate*)aDate weekDay:(NSInteger)weekDay{
    Day *day = [[Day alloc] init];
    day.day = dayNum;
    day.date = aDate;
    day.weekDay = weekDay;
    if ([aDate compare:_selectDate] == 0) {
        day.selected = YES;
    }
    if (_clubId > 0) {
        [self setDayPrice:day];
    }
    day.selectBlock = ^(id obj){
        NSDate *date = (NSDate*)obj;
        for (NSInteger i=0; i<_months.count; i++) {
            NSArray *arr = _months[i];
            for (NSInteger j=0; j<arr.count; j++) {
                NSArray *arr_ = arr[j];
                for (NSInteger k=0; k<arr_.count; k++) {
                    Day *day = arr_[k];
                    if ([day.date isEqualToDate:date]) {
                        day.selected = YES;
                    }else{
                        day.selected = NO;
                    }
                }
            }
        }
        [_tableView reloadData];
    };
    day.selectEndBlock = ^(id obj){
        NSDate *sd = (NSDate*)obj;
        _selectDateStr = [Utilities stringwithDate:sd];
        if (_completion) {
            _completion (_selectDateStr);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    return day;
}

- (void)setDayPrice:(Day*)day{
    if (!_priceDic || _priceDic.count == 0) {
        return ;
    }
    NSString *date = [Utilities stringwithDate:day.date];
    if (_priceDic[date]) {
        CalendarPriceModel *cpm = _priceDic[date];
        day.price = cpm.price;
        day.specialOffer = cpm.specialOffer;
        day.holidayName = cpm.holidayName;
    }else{
        day.price = -1;
    }
}

- (NSDate*)dateWithComponents:(NSDateComponents *)components Index:(NSInteger)index firstWeekday:(NSInteger)firstWeekday{
    [components setDay:index - firstWeekday + 1];
    NSCalendar *ca = [NSCalendar currentCalendar];
    [ca setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [ca dateFromComponents:components];
}

- (BOOL)tableView:(UITableView *)tableView hasPriceWithdays:(NSArray*)days indexPath:(NSIndexPath*)indexPath {
    BOOL hasPrice = NO;
    if (_clubId == 0) {
        return hasPrice;
    }
    for (Day *day in days) {
        if (day.price>=0) {
            hasPrice = YES;
            break;
        }
    }
    return hasPrice;
}

#pragma mark - UITableView - 相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_months count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_months[section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *days = _months[indexPath.section][indexPath.row];
    BOOL hasPrice = [self tableView:tableView hasPriceWithdays:days indexPath:indexPath];
    NSString *identifier = hasPrice ? @"DayViewCell_Price" : @"DayViewCell_None";
    DayViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.hasPrice = _clubId>0 ? YES : NO;
    cell.days = days;
    cell.scrolling = ^BOOL(void){
        return _scrolling;
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 76;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == _months.count-1 ? 20 : 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DayViewHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayViewHeadCell"];
    NSDate *date = [Utilities getDateWithDate:[NSDate date] withMonth:section];
    NSString *dateStr = [Utilities stringwithDate:date];
    cell.dateLabel.text = [Utilities getDateStringFromString:dateStr WithFormatter:@"yyyy年MM月"];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _scrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _scrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _scrolling = NO;
}

@end
