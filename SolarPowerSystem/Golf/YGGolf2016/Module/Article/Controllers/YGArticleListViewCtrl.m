//
//  YGArticleListViewCtrl.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleListViewCtrl.h"
#import "YGYueduCell.h"
#import "YGYueduDataProvider.h"
#import "YGArticleViewModel.h"
#import "DDSegmentScrollView.h"
#import "YGRefreshComponent.h"
#import "YGYueduCommon.h"
#import "ReactiveCocoa.h"

@interface YGArticleListViewCtrl () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet DDSegmentScrollView *segmentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) YGYueduDataProvider *provider;

@property (assign, nonatomic) BOOL didAppearedflag;// 这个控制器内容是否为第一次显示。YES,显示过。NO,未显示。
@end

@implementation YGArticleListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.scrollsToTop = YES;
    
    if (!self.didAppearedflag) {
        self.didAppearedflag = YES;
        // 第一次加载时不检查数据是否过期，强制更新
        [self loadCategoryData:[self.provider.columnBean.categoryList firstObject] checkExpire:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.scrollsToTop = NO;
}

- (void)initUI
{
    [YGYueduCell registerYueDuCellsInTableView:self.tableView];
    self.segmentView.titles = [self.columnBean allCategoryNames];
    
    //tableView为group形式，添加了高度为1的header
    self.tableView.contentInset = UIEdgeInsetsMake(43.f+64.f, 0, 0, 0);
    
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        BOOL isMore = YGRefreshTypeFooter==type;
        [self refresh:self.provider.categoryBean isMore:isMore];
    }];
}

#pragma mark - Data
- (void)initData
{
    self.provider = [[YGYueduDataProvider alloc] initWithColumn:self.columnBean];
    ygweakify(self);
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (!self.provider.isCacheData) {
            [self.loadingIndicator stopAnimating];
        }
        if (suc) {
            [self.tableView reloadData];
            if (!isMore && !self.provider.isCacheData) {
                [self.tableView.mj_header endRefreshing];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    [RACObserve(self.provider, noMoreData)
     subscribeNext:^(NSNumber *x) {
         ygstrongify(self);
         if (x.boolValue) {
             [self.tableView.mj_footer endRefreshingWithNoMoreData];
         }else{
             [self.tableView.mj_footer resetNoMoreData];
         }
     }];
}

- (void)loadCategoryData:(YueduCategoryBean *)category checkExpire:(BOOL)checkExpire
{
    BOOL cached = [self.provider haveCacheData:category];
    if (!cached) {
        // 未缓存数据时，显示loading
        [self.loadingIndicator startAnimating];
    }
    
    BOOL shouldRefresh = YES;
    if (checkExpire) {
        shouldRefresh = [self.provider dataExpiredOfCategory:category];
    }
    
    if (category.id == 0 || category.id != self.provider.categoryBean.id) {
        [self.tableView.mj_header endRefreshing];
        [self.provider updateUsingCacheData:category];
        if (shouldRefresh) {
            [self refresh:self.provider.categoryBean isMore:NO];
        }
    }
}

#pragma mark - Refresh
- (IBAction)segmentDidChanged:(DDSegmentScrollView *)segmentView
{
    YueduCategoryBean *categoryBean = [self.columnBean categoryAtIndex:segmentView.currentIndex];
    [self loadCategoryData:categoryBean checkExpire:YES];
}

- (void)refresh:(YueduCategoryBean *)category
         isMore:(BOOL)isMore
{
    if (isMore) {
        [self.provider loadMoreData];
    }else{
        [self.provider refreshCategory:category];
    }
}

- (void)openCategory:(YueduCategoryBean *)category
{
    int32_t cid = category.id;
    for (YueduCategoryBean *aCategory in self.provider.columnBean.categoryList) {
        if (aCategory.id == cid) {
            NSUInteger index = [self.provider.columnBean.categoryList indexOfObject:aCategory];
            self.segmentView.currentIndex = index;
            [self.tableView scrollToTopAnimated:YES];//回到顶部
            [self loadCategoryData:aCategory checkExpire:YES];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.provider.articleCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    YGYueduCellType cellType = article.cellType;
    NSString *identifier = [YGYueduCell cellIdentifierForType:cellType];
    YGYueduCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.viewCtrl = self;
    cell.categoryActionEnabled = article.category.id != self.provider.categoryBean.id;
    [cell setCategoryAction:^(YueduArticleBean *tmp) {
        [self openCategory:tmp.category];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    YGArticleViewModel *vm = article.viewModel;
    return [vm containerHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(YGYueduCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    [cell configureWithArticle:article];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //悦读埋点
    int32_t p = 10000 + self.provider.columnBean.id;
    YGPostBuriedPoint(p);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
