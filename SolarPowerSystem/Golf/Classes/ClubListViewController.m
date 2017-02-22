//
//  ClubListViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubListViewController.h"
#import "ClubListCell.h"
#import "SelectedCitysController.h"
#import "ChooseDateController.h"
#import "ChooseTimeController.h"
#import "ClubMainViewController.h"
#import "ClubHomeController.h"
#import "YGMapViewCtrl.h"
#import "SimpleCityModel.h"
#import "CalendarClass.h"

#import "YGMapViewCtrl.h"

@interface ClubListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    BOOL _didSelectDateTime;
    BOOL _isDateTimePickerDisappear;
    CGFloat _lastContentOffsetY;
    NoResultView *_noResultView;
    BOOL _isRank;
    // 正在滑出
    BOOL _isShowAnimation;
    // 正在滚动
    BOOL _isScrolling;
    
    NSInteger _currentIndex;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UIView *pickerDateTimeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerHeightConstraint;
@property (nonatomic,weak) IBOutlet UIButton *dateButton;
@property (nonatomic,weak) IBOutlet UIButton *timeButton;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,strong) UIButton *navCenterButton;
@property (nonatomic,weak) IBOutlet UIView *rankView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rankViewHeightConstraint;
@property (nonatomic,weak) IBOutlet UIView *lineView;
@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *btns;

@property (nonatomic,strong) NSMutableArray *clubArr;
@property (nonatomic,strong) NSMutableArray *defaultClubArr;

@end

@implementation ClubListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"球场列表";
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top =  64.f + self.pickerHeightConstraint.constant + self.rankViewHeightConstraint.constant;
    self.tableView.contentInset = insets;
    
    [self initizationData];
}

- (void)doLeftNavAction{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count>=2) {
        BaseNavController *vc = viewControllers[viewControllers.count-2];
        if ([vc isKindOfClass:[SelectedCitysController class]]) {
            for (BaseNavController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[ClubHomeController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                    return;
                }
            }
        }
    }
    [self back];
}

// 初始化
- (void) initizationData{
    [self rightNavButtonImg:@"ic_map"];

    __weak typeof(self) ws = self;
    _noResultView = [NoResultView text:@"没有搜索结果" type:NoResultTypeSearch superView:self.view show:^{
        ws.tableView.hidden = YES;
    } hide:^{
        ws.tableView.hidden = NO;
    }];
    
    
    self.clubArr = [NSMutableArray array];
    self.defaultClubArr = [NSMutableArray array];
    
    _didSelectDateTime = NO;
    if (_cm.date.length*_cm.time.length>0) {
        _didSelectDateTime = YES;
    }
    
    [self setTwoButtonTitles];
    [self createNavCenterBtn:YES];
    
    _cm.latitude = [LoginManager sharedManager].currLatitude;
    _cm.longitude = [LoginManager sharedManager].currLongitude;
    _currentIndex = 1;
    
    _activityView.hidden = NO;
    [[ServiceManager serviceManagerWithDelegate:self] searchClubWithCondition:_cm withPage:0 withPageSize:0 withVersion:@"3.0"];
}

// 导航栏中间的按钮
- (void)createNavCenterBtn:(BOOL)showDateTimePickView{
    if (self.navCenterButton == nil) {
        self.navCenterButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _navCenterButton.frame = CGRectMake(0, 0, 180, 44);
        [_navCenterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_navCenterButton.titleLabel setNumberOfLines:0];
        [_navCenterButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_navCenterButton addTarget:self action:@selector(centerNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSMutableAttributedString *attributTitle = nil;
    if (showDateTimePickView) {
        if (_keyword.length>0) {
            attributTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",_keyword] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:MainTintColor}];
        }else{
            attributTitle = [[NSMutableAttributedString alloc] initWithString:_cm.cityName
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:MainHighlightColor}];
            [attributTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@" ▾" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#b8b8b8"]}]];
        }
    }else{
        attributTitle = [[NSMutableAttributedString alloc] initWithString:[self navCenterButtonTitle] attributes:@{NSForegroundColorAttributeName:MainTintColor,NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    }
    [_navCenterButton setAttributedTitle:attributTitle forState:UIControlStateNormal];
    [self.navigationItem setTitleView:_navCenterButton];
}

// 设置日期／时间按钮的title
- (void)setTwoButtonTitles{
    [self dateButtonTitle];
    [self timeButtonTitle];
}

- (NSString*)navCenterButtonTitle{
    NSString *dateStr = [Utilities getDateStringFromString:_cm.date WithFormatter:@"MM月dd日"];
    NSString *weekStr = [Utilities getWeekDayByDate:[Utilities getDateFromString:_cm.date]];
    return [NSString stringWithFormat:@"%@\n%@ %@ %@",_keyword.length>0?_keyword:_cm.cityName,dateStr,weekStr,_cm.time];
}

- (void)dateButtonTitle{
    NSString *dateStr = [Utilities getDateStringFromString:_cm.date WithFormatter:@"MM月dd日"];
    NSString *weekStr = [@" " stringByAppendingString:[Utilities getWeekDayByDate:[Utilities getDateFromString:_cm.date]]];
    if (_cm.date && dateStr && weekStr) {
        NSMutableAttributedString *mas_date = [[NSMutableAttributedString alloc] initWithString:dateStr];
        [mas_date addAttributes:@{NSForegroundColorAttributeName:MainHighlightColor,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, dateStr.length)];
        NSMutableAttributedString *mas_week = [[NSMutableAttributedString alloc] initWithString:weekStr];
        [mas_week addAttributes:@{NSForegroundColorAttributeName:MainHighlightColor,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, mas_week.length)];
        [mas_week appendAttributedString:[[NSAttributedString alloc] initWithString:@" ▾" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#b8b8b8"],NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
        [mas_date appendAttributedString:mas_week];
        [_dateButton setAttributedTitle:mas_date forState:UIControlStateNormal];
    }
}

- (void)timeButtonTitle{
    NSMutableAttributedString *mas_time = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",_cm.time]];
    [mas_time addAttributes:@{NSForegroundColorAttributeName:MainHighlightColor,NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, mas_time.length)];
    [mas_time appendAttributedString:[[NSAttributedString alloc] initWithString:@" ▾" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#b8b8b8"],NSFontAttributeName:[UIFont systemFontOfSize:11]}]];
    [_timeButton setAttributedTitle:mas_time forState:UIControlStateNormal];
}

- (void)centerNavButtonAction{
    if (_isDateTimePickerDisappear) {
        _isDateTimePickerDisappear = NO;
        _isShowAnimation = YES;
        [self dateTimePickerViewShow:YES];
    }else{
        if (_keyword.length == 0) {
            [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"SelectedCitysController" completion:^(BaseNavController *controller) {
                SelectedCitysController *vc = (SelectedCitysController*)controller;
                vc.cm = [_cm copy];
                vc.chooseBlock = ^(id data){
                    SimpleCityModel *scm = (SimpleCityModel *)data;
                    _cm.cityId = scm.cityId;
                    _cm.provinceId = scm.provinceId;
                    _cm.cityName = scm.name;
                    [self createNavCenterBtn:YES];
                    _currentIndex = 1;
                    _activityView.hidden = NO;
                    [[ServiceManager serviceManagerWithDelegate:self] searchClubWithCondition:_cm withPage:0 withPageSize:0 withVersion:@"3.0"];
                };
            }];
        }
    }
}


- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (_activityView) {
        [_activityView removeFromSuperview];
    }
    if (serviceManager.success) {
        NSArray *clubArray = [NSArray arrayWithArray:data];
        [_clubArr removeAllObjects];
        [_defaultClubArr removeAllObjects];
        [_clubArr addObjectsFromArray:clubArray];
        [_defaultClubArr addObjectsFromArray:clubArray];
        
        if (_cm.cityId == 0 && _cm.provinceId == 0 && Equal(_cm.cityName, @"当前位置")) {
            [self rankWithIndex:3];
        }else{
            [self rankWithIndex:_currentIndex];
        }
        
        [_tableView reloadData];
        
        CGFloat offsetY = 64.f + self.rankViewHeightConstraint.constant + self.pickerHeightConstraint.constant;
        [self.tableView setContentOffset:CGPointMake(0, -offsetY) animated:YES];
        if (_noResultView) {
            [_noResultView show:_clubArr.count>0?NO:YES];
        }
    }
}

#pragma mark - UITableView delegate && dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_clubArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClubListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubListCell" forIndexPath:indexPath];
    cell.cm = _cm;
    if (indexPath.row < _clubArr.count) {
        cell.club = _clubArr[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClubModel *cm = _clubArr[indexPath.row];
    [self toChooseTeetimeView:cm];
}

- (void)toChooseTeetimeView: (ClubModel *)model {
    ConditionModel *nextCondition = [_cm copy];
    nextCondition.clubId = model.clubId;
    nextCondition.clubName = model.clubName;
    nextCondition.address = model.address;
    nextCondition.price = model.minPrice;
    nextCondition.payType = model.payType;
    
    ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
    vc.cm = nextCondition;
    vc.agentId = -1;
    [self.navigationController pushViewController:vc animated:YES];
}

// 排序按钮
- (IBAction)rankButtonAction:(UIButton*)sender{
    _isRank = YES;
    
    CGFloat offsetY = 64.f + self.rankViewHeightConstraint.constant + self.pickerHeightConstraint.constant;
    [self.tableView setContentOffset:CGPointMake(0, -offsetY) animated:YES];
    
    for (NSLayoutConstraint *lc in _rankView.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeCenterX) {
            lc.constant = sender.center.x-sender.width/2.;
            [UIView animateWithDuration:0.4 animations:^{
                [_rankView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isRank = NO;
            }];
            break;
        }
    }
    
    for (UIButton *btn in _btns) {
        btn.selected = NO;
    }
    sender.selected = YES;
    _currentIndex = sender.tag;
    
    [self rank:sender.tag];
}

- (void)rankWithIndex:(NSInteger)index{
    _currentIndex = index;
    _isRank = YES;
    
    CGFloat offsetY = 64.f + self.rankViewHeightConstraint.constant + self.pickerHeightConstraint.constant;
    [self.tableView setContentOffset:CGPointMake(0, -offsetY) animated:YES];
    
    UIButton *btn = nil;
    for (UIButton *button in _btns) {
        if (index == button.tag) {
            btn = button;
        }
    }
    
    for (NSLayoutConstraint *lc in _rankView.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeCenterX) {
            lc.constant = btn.center.x-btn.width/2.;
            [UIView animateWithDuration:0.4 animations:^{
                [_rankView layoutIfNeeded];
            } completion:^(BOOL finished) {
                _isRank = NO;
            }];
            break;
        }
    }
    
    for (UIButton *btn in _btns) {
        btn.selected = NO;
    }
    btn.selected = YES;
    
    [self rank:index];
}

- (void)rank:(NSInteger)index{
    [_clubArr removeAllObjects];
    if (index == 1) {
        [_clubArr addObjectsFromArray:_defaultClubArr];
    }else{
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_defaultClubArr];
        for (int i=0; i<mutableArray.count; i++) {
            for (int j=i+1; j<mutableArray.count; j++) {
                ClubModel *c1 = mutableArray[i];
                ClubModel *c2 = mutableArray[j];
                if (index == 2) {
                    if (c1.minPrice > c2.minPrice) {
                        [self swapObject:mutableArray pos1:i pos2:j];
                    }
                }else{
                    if ([c1.remote floatValue] > [c2.remote floatValue]) {
                        [self swapObject:mutableArray pos1:i pos2:j];
                    }
                }
            }
        }
        [_clubArr addObjectsFromArray:mutableArray];
    }
    [_tableView reloadData];
}

- (void)swapObject: (NSMutableArray *)mutableArray pos1:(NSInteger) i pos2:(NSInteger) j {
    ClubModel *model1 = [mutableArray objectAtIndex:i];
    ClubModel *model2 = [mutableArray objectAtIndex:j];
    [mutableArray replaceObjectAtIndex:i withObject:model2];
    [mutableArray replaceObjectAtIndex:j withObject:model1];
}

// 选择日期
- (IBAction)dateButtonAciton:(id)sender{
    [ChooseDateController controllerWithTarget:self date:_cm.date clubId:0 completion:^(NSString *selectDate) {
        if (selectDate) {
            NSString *dateString = [NSString stringWithFormat:@"%@ %@:00",selectDate,_cm.time];
            NSDate *date = [Utilities getDateFromString:dateString WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *currentDate = [CalendarClass dateForStandardTodayAll];
            if ([date timeIntervalSinceDate:currentDate]<0) {
                NSString *hour = [Utilities getHourByDate:currentDate];
                NSString *minute = [Utilities getMinuteByDate:currentDate];
                NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
                if ([minute integerValue]>0&&[minute integerValue]<30) {
                    minute = @"30";
                    time = [NSString stringWithFormat:@"%@:%@",hour,minute];
                }else if ([minute integerValue] > 30){
                    currentDate = [currentDate dateByAddingTimeInterval:1800];//加半个小时
                    hour = [Utilities getHourByDate:currentDate];
                    time = [NSString stringWithFormat:@"%@:00",hour];
                }
                NSArray *arr = [time componentsSeparatedByString:@":"];
                if ([arr[0] integerValue]*60+[arr[1] integerValue]>1230) {
                    [SVProgressHUD showInfoWithStatus:@"您选择的开球日期或时间已过，请重新选择时间预订"];
                    return ;
                }else{
                    _cm.time = time;
                }
            }
            _cm.date = selectDate;
            [self setTwoButtonTitles];
            [[ServiceManager serviceManagerWithDelegate:self] searchClubWithCondition:_cm withPage:0 withPageSize:0 withVersion:@"3.0"];
        }
    }];
}

// 选择时间
- (IBAction)timeButtonAction:(id)sender{
    [ChooseTimeController controllerWithTarget:self date:_cm.date time:_cm.time clubId:0 completion:^(NSString *selectTime) {
        if (selectTime) {
            _cm.time = selectTime;
            [self timeButtonTitle];
            [[ServiceManager serviceManagerWithDelegate:self] searchClubWithCondition:_cm withPage:0 withPageSize:0 withVersion:@"3.0"];
        }
    }];
}

#pragma mark - scroll
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (fabs(scrollView.contentOffset.y-_lastContentOffsetY) > 5) {
        _lastContentOffsetY = scrollView.contentOffset.y;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _isScrolling = YES;
    if (_isRank) {
        return;
    }
    
    if (scrollView.contentOffset.y - _lastContentOffsetY > 10) {// 收起来
        if (!_isDateTimePickerDisappear && !_isShowAnimation) {
            _isDateTimePickerDisappear = YES;
            [self dateTimePickerViewShow:!_isDateTimePickerDisappear];
        }
    }else if (scrollView.contentOffset.y-_lastContentOffsetY < -10) {// 拉出来
        if (_isDateTimePickerDisappear && !_isShowAnimation) {
            _isDateTimePickerDisappear = NO;
            [self dateTimePickerViewShow:!_isDateTimePickerDisappear];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _isScrolling = NO;
    _isShowAnimation = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _isScrolling = NO;
    _isShowAnimation = NO;
}

// 控制显示或隐藏日期时间控件
- (void)dateTimePickerViewShow:(BOOL)show{
    if (_isRank) {
        return;
    }
    
    CGFloat constant = show ? 50 : 0;
//    CGFloat alpha = show?1.f:0.f;
    
    self.pickerHeightConstraint.constant = constant;
    [UIView animateWithDuration:.5f animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
//        self.pickerDateTimeView.alpha = alpha;
        if (!_isScrolling) {
            _isShowAnimation = NO;
        }
    }];
    
    [self createNavCenterBtn:show];
//    _navCenterButton.alpha = 0.1;
//    [UIView animateWithDuration:0.2 animations:^{
//        _navCenterButton.alpha = 1;
//    }];
}

- (void)doRightNavAction
{
    YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
    vc.clubList = self.defaultClubArr;
    [vc setDidSelectedClub:^(ClubModel *club) {
        [self didSelectedClubOnMap:club];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectedClubOnMap:(ClubModel *)cmodel
{
    ConditionModel *nextCondition = [_cm copy];
    nextCondition.clubId = cmodel.clubId;
    nextCondition.clubName = cmodel.clubName;
    nextCondition.address = cmodel.address;
    nextCondition.price = cmodel.minPrice;
    nextCondition.payType = cmodel.payType;
    
    ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
    vc.cm = nextCondition;
    vc.agentId = -1;
    [[GolfAppDelegate shareAppDelegate].currentController.navigationController pushViewController:vc animated:YES];
}

@end
