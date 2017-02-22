//
//  YGBalanceDetailsViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/11.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGBalanceDetailsViewCtrl.h"
#import "YGBalanceDetailsCell.h"
#import "YGMallOrderViewCtrl.h"
#import "ClubOrderViewController.h"
#import "TeachingOrderDetailViewController.h"
#import "YGThriftRequestManager.h"
#import "YGTeachBookingOrderViewCtrl.h"
#import "YGPackageOrderDetailViewCtr.h"

@interface YGBalanceDetailsViewCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *yunbiList;
@property (strong, nonatomic) NoResultView *noResultView;
@property (nonatomic) int pageNo;
@property (nonatomic) BOOL hasNOMore;
@property (nonatomic) int pageSize;
@end

@implementation YGBalanceDetailsViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeTableView];
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

- (void)initializeTableView {
    self.yunbiList = [NSMutableArray array];
    _pageNo = 0;
    self.pageSize = 20;
    [self getListData];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self getFirstPage];
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
    [self addNoResultView];
}

- (void)getFirstPage {
    _pageNo = 1;
    [[ServiceManager serviceManagerWithDelegate:self] accountConsumeList:[[LoginManager sharedManager] getSessionId] consumeType:self.accountType pageNo:_pageNo];
}

- (void)getListData {
    _pageNo ++;
    [[ServiceManager serviceManagerWithDelegate:self] accountConsumeList:[[LoginManager sharedManager] getSessionId] consumeType:self.accountType pageNo:_pageNo];
}

- (void)addNoResultView{
    self.noResultView = [NoResultView text:@"您还没有消费记录，点击去逛商城"  type:NoResultTypeList superView:self.view btnTaped:^{
        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:0 extro:@"" controller:self];
    } show:^{
    } hide:^{
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_yunbiList.count >= _pageSize) {
        return _yunbiList.count + 1;
    }
    return _yunbiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_yunbiList.count == indexPath.row && indexPath.row >= _pageSize) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_hasNOMore ? @"EndMessageCell" : @"LoadingCell" forIndexPath:indexPath];
        return cell;
    }
    YGBalanceDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGBalanceDetailsCell" forIndexPath:indexPath];
    
    ConsumeModel *model = [self.yunbiList objectAtIndex:indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_hasNOMore && indexPath.row == _yunbiList.count && indexPath.row >= _pageSize) {
        [self getListData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ConsumeModel *model = [self.yunbiList objectAtIndex:indexPath.row];
    
    if (model.relativeType == 1) { // 商品订单
        
        YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
        vc.orderId = model.relativeId;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (model.relativeType == 2){ // 球场订单
        NSString *title = [NSString stringWithFormat:@"订单%d",model.relativeId];
        ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
        clubOrder.orderId = model.relativeId;
        clubOrder.isBackUp = YES;
        [self pushViewController:clubOrder title:title hide:YES];
    }else if (model.relativeType == 3){ // 教学订单
        [self pushWithStoryboard:@"Teach" title:[NSString stringWithFormat:@"订单%d",model.relativeId] identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
            TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
            vc.orderId = model.relativeId;
            vc.blockReturn = ^(id data){
                [self.navigationController popToViewController:self animated:YES];
            };
        }];
    }else if(model.relativeType == 4){// 练习场订单
        [SVProgressHUD show];
        [YGRequest fetchTeachingOrderDetail:@(model.relativeId)
                                    success:^(BOOL suc, id object) {
                                        VirtualCourseOrderDetail *detail = object;
                                        if (suc) {
                                            [SVProgressHUD dismiss];
                                            YGTeachBookingOrderViewCtrl *vc = [YGTeachBookingOrderViewCtrl instanceFromStoryboard];
                                            vc.order = detail.order;
                                            [self.navigationController pushViewController:vc animated:YES];
                                        }else{
                                            [SVProgressHUD showErrorWithStatus:detail.err.errorMsg];
                                        }
                                    }
                                    failure:^(Error *err) {
                                        [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
                                    }];
    }else if (model.relativeType == 5){ //旅行套餐
        YGPackageOrderDetailViewCtr *vc = [YGPackageOrderDetailViewCtr instanceFromStoryboard];
        vc.orderId = model.relativeId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
//    [_refreshControl endRefreshing];
    [self.tableView.mj_header endRefreshing];
    if (array&&array.count>0) {
        if (_pageNo == 1) {
            self.hasNOMore = NO;
            [self.yunbiList removeAllObjects];
        }
        [self.yunbiList addObjectsFromArray:array];
    }else{
        self.hasNOMore = YES;
    }
    if (self.yunbiList.count>0) {
        [_noResultView show:NO];
        _tableView.hidden = NO;
    }else{
        [_noResultView show:YES];
        _tableView.hidden = YES;
    }
    [_tableView reloadData];
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeTableView];
}

@end
