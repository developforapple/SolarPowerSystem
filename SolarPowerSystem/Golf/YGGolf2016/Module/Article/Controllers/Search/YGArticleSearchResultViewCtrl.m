//
//  YGArticleSearchResultViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleSearchResultViewCtrl.h"
#import "YGYueduCell.h"
#import "YGYueduAlbumCell.h"
#import "YGYueduDataProvider.h"
#import "YGArticleViewModel.h"
#import "YGRefreshComponent.h"
#import "YGArticleAlbumDetailViewCtrl.h"
#import "UIScrollView+EmptyDataSet.h"
#import "YGRefreshComponent.h"
#import "ReactiveCocoa.h"

@interface YGArticleSearchResultViewCtrl ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *articleHeaderView;
@property (strong, nonatomic) YGYueduDataProvider *provider;

@property (weak, nonatomic) IBOutlet UIView *albumContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *albumCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *albumFlowLayout;

@end

@implementation YGArticleSearchResultViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initProvider];
}

- (void)initUI
{
    [YGYueduCell registerYueDuCellsInTableView:self.tableView];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:NO footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeFooter) {
            [self.provider loadMoreData];
        }
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (void)initProvider
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initWithSearchType:YGYueduSearchTypeAll];
    self.provider.isSimpleMode = YES;
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (suc) {
            if (self.completion) {
                self.completion();
            }
            [self updateUI];
        }else{
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

- (void)updateUI
{
    BOOL hasAblum = self.provider.albumCount!=0;
    self.tableView.tableHeaderView = hasAblum?self.albumContainer:nil;
    [self.tableView reloadData];
    [self.albumCollectionView reloadData];
}

- (void)reset
{
    [self.tableView scrollToTopAnimated:NO];
}

#pragma mark - Search
- (void)search:(NSString *)keywords
{
    if (!keywords) return;
    if (self.provider.keywords && [self.provider.keywords isEqualToString:keywords]) {
        if (self.completion) {
            self.completion();
        }
        return;
    }
    [self.provider refreshKeywords:keywords];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(YGYueduCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    [cell configureWithArticle:article];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    return [article.viewModel containerHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.provider.articleCount==0?nil:self.articleHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.provider.articleCount==0?0.f:CGRectGetHeight(self.articleHeaderView.frame);
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.provider.albumCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGYueduAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGYueduAlbumCellID forIndexPath:indexPath];
    YueduAlbumBean *album = [self.provider albumAtIndex:indexPath.item];
    [cell configureWithAlbum:album];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YueduAlbumBean *album = [self.provider albumAtIndex:indexPath.item];
    YGArticleAlbumDetailViewCtrl *detailVC = [YGArticleAlbumDetailViewCtrl instanceFromStoryboard];
    detailVC.albumId = @(album.id);
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - EmptyData
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName:RGBColor(153, 153, 153, 1)};
    return [[NSAttributedString alloc] initWithString:@"高球界还没有这样的内容哦" attributes:attribute];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"icon_search_noresult"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.provider.articleCount==0&&self.provider.albumCount==0;
}

@end
