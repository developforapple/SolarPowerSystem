//
//  YGOrderListViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/9/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderListViewCtrl.h"
#import "UIScrollView+EmptyDataSet.h"
#import "YGSegmentedControl.h"
#import "YGOrderCell.h"
#import "YGOrderHandler.h"
#import "YGOrderDataProvider.h"

#import "YGPopoverItemsViewCtrl.h"

@interface YGOrderListViewCtrl ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *segmentPanel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet YGSegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSUInteger curIndex;
@property (strong, nonatomic) YGOrderDataProvider *provider;
@end

@implementation YGOrderListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    self.curIndex = 0;
}

- (void)initUI
{
    Class cellCls = orderCellClassOfOrderType(self.orderType);
    BOOL isValidCellCls = cellCls && [cellCls isSubclassOfClass:[YGOrderCell class]];
    if (!isValidCellCls) return;
    
    // group类型的tableView加了高度为1的headerView
    self.tableView.contentInset = UIEdgeInsetsMake(self.segmentViewHeightConstraint.constant-1.f, 0, 0, 0);
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self mjrefresh:type];
    }];
    self.tableView.noMoreDataNotice = @"没有更多了";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = [cellCls estimatedRowHeight];
    self.tableView.sectionHeaderHeight = 5.f;
    self.tableView.sectionFooterHeight = 5.f;
    self.tableView.estimatedSectionHeaderHeight = 5.f;
    self.tableView.estimatedSectionFooterHeight = 5.f;
    
    [cellCls registerInTableView:self.tableView];
    
    [self.segmentPanel layoutIfNeeded];
    self.segmentControl.frame = self.segmentPanel.bounds; //segmentContrl在iOS10上有BUG
    self.segmentControl.font = [UIFont systemFontOfSize:14];
    self.segmentControl.hairlineColor = RGBColor(230, 230, 230, 1);
    [self.segmentControl setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];

    self.navigationItem.title = getOrderTitle(self.orderType);
    [self rightNavButtonImg:@"icon_mall_index_more"];
}

- (void)doRightNavAction
{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeHome]];
    
    switch (self.orderType) {
        case YGOrderTypeCourse:{
            [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeCourseHome]];
        }   break;
        case YGOrderTypeMall:{
            [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMall]];
            [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMallCart]];
        }   break;
        case YGOrderTypeTeaching:{
            [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeTeachingHome]];
        }   break;
        case YGOrderTypeTeachBooking:{
            [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeTeachBookingHome]];
        }   break;
    }
    
    ygweakify(self);
    YGPopoverItemsViewCtrl *vc = [YGPopoverItemsViewCtrl instanceFromStoryboard];
    [vc setupItems:items callback:^(YGPopoverItem *item) {
        ygstrongify(self);
        [YGPopoverItem performDefaultOpeaterOfItem:item fromNavi:self.navigationController];
    }];
    [vc show];
}

- (void)setCurIndex:(NSUInteger)curIndex
{
    _curIndex = curIndex;
    self.segmentControl.selectedSegmentIndex = curIndex;
}

- (IBAction)segmentChanged:(DZNSegmentedControl *)segment
{
    NSInteger idx = segment.selectedSegmentIndex;
    self.curIndex = idx;
    if (idx < self.provider.statues.count) {
        NSUInteger status = [self.provider.statues[idx] integerValue];
        [self.provider fetchDataOfStatus:status];
    }
}

- (void)updateSegmentTitles
{
    self.segmentControl.items = self.provider.titles;
    for (NSInteger i=0; i < self.provider.countes.count; i++) {
        [self.segmentControl setCount:self.provider.countes[i] forSegmentAtIndex:i];
    }
}

- (void)mjrefresh:(YGRefreshType)type
{
    if (type == YGRefreshTypeHeader) {
        [self.provider refresh];
    }else{
        [self.provider loadMore];
    }
}

#pragma mark - Data
- (void)initData
{
    ygweakify(self);
    self.provider = [[YGOrderDataProvider alloc] initWithType:self.orderType];
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (suc) {
            [self.tableView reloadEmptyDataSet];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            
            BOOL hasMore = [self.provider hasMoreDataOfStatus:self.provider.curStatus];
            if (hasMore) {
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_footer resetNoMoreData];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self updateSegmentTitles];
            
            if ([self.loadingIndicator isAnimating]) {
                [self.loadingIndicator stopAnimating];
                [self.tableView setHidden:NO animated:YES];
                self.segmentPanel.hidden = NO;
            }
        }else{
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
        }
    }];
    [self.provider fetchDataOfStatus:0];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.provider.orderList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = orderCellIdentifierOfOrderType(self.orderType);
    YGOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    id order = [self.provider orderAtIndex:indexPath.section];
    [cell configureWithOrder:order];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id order = [self.provider orderAtIndex:indexPath.section];
    [YGOrderHandler showOrderDetail:order fromNaviViewCtrl:self.navigationController];
}

#pragma mark - Empty
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    return [[NSAttributedString alloc] initWithString:@"没有订单" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:RGBColor(102, 102, 102, 1)}];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"img_none_list_gray"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.provider.orderList.count==0;
}

@end
