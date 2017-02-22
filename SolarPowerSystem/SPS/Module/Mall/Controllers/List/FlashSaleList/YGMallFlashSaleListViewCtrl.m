//
//  YGMallFlashSaleListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallFlashSaleListViewCtrl.h"
#import "YGMallFlashSaleCommodityCell.h"
#import "YGMallFlashSaleLogic.h"
#import "YG_MallCommodityViewCtrl.h"
#import "YGMallViewCtrl.h"
#import "YGPopoverItemsViewCtrl.h"
#import "YGMallCartViewCtrl.h"
#import "YGMallCommodityListContainer.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YGMallFlashSaleListViewCtrl () <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) YGMallFlashSaleLogic *flashSale;
@property (strong, nonatomic) NSArray *sortedData;
@end

@implementation YGMallFlashSaleListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    YGPostBuriedPoint(YGMallPointFlashSaleList);
    [self initUI];
    [self initData];
}

- (void)initUI
{
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeHeader) {
            [self.flashSale refresh];
        }else{
            [self.flashSale loadMore];
        }
    }];
    self.tableView.noMoreDataNotice = @"看完啦~不要错过抢购哦！";
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(48.f, 0, 0, 0);
    [self rightNavButtonImg:@"icon_mall_index_more"];
}

- (void)initData
{
    self.flashSale = [[YGMallFlashSaleLogic alloc] initWithScene:YGMallFlashSaleSceneList];
    ygweakify(self);
    [self.flashSale setCallback:^(BOOL suc, BOOL isMore, id object) {
        ygstrongify(self);
        if (isMore) {
            if (self.flashSale.hasMore) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            [self.tableView.mj_header endRefreshing];
        }
        
        if (suc) {
            self.sortedData = [self.flashSale sortedData];
            [self.tableView reloadData];
        }else if ([object isKindOfClass:[NSString class]]){
            [SVProgressHUD showErrorWithStatus:object];
        }
    }];
    [self.flashSale refresh];
}

- (void)doRightNavAction
{
    NSInteger idx = [self.navigationController.viewControllers indexOfObject:self]-1;
    UIViewController *previousViewCtrl = [self.navigationController.viewControllers objectAtIndex:idx];
    NSMutableArray *items = [NSMutableArray array];
    if (idx != 0) {
        //前面不是首页
        [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeHome]];
    }
    if (![previousViewCtrl isKindOfClass:[YGMallViewCtrl class]]) {
        //前面不是商城首页
        [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMall]];
    }
    
    [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMallList]];
    [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMallCart]];
    
    ygweakify(self);
    YGPopoverItemsViewCtrl *vc = [YGPopoverItemsViewCtrl instanceFromStoryboard];
    [vc setupItems:items callback:^(YGPopoverItem *item) {
        ygstrongify(self);
        [YGPopoverItem performDefaultOpeaterOfItem:item fromNavi:self.navigationController];
    }];
    [vc show];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sortedData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tmp = self.sortedData[section];
    return tmp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallFlashSaleCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallFlashSaleCommodityCell forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(YGMallFlashSaleCommodityCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *tmp = self.sortedData[section];
    CommodityModel *commodity = tmp[row];
    [cell configureWithCommodity:commodity];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    YGMallFlashSaleDateCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallFlashSaleDateCell];
    NSArray *tmp = self.sortedData[section];
    [cell configureWithCommodity:[tmp lastObject]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *tmp = self.sortedData[section];
    CommodityModel *commodity = tmp[row];

    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
    vc.cid = commodity.commodityId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Empty
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"img_none_list_gray"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.sortedData.count == 0;
}
@end
