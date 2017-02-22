//
//  CoachNoticeController.m
//  Golf
//
//  Created by 黄希望 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachNoticeController.h"
#import "MJRefresh.h"
#import "NoResultView.h"
#import "CoachNoticeCell.h"
#import "TeachingOrderDetailViewController.h"
#import "MyStudentDetailController.h"
#import "TeachInfoDetailTableViewController.h"

@interface CoachNoticeController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) BOOL isMore;

@end

@implementation CoachNoticeController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initization];
}

#pragma 初始化
- (void)initization{
    self.dataSource = [NSMutableArray array];
    self.page = 1;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    
    __weak CoachNoticeController *weakSelf = self;
    noResultView = [NoResultView text:@"暂无通知" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
//    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        weakSelf.page = 1;
//        weakSelf.isMore = YES;
//        weakSelf.tableView.mj_footer.hidden = NO;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];
//    
//    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        weakSelf.page ++;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeHeader) {
            self.page = 1;
            self.isMore = YES;
            [self loadDataPageNo:self.page];
        }else if (type == YGRefreshTypeFooter){
            self.page ++;
            [self loadDataPageNo:self.page];
        }
    }];
    
    [self loadDataPageNo:self.page];
}

#pragma 获取数据
- (void)loadDataPageNo:(int)page{
    if (self.isMore && [LoginManager sharedManager].session.memberId > 0) {
        [[ServiceManager serviceManagerWithDelegate:self] teachingCoachMessageList:[LoginManager sharedManager].session.memberId  pageNo:page pageSize:20];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_coach_message_list")) {
            
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        [self.dataSource addObjectsFromArray:array];
        if (array.count > 0) {
            self.isMore = YES;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.isMore = NO;
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        [noResultView show:self.dataSource.count == 0];
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
        CoachNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachNoticeCell" forIndexPath:indexPath];
        CoachNoticeModel *cnm = self.dataSource[indexPath.row];
        cell.cnm = cnm;
        cell.blockReturn = ^(id obj){
            NSInteger type = [obj integerValue];
            if (type == 0) {
                MyStudentDetailController *msd = [MyStudentDetailController instanceFromStoryboard];
                msd.memberId = cnm.memberId;
                [self pushViewController:msd title:@"学员详情" hide:YES];
            }else if (type == 1){
                TeachingOrderDetailViewController *vc = [TeachingOrderDetailViewController instanceFromStoryboard];
                vc.orderId = cnm.relativeId;
                vc.isCoach = YES;
                ygweakify(self);
                vc.blockReturn = ^(id data){
                    ygstrongify(self);
                    [self.navigationController popToViewController:self animated:YES];
                };
                [self pushViewController:vc title:[NSString stringWithFormat:@"订单%d",cnm.relativeId] hide:YES];
            }else{
                TeachInfoDetailTableViewController *vc = [TeachInfoDetailTableViewController instanceFromStoryboard];
                vc.reservationId = cnm.relativeId;
                vc.coachId = [LoginManager sharedManager].session.memberId;
                ygweakify(self);
                vc.blockCanceled = ^(id data){
                    ygstrongify(self);
                    [self.tableView.mj_header beginRefreshing];
                };
            }
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count) {
        return 44;
    }else{
        CoachNoticeModel *cnm = self.dataSource[indexPath.row];
        if (cnm.msgType == 4) { // 评论
            CGSize sz = [Utilities getSize:cnm.valueOne withFont:[UIFont systemFontOfSize:16.0] withWidth:Device_Width - 75];
            return sz.height+85;
        }
        return 130;
    }
}

@end
