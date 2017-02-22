//
//  YGSearchResultViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchResultViewCtrl.h"
#import "YGSearchBaseCell.h"
#import "YGSearchHeaderFooterCell.h"
#import "YGSearchEngine.h"
#import "YGThrift+SeatchEngine.h"
#import "YGRefreshComponent.h"
#import "UIScrollView+EmptyDataSet.h"

@interface YGSearchResultViewCtrl ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{
    BOOL _inLoading;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet YGSearchEngine *engine;
@property (strong, nonatomic) NSArray *typeList;
@end

@implementation YGSearchResultViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ygweakify(self);
    _inLoading = NO;
    
    // 需要进行一些设置
    [self setType:self.type];
    
    [self.engine setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (!self) return;
        
        self->_inLoading = NO;
        if (suc) {
            self.typeList = [self.engine resultTypeList];
            [self.tableView reloadData];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络不可用"];
        }
        if (self.engine.noMoreData) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (void)setType:(YGSearchType)type
{
    _type = type;
    
    if (type != YGSearchTypeAll) {
        ygweakify(self);
        [self.tableView setRefreshHeaderEnable:NO footerEnable:YES callback:^(YGRefreshType type) {
            ygstrongify(self);
            if (type == YGRefreshTypeFooter && !self.engine.noMoreData) {
                [self.engine loadMore];
            }
        }];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - Search
- (void)searchWithKeywords:(NSString *)keywords
{
    if (keywords.length == 0) {
        [self.engine reset];
        self.typeList = nil;
        _inLoading = NO;
        [self.tableView reloadData];
    }else{
        YGSearchCondition *c = [[YGSearchCondition alloc] initWithType:self.type keywords:keywords pageNo:1];
        _inLoading = YES;
        [self.engine search:c];
    }
}

#pragma mark - Data
- (BOOL)shouldShowFooterInSection:(NSUInteger)section
{
    NSNumber *type = self.typeList[section];
    return [self.engine hasMoreDataOfType:type.integerValue];
}

- (BOOL)shouldShowHeaderInSection:(NSUInteger)section
{
    return YGSearchTypeAll==self.type;
}

- (NSArray *)listInSection:(NSUInteger)section
{
    NSNumber *type = self.typeList[section];
    NSArray *list = self.engine.resultData[type];
    return list;
}

- (BOOL)isHeaderOrFooterCell:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    BOOL result = NO;
    
    if (row == 0) {
        result = [self shouldShowHeaderInSection:section];
    }else{
        BOOL showFooter = [self shouldShowFooterInSection:section];
        NSUInteger rows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
        return row+1==rows && showFooter;
    }
    return result;
}

- (id<YGSearchViewModelProtocol>)beanAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHeaderOrFooterCell:indexPath]) {
        return nil;
    }
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    
    NSArray *list = [self listInSection:section];
    NSUInteger idx = row - [self shouldShowHeaderInSection:section];
    if (idx < list.count) {
        return list[idx];
    }
    return nil;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.typeList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL showHeader = [self shouldShowHeaderInSection:section];
    BOOL showFooter = [self shouldShowFooterInSection:section];
    NSArray *list = [self listInSection:section];
    return list.count + showHeader + showFooter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *type = self.typeList[indexPath.section];
    YGSearchCellType cellType;
    if ([self isHeaderOrFooterCell:indexPath]) {
        cellType = YGSearchCellTypeHeaderFooter;
    }else{
        cellType = [YGSearchBaseCell cellTypeForSearchType:type.integerValue];
    }
    
    NSString *identifier = [YGSearchBaseCell cellIdentifierForType:cellType];
    YGSearchBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(__kindof YGSearchBaseCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *type = self.typeList[indexPath.section];
    if ([self isHeaderOrFooterCell:indexPath]) {
        YGSearchHeaderFooterCell *theCell = cell;
        BOOL isHeader = indexPath.row==0;
        NSString *title = isHeader?SearchTitleOfType(type.integerValue):SearchFooterOfType(type.integerValue);
        theCell.usedForHeader = isHeader;
        [theCell configureWithEntity:title];
    }else{
        id<YGSearchViewModelProtocol> bean = [self beanAtIndexPath:indexPath];
        if ([bean respondsToSelector:@selector(viewModel)]) {
            __kindof YGSearchViewModel *vm = [bean viewModel];
            [cell configureWithEntity:vm];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHeaderOrFooterCell:indexPath]) {
        return 44.f;
    }
    id<YGSearchViewModelProtocol> bean = [self beanAtIndexPath:indexPath];
    if ([bean respondsToSelector:@selector(viewModel)]) {
        return [[bean viewModel] containerHeight];
    }
    return 1.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *type = self.typeList[indexPath.section];
    if ([self isHeaderOrFooterCell:indexPath]) {
        if (indexPath.row != 0 && self.willShowAllResult) {
            self.willShowAllResult(type.integerValue);
        }
    }else{
        id<YGSearchViewModelProtocol> bean = [self beanAtIndexPath:indexPath];
        if (self.willShowResultDetail) {
            self.willShowResultDetail(bean);
        }
    }
}

#pragma mark - Empty
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                           NSForegroundColorAttributeName:RGBColor(153, 153, 153, 1)};
    return [[NSAttributedString alloc] initWithString:@"没有更多的搜索结果" attributes:attr];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return !_inLoading && self.engine.condition.keywords.length != 0 && self.typeList.count == 0;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    // 导航栏下40的位置
    return -CGRectGetHeight(scrollView.frame)/2 + 64.f + 40.f;
}

@end
