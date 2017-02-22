//
//  YGOrdersRecentListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrdersRecentListViewCtrl.h"
#import "YGOrderCell.h"
#import "YGOrderManager.h"
#import "YGOrderHandler.h"

@interface YGOrdersRecentListViewCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<id<YGOrderModel>> *orderList;
@property (strong, nonatomic) YGOrderManager *manager;
@end

@implementation YGOrdersRecentListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    [self registerOrderType:YGOrderTypeCourse];
    [self registerOrderType:YGOrderTypeMall];
    [self registerOrderType:YGOrderTypeTeaching];
    [self registerOrderType:YGOrderTypeTeachBooking];

    self.tableView.contentInset = UIEdgeInsetsMake(self.edgeInsetsTop, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.edgeInsetsTop, 0, 0, 0);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = [YGOrderCell estimatedRowHeight];
    self.tableView.sectionHeaderHeight = 5.f;
    self.tableView.sectionFooterHeight = 5.f;
    self.tableView.estimatedSectionHeaderHeight = 5.f;
    self.tableView.estimatedSectionFooterHeight = 5.f;
    
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self loadData:type==YGRefreshTypeFooter];
    }];
}

- (void)registerOrderType:(YGOrderType)type
{
    Class cls = orderCellClassOfOrderType(type);
    if (cls && [cls isSubclassOfClass:[YGOrderCell class]]) {
        [cls registerInTableView:self.tableView];
    }
}

- (void)reload:(YGOrderManager *)manager isMore:(BOOL)isMore
{
    self.manager = manager;
    self.orderList = manager.orderList;
    [self.tableView reloadData];
    
    if (isMore) {
        if (manager.noMore) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
    }else{
        [self.tableView.mj_header endRefreshing];
    }
}

- (void)loadData:(BOOL)isMore
{
    if (isMore) {
        [self.manager loadMore];
    }else{
        [self.manager reload];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.orderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<YGOrderModel> order = self.orderList[indexPath.section];
    YGOrderType type = typeOfOrder(order);
    NSString *identifier = orderCellIdentifierOfOrderType(type);
    __kindof YGOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.inManagerList = YES;
    [cell configureWithOrder:order];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id order = self.orderList[indexPath.section];
    [YGOrderHandler showOrderDetail:order fromNaviViewCtrl:self.navigationController];
}

@end
