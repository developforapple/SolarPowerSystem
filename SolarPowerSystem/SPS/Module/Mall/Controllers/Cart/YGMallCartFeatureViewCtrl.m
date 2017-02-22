//
//  YGMallCartFeatureViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCartFeatureViewCtrl.h"
#import "YGMallCommodityGridCell.h"
#import "YGMallSectionTitleView.h"

@interface YGMallCartFeatureViewCtrl () <UITableViewDelegate,UITableViewDataSource>
{
    BOOL _firstLoadFlag;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation YGMallCartFeatureViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    _firstLoadFlag = YES;
    
    [self initUI];
}

- (void)initUI
{
    [YGMallSectionTitleView registerIn:self.tableView];
    [YGMallCommodityGridCell registerIn:self.tableView];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:NO footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self loadData];
    }];
    
    self.tableView.rowHeight = [YGMallCommodityGridCell preferredHeight];
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (void)setVisible:(BOOL)visible
{
    _visible = visible;
    
    if (_firstLoadFlag) {
        _firstLoadFlag = NO;
        [self loadData];
    }
}

- (void)loadData
{
    ygweakify(self);
    [self.cart loadFeaturedCommodity:^(BOOL suc, BOOL hasMore) {
        ygstrongify(self);
        
        if (!suc) {
            [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView reloadData];
            if (hasMore) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)ceilf(self.cart.featuredCommodities.count/2.f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallCommodityGridCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallCommodityGridCell forIndexPath:indexPath];
    NSInteger index1 = indexPath.row * 2;
    NSInteger index2 = indexPath.row * 2 + 1;
    NSMutableArray *list = [NSMutableArray arrayWithObject:self.cart.featuredCommodities[index1]];
    if (index2 < self.self.cart.featuredCommodities.count) {
        [list addObject:self.self.cart.featuredCommodities[index2]];
    }
    [cell configureWithCommodities:list];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.cart.featuredCommodities.count == 0) {
        return nil;
    }
    YGMallSectionTitleView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kYGMallSectionTitleView];
    [view configureWithHeader:[YGMallSectionHeaderModel header:YGMallSectionTypeCommodity]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48.f;
}

@end
