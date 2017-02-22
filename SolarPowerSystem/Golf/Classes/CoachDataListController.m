//
//  CoachDataListController.m
//  Golf
//
//  Created by 黄希望 on 15/6/10.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDataListController.h"
#import "MJRefresh.h"
#import "CoachDataTableViewCell.h"
#import "CoachDataHead.h"
#import "CoachNavHead.h"

@interface CoachDataListController ()<UITableViewDelegate,UITableViewDataSource>
{
    CoachNavHead *navHead;
    UIImageView *bgImageView;
}

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) CoachDataHead *head;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) CoachDataRpt *rptToday;
@property (nonatomic,strong) CoachDataRpt *rptMonth;
@property (nonatomic,strong) CoachDataRpt *rptAll;
@property (nonatomic,assign) int dataType;

@end

@implementation CoachDataListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)initization
{
    self.tableView.hidden = YES;
    __weak CoachDataListController *cklc = self;
    navHead = [[[NSBundle mainBundle] loadNibNamed:@"CoachNavHead" owner:self options:nil] lastObject];
    navHead.frame = CGRectMake(0, 0, Device_Width, 64);
    navHead.respEvent = ^(id obj){
        int index = [obj intValue];
        if (index == 4) {
            [super doLeftNavAction];
        }else{
            _dataType = index;
            [cklc getDataFromServer];
        }
    };
    [self.view addSubview:navHead];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, [self headHeight])];
    bgImageView.image = [UIImage imageNamed:@"bg_DataReport_blue"];
    [self.view insertSubview:bgImageView atIndex:0];
    
    self.head = [[[NSBundle mainBundle] loadNibNamed:@"CoachDataHead" owner:self options:nil] lastObject];
    _head.frame = CGRectMake(0, 0, Device_Width, [self headHeight]);

    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.dataType = 1; // 今天
    self.dataSource = [NSMutableArray array];
    
    [self getDataFromServer];
}

#pragma 获取数据
- (void)getDataFromServer
{
    if (_dataType == 1 && self.rptToday) {
        [self handleData];
        
    }else if (_dataType == 2 && self.rptMonth){
        [self handleData];
        
    }else if (_dataType == 3 && self.rptAll){
        [self handleData];
        
    }else if([LoginManager sharedManager].session.memberId > 0){
        [[ServiceManager serviceManagerWithDelegate:self] teachingCoachDataReport:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId dataType:_dataType];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag
{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_coach_data_report")) {
        self.tableView.hidden = NO;
        if (array.count > 0) {
            if (_dataType == 1) {
                self.rptToday = array[0];
            }else if (_dataType == 2){
                self.rptMonth = array[0];
            }else if (_dataType == 3){
                self.rptAll = array[0];
            }
            
            [self handleData];
        }
    }
}

- (void)handleData
{
    [self.dataSource removeAllObjects];
    if (_dataType == 1) {
        [self.dataSource addObjectsFromArray:_rptToday.dataList];
        _head.teachCount = _rptToday.teachCount;
        _head.orderTotal = _rptToday.orderAmount;
        _head.orderCount = _rptToday.orderCount;
    }else if (_dataType == 2){
        [self.dataSource addObjectsFromArray:_rptMonth.dataList];
        _head.teachCount = _rptMonth.teachCount;
        _head.orderTotal = _rptMonth.orderAmount;
        _head.orderCount = _rptMonth.orderCount;
    }else if (_dataType == 3){
        [self.dataSource addObjectsFromArray:_rptAll.dataList];
        _head.teachCount = _rptAll.teachCount;
        _head.orderTotal = _rptAll.orderAmount;
        _head.orderCount = _rptAll.orderCount;
    }
    [self.tableView reloadData];
    [_head loadData];
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count > 0 ? [self.dataSource count] : 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoneRecordListCell" forIndexPath:indexPath];
        return cell;
    }else{
        CoachDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachDataTableViewCell" forIndexPath:indexPath];
        cell.rpt = self.dataSource[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count == 0) {
        return Device_Height - [self headHeight];
    }
    return 101;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self headHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _head;
}

- (CGFloat)headHeight
{
    if (Device_Width == 320) {
        return 346;
        
    }else if (Device_Width == 375){
        return 400;
        
    }else if (Device_Width == 414){
        return 441;
        
    }else{
        return 400;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > [self headHeight]){
        navHead.bgView.alpha = 1;
        
    }else if (scrollView.contentOffset.y > [self headHeight]-150) {
        navHead.bgView.alpha = ([self headHeight]-150)/150.;
        
    } else{
        navHead.bgView.alpha = 0;
    }
    
    if (scrollView.contentOffset.y < 0) {
        bgImageView.transform = CGAffineTransformMakeScale(1 - (scrollView.contentOffset.y / 100),1 - (scrollView.contentOffset.y / 100));
        
    }else if (scrollView.contentOffset.y == 0){
        bgImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        bgImageView.height = [self headHeight];
        
    }else{
        bgImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        if ([self headHeight] > scrollView.contentOffset.y) {
            bgImageView.height = [self headHeight] - scrollView.contentOffset.y;
        }
    }
}

@end
