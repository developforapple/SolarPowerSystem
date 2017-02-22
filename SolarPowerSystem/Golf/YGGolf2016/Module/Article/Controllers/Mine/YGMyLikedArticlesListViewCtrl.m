//
//  YGMyLikedArticlesListViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMyLikedArticlesListViewCtrl.h"
#import "YGYueduCell.h"
#import "YGYueduDataProvider.h"
#import "YGRefreshComponent.h"
#import "YGArticleViewModel.h"
#import "YGYueduCommon.h"
#import "ReactiveCocoa.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YGMyLikedArticlesListViewCtrl ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
{
    BOOL _firstAppearFlag;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) YGYueduDataProvider *provider;
@end

@implementation YGMyLikedArticlesListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statisticsToken = YueduPage_LikedArticle;
    
    [self initUI];
    [self initData];
    [self initSignal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_firstAppearFlag) {
        _firstAppearFlag = YES;
        [self.provider refresh];
    }
}

- (void)initUI
{
    [YGYueduCell registerYueDuCellsInTableView:self.tableView];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:NO footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        BOOL isMore = YGRefreshTypeFooter==type;
        if (isMore) {
            [self.provider loadMoreData];
        }
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.contentEdgeInsetsTop, 0, 0, 0);
}

- (void)initData
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initForMyLikedArticle];
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        [self.loadingIndicator stopAnimating];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        self.tableView.tableHeaderView.hidden = self.provider.articleCount==0;
        if (!suc) {
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
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

- (void)initSignal
{
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:kYGYueduDidLikedArticleNotification object:nil]
       subscribeNext:^(NSNotification *x) {
           ygstrongify(self);
           @synchronized (self.provider) {
               NSLog(@"1");
               
               if ([self.provider insertArticle:x.object atIndex:0]) {
                   [self.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                   [self.tableView reloadEmptyDataSet];
               }
           }
    }];
    [[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:kYGYueduDidDislikedArticleNotification object:nil]
       subscribeNext:^(NSNotification *x) {
           ygstrongify(self);
           @synchronized (self.provider) {
               NSLog(@"0");
               YueduArticleBean *article = x.object;
               NSUInteger index = [self.provider removeArticle:@(article.id)];
               if (index != NSNotFound) {
                   [self.tableView deleteRow:index inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                   [self.tableView reloadEmptyDataSet];
               }
           }
     }];
}

#pragma mark - Action
- (IBAction)exit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView
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
    // 我收藏的文章点击量埋点统计
    YGPostBuriedPoint(YGYueduStatistics_MyLikedArticle);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - EmptyData
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:RGBColor(153, 153, 153, 1)};
    return [[NSAttributedString alloc] initWithString:@"还没有收藏" attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"icon_me_read_nocllect"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.provider.albumCount==0 && ![self.loadingIndicator isAnimating];
}

@end
