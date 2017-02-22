//
//  ChooseTimeController.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ChooseTimeController.h"
#import "TimeViewCell.h"
#import "Time.h"
#import "TimeTableModel.h"
#import "YGBaseNavigationController.h"

@interface ChooseTimeController ()<UITableViewDelegate,UITableViewDataSource>{
    NSDate *_selectDate;
    BOOL _scrolling;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,copy) void (^completion)(NSString *selectDate);
@property (nonatomic,strong) NSString *selectDateStr;
@property (nonatomic,strong) NSString *selectTime;
@property (nonatomic,assign) int clubId;
@property (nonatomic,strong) NSDictionary *timetableDic;

@property (nonatomic,strong) NSMutableArray *timeArr;

@end

@implementation ChooseTimeController

+ (void)controllerWithTarget:(UIViewController*)target
                        date:(NSString*)date
                        time:(NSString*)time
                      clubId:(int)clubId
                  completion:(void(^)(NSString *selectTime))completion{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BookTeetime" bundle:nil];
    ChooseTimeController *vc = [sb instantiateViewControllerWithIdentifier:@"ChooseTimeController"];
    vc.title = @"选择时间";
    vc.completion = completion;
    vc.selectDateStr = date;
    vc.selectTime = time;
    vc.clubId = clubId;
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    
    if (clubId > 0) {
        [ServerService clubPriceTimetable:clubId date:date success:^(NSDictionary *dic) {
            [target presentViewController:nav animated:YES completion:nil];
            vc.timetableDic = [NSDictionary dictionaryWithDictionary:dic];
            [vc initizationData];
        } failure:^(id error) {
        }];
    }else{
        [target presentViewController:nav animated:YES completion:nil];
        [vc initizationData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self leftButtonAction:@"取消"];
}

- (void)doLeftNavAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initizationData{
    _selectDate = [Utilities getDateFromString:_selectDateStr];
    self.timeArr = [NSMutableArray array];
    NSMutableArray *teetimes = [NSMutableArray array];
    NSMutableArray *rowTeetimes = [NSMutableArray array];
    for (NSInteger i=5; i<=20; i++) {
        [self addTeetimes:teetimes index:i];
        if ((i-4)%2==0) {
            [rowTeetimes addObject:[NSArray arrayWithArray:teetimes]];
            [teetimes removeAllObjects];
        }
        if (i==12 || i==20) {
            [_timeArr addObject:[NSArray arrayWithArray:rowTeetimes]];
            [rowTeetimes removeAllObjects];
        }
    }
    [_tableView reloadData];
}

- (void)addTeetimes:(NSMutableArray*)arr index:(NSInteger)index{
    [arr addObject:[self timeWithIndex:index type:1]];
    [arr addObject:[self timeWithIndex:index type:2]];
}

- (Time*)timeWithIndex:(NSInteger)index type:(NSInteger)type{
    NSString *tee = nil;
    if (type == 1) {
        tee = [self teetime00WithIndex:index];
    }else{
        tee = [self teetime30WithIndex:index];
    }
    Time *time = [[Time alloc] init];
    time.teetime = tee;
    time.price = ((TimeTableModel*)_timetableDic[tee]).minPrice;
    time.specialOffer = ((TimeTableModel*)_timetableDic[tee]).specialOffer;
    time.date = _selectDate;
    if (Equal(_selectTime, tee)) {
        time.selected = YES;
    }
    time.selectBlock = ^(id obj){
        NSString *teetime = (NSString*)obj;
        for (NSInteger a=0; a<_timeArr.count; a++) {
            NSArray *arr = _timeArr[a];
            for (NSInteger b=0; b<arr.count; b++) {
                NSArray *arr_ = arr[b];
                for (NSInteger c=0; c<arr_.count; c++) {
                    Time *t = arr_[c];
                    if (Equal(t.teetime, teetime)) {
                        t.selected = YES;
                    }else{
                        t.selected = NO;
                    }
                }
            }
        }
        [_tableView reloadData];
    };
    time.selectEndBlock = ^(id obj){
        _selectTime = (NSString*)obj;
        if (_completion) {
            _completion (_selectTime);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    return time;
}

- (NSString*)teetime00WithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%02tu:00",index];
}

- (NSString*)teetime30WithIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%02tu:30",index];
}

#pragma mark - UITableView - 相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_timeArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_timeArr[section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = _clubId>0 ? @"TimeViewCell_Price" : @"TimeViewCell_None";
    TimeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.hasPrice = _clubId>0 ? YES : NO;
    cell.times = _timeArr[indexPath.section][indexPath.row];
    cell.scrolling = ^BOOL(void){
        return _scrolling;
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TimeViewHeadCell"];
    cell.textLabel.text = section == 0 ? @"上午" : @"下午";
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _scrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _scrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _scrolling = NO;
}

@end
