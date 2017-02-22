//
//  YGMallOrderReviewListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderReviewListViewCtrl.h"
#import "YGMallOrderModel.h"
#import "YGMallOrderReviewCell.h"
#import "YGMallOrderReviewEditViewCtrl.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YGMallOrderReviewListViewCtrl ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<YGMallOrderCommodity *> *commodityList;
@end

@implementation YGMallOrderReviewListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    if ([self unreviewedAmount] == 0 && self.didReviewedOrder) {
        self.didReviewedOrder(self.orderId);
    }
}

- (void)loadData
{
    [ServerService fetchMallOrderCommodityList:self.orderId callBack:^(id obj) {
        self.commodityList = obj;
        [self.tableView reloadData];
        [self.tableView setHidden:NO animated:YES];
        [self.loadingIndicator stopAnimating];
    } failure:^(id error) {
    }];
}

- (NSInteger)unreviewedAmount
{
    NSInteger amount = 0;
    for (YGMallOrderCommodity *commodity in self.commodityList) {
        if (!commodity.comment_status) {
            amount++;
        }
    }
    return amount;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commodityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallOrderReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallOrderReviewCell forIndexPath:indexPath];
    cell.commodity = self.commodityList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YGMallOrderCommodity *commodity = self.commodityList[indexPath.row];
    if (!commodity.comment_status) {
        YGMallOrderReviewEditViewCtrl *vc = [YGMallOrderReviewEditViewCtrl instanceFromStoryboard];
        vc.commodity = commodity;
        vc.orderId = self.orderId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
