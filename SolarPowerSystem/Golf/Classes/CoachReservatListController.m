//
//  CoachReservatListController.m
//  Golf
//
//  Created by 黄希望 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachReservatListController.h"
#import "MJRefresh.h"
#import "CoachReservateListCell.h"
#import "MemberReservationModel.h"
#import "OrderClickView.h"
#import "TeachInfoDetailTableViewController.h"
#import "CCAlertView.h"
#import "CoachReservateSearchController.h"
#import "BaiduMobStat.h"

@interface CoachReservatListController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) IBOutletCollection(OrderClickView) NSArray *clickViews;
@property (nonatomic,weak) IBOutlet UIView *lineView;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) BOOL isMore;
@property (nonatomic,assign) int reservateStatus;
@property (nonatomic,assign) BOOL isScrolling;

@end

@implementation CoachReservatListController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initization];
    
    __weak CoachReservatListController *weakSelf = self;
    noResultView = [NoResultView text:@"当前状态暂无预约记录" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
}

- (void)initization{

    self.dataSource = [NSMutableArray array];
    self.page = 1;
    self.reservateStatus = 0;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weak CoachReservatListController *weakSelf = self;
    
//    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        weakSelf.page = 1;
//        weakSelf.isMore = YES;
//        weakSelf.tableView.mj_footer.hidden = NO;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        self.page = 1;
        self.isMore = YES;
//        self.tableView.mj_footer.hidden = NO;
        if (type == YGRefreshTypeFooter) {
            self.page ++;
            [self loadDataPageNo:self.page];
        }else if (type == YGRefreshTypeHeader){
            [self loadDataPageNo:self.page];
        }
    }];
    
//    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        weakSelf.page ++;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];
    
    if (!_isSearch) {
        [self rightButtonActionWithImg:@"search"];
        // 设置头部界面状态
        for (OrderClickView *ocv in _clickViews) {
            ocv.respEvent = ^(id obj){
                if (weakSelf.isScrolling) {
                    return ;
                }
                NSInteger index = [obj integerValue] - 1;
                [weakSelf loadWithIndex:index];
            };
        }
        if (self.selectedIndex > 0) {
            [self loadWithIndex:self.selectedIndex];
        }else{
            [self loadDataPageNo:self.page];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_isSearch) {
        if (self.dataSource.count > 0) {
            [noResultView show:NO];
        }else{
            if (!self.isMore) {
                [noResultView show:YES];
            }else{
                [noResultView show:NO];
            }
        }
    }
}


- (void)loadWithIndex:(NSInteger)index{
    self.selectedIndex = index;
    self.reservateStatus = [self statusWithIndex:index];
    
    [self move];
    
    self.page = 1;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    [self loadDataPageNo:self.page];
}

#pragma mark - move

- (void)move{
    CGFloat x = 0;
    for (OrderClickView *ocv in _clickViews) {
        if (ocv.tag == self.selectedIndex + 1) {
            ocv.isSelected = YES;
            x = ocv.yg_x;
        }else{
            ocv.isSelected = NO;
        }
    }
        
    for (NSLayoutConstraint *lct in _lineView.superview.constraints) {
        if (lct.firstAttribute == NSLayoutAttributeLeading && lct.firstItem == _lineView) {
            ygweakify(self);
            [UIView animateWithDuration:0.3 animations:^{
                ygstrongify(self);
                lct.constant = x;
                [self.lineView.superview layoutIfNeeded];
            }];
            break;
        }
    }
    
    if (self.selectedIndex==0) {
        [_scrollView setContentOffset:CGPointMake(self.selectedIndex*71, 0) animated:YES];
    }else{
        OrderClickView *ocv = _clickViews[self.selectedIndex];
        CGFloat offsetX = _scrollView.contentOffset.x;
        CGFloat gabx = ocv.center.x-offsetX;
        
        // 点击左侧向右滚动
        if (gabx > 0 && gabx < 107) {
            [_scrollView setContentOffset:CGPointMake((self.selectedIndex-1)*71, 0) animated:YES];
        }
        
        // 点击右侧向左滚动
        if (gabx > Device_Width-107 && gabx < Device_Width) {
            int a = (int)offsetX/71;
            CGFloat ptx = (a+1)*71;
            ptx = MIN(ptx, _scrollView.contentSize.width-Device_Width);
            [_scrollView setContentOffset:CGPointMake(ptx, 0) animated:YES];
        }
    }
}

#pragma 获取数据
- (void)loadDataPageNo:(int)page{
    if (self.page == 1) {
        self.isMore = YES;
        self.tableView.mj_footer.hidden = NO;
    }
    
    if (self.isMore && [LoginManager sharedManager].session.memberId > 0) {
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberByReservationStatus:self.reservateStatus pageNo:page pageSize:20 sessionId:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId memberId:0 keyword:_term];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_member_reservation_list")) {
        if (array.count > 0) {
            MemberReservationModel *mrm = [array firstObject];
            if (self.page == 1) {
                [self.dataSource removeAllObjects];
            }
            [self.dataSource addObjectsFromArray:mrm.dataList];
            if (mrm.dataList.count > 0) {
                self.isMore = YES;
                self.tableView.mj_footer.hidden = NO;
            }else{
                self.isMore = NO;
                self.tableView.mj_footer.hidden = YES;
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            if (self.dataSource.count > 0) {
                [noResultView show:NO];
            }else{
                [noResultView show:YES];
            }
        }
    }
}

#pragma mark - 预约状态

- (int)statusWithIndex:(NSInteger)index{
    if (index == 0) {
        return 0;
    }else if (index == 1){
        return 1;
    }else if (index == 2){
        return 5;
    }else if (index == 3){
        return 6;
    }else if (index == 4){
        return 2;
    }else if (index == 5){
        return 4;
    }else{
        return 3;
    }
}

#pragma mark - UITableView delegate && dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isMore ? [self.dataSource count] : [self.dataSource count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FinishLoadCell" forIndexPath:indexPath];
        return cell;
    }else{
        CoachReservateListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachReservateListCell" forIndexPath:indexPath];
        ReservationModel *rm = self.dataSource[indexPath.row];
        cell.rm = rm;
        
        ygweakify(self);
        ygweakify(rm);
        cell.blockReturn = ^(id obj){
            ygstrongify(self);
            ygstrongify(rm);
            if ([LoginManager sharedManager].loginState && [LoginManager sharedManager].session.memberId > 0) {
                CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"确认已完成该教学？"];
                [alert addButtonWithTitle:@"取消" block:nil];
                [alert addButtonWithTitle:@"确定完成" block:^{
                    [[BaiduMobStat defaultStat] logEvent:@"btnReservationListComplete" eventLabel:@"预约列表完成教学按钮"];
                    [MobClick event:@"btnReservationListComplete" label:@"预约列表完成教学按钮"];
                    [[ServiceManager serviceManagerInstance] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:rm.reservationId opteraton:1 periodId:rm.periodId callBack:^(BOOL boolen) {
                        if (boolen) {
                            [SVProgressHUD showInfoWithStatus:@"确认成功"];
                            if (self.selectedIndex == 0) {
                                rm.reservationStatus = 6;
                            }else{
                                if (indexPath.row < self.dataSource.count) {
                                    [self.dataSource removeObjectAtIndex:indexPath.row];
                                }
                            }
                            [self.tableView reloadData];
                        }
                    }];
                }];
                [alert show];
            }
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count) {
        return 44;
    }else{
        return 124;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count > 0 && indexPath.row < self.dataSource.count) {
        ReservationModel *rm = self.dataSource[indexPath.row];
        TeachInfoDetailTableViewController *vc = [TeachInfoDetailTableViewController instanceFromStoryboard];
        [self pushViewController:vc title:@"预约详情" hide:YES];
        vc.reservationId = rm.reservationId;
        vc.coachId = [LoginManager sharedManager].session.memberId;
        ygweakify(self);
        ygweakify(rm);
        vc.blockCanceled = ^(id data){
            ygstrongify(self);
            ygstrongify(rm);
            if (_selectedIndex == 0) {
                rm.reservationStatus = [data intValue];
            }else{
                if (indexPath.row < self.dataSource.count) {
                    [self.dataSource removeObjectAtIndex:indexPath.row];
                }
            }
            [self.tableView reloadData];
        };
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count == indexPath.row && self.isMore) {
        self.page ++;
        [self loadDataPageNo:self.page];
    }
}

- (void)doRightNavAction{
    [[BaiduMobStat defaultStat] logEvent:@"btnSearchNavButton" eventLabel:@"导航条搜索按钮点击"];
    [MobClick event:@"btnSearchNavButton" label:@"导航条搜索按钮点击"];
    CoachReservateSearchController *searchController = [CoachReservateSearchController instanceFromStoryboard];
    [self pushViewController:searchController title:@"" hide:YES];
    searchController.isSearch = YES;
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _isScrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _isScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        _isScrolling = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    _isScrolling = NO;
}

@end
