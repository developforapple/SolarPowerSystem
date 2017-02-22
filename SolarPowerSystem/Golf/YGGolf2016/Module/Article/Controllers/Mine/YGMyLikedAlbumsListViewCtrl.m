//
//  YGMyLikedAlbumsListViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMyLikedAlbumsListViewCtrl.h"
#import "YGYueduAlbumCell.h"
#import "YGRefreshComponent.h"
#import "YGYueduDataProvider.h"
#import "YGArticleAlbumDetailViewCtrl.h"
#import "ReactiveCocoa.h"
#import "UIScrollView+EmptyDataSet.h"

@interface YGMyLikedAlbumsListViewCtrl ()<UICollectionViewDataSource,UICollectionViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) YGYueduDataProvider *provider;
@end

@implementation YGMyLikedAlbumsListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statisticsToken = YueduPage_LikedAlbum;
    
    [self initUI];
    [self initData];
    [self initSignal];
    
    [self loadData:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.scrollsToTop = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.collectionView.scrollsToTop = NO;
}

- (void)initUI
{
    ygweakify(self);
    
    [YGYueduAlbumCell registerCellInCollectionView:self.collectionView];
    CGFloat w = (int)((Device_Width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right - self.flowLayout.minimumInteritemSpacing)/2);
    self.flowLayout.itemSize = CGSizeMake(w, w);
    
    [self.collectionView setRefreshHeaderEnable:NO footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        BOOL isMore = type==YGRefreshTypeFooter;
        [self loadData:isMore];
    }];
    self.collectionView.contentInset = UIEdgeInsetsMake(self.contentEdgeInsetsTop, 0, 0, 0);
}

- (void)initData
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initForMyLikedAlbum];
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        [self.loadingIndicator stopAnimating];
        [self.collectionView reloadData];
        if (!suc) {
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
        }
    }];
    [RACObserve(self.provider, noMoreData)
     subscribeNext:^(NSNumber *x) {
         ygstrongify(self);
         if (x.boolValue) {
             [self.collectionView.mj_footer endRefreshingWithNoMoreData];
         }else{
             [self.collectionView.mj_footer resetNoMoreData];
         }
     }];
}

- (void)initSignal
{
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter]
     rac_addObserverForName:kYGYueduDidLikedAlbumNotification object:nil]
     subscribeNext:^(NSNotification *x) {
         ygstrongify(self);
         if ([self.provider insertAlbum:x.object atIndex:0]) {
             [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
             [self.collectionView reloadEmptyDataSet];
         }
     }];
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:kYGYueduDidDislikedAlbumNotification object:nil] subscribeNext:^(NSNotification *x) {
        ygstrongify(self);
        YueduAlbumBean *album = x.object;
        NSUInteger index = [self.provider removeAlbum:@(album.id)];
        if (index != NSNotFound) {
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
            [self.collectionView reloadEmptyDataSet];
        }
    }];
}

- (void)loadData:(BOOL)isMore
{
    if (isMore) {
        [self.provider loadMoreData];
    }else{
        [self.provider refresh];
    }
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.provider.albumCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGYueduAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGYueduAlbumCellID forIndexPath:indexPath];
    if (!iOS8) {
        [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(YGYueduAlbumCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell configureWithAlbum:[self.provider albumAtIndex:indexPath.item]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YueduAlbumBean *album = [self.provider albumAtIndex:indexPath.item];
    YGArticleAlbumDetailViewCtrl *detailVC = [YGArticleAlbumDetailViewCtrl instanceFromStoryboard];
    detailVC.albumId = @(album.id);
    [self.navigationController pushViewController:detailVC animated:YES];
    
    // 我收藏的专题点击量埋点统计
    YGPostBuriedPoint(YGYueduStatistics_MyAlbumArticle);
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
    return self.provider.articleCount==0 && ![self.loadingIndicator isAnimating];
}

@end
