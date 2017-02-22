//
//  YGAlbumListViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGAlbumListViewCtrl.h"
#import "YGYueduDataProvider.h"
#import "YGYueduAlbumCell.h"
#import "YGArticleAlbumDetailViewCtrl.h"
#import "YGRefreshComponent.h"
#import "DDSegmentScrollView.h"
#import "ReactiveCocoa.h"

@interface YGAlbumListViewCtrl () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    // 这个控制器内容是否为第一次显示。YES,显示过。NO,未显示。
    BOOL _didAppearedflag;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowlayout;
@property (weak, nonatomic) IBOutlet DDSegmentScrollView *segmentView;
@property (strong, nonatomic) YGYueduDataProvider *provider;
@end

@implementation YGAlbumListViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.scrollsToTop = YES;
    
    if (!_didAppearedflag) {
        _didAppearedflag = YES;
        // 第一次加载时不检查数据是否过期，强制更新
        [self loadCategoryData:[self.provider.columnBean.categoryList firstObject] checkExpire:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.collectionView.scrollsToTop = NO;
}

- (void)initUI
{
    [YGYueduAlbumCell registerCellInCollectionView:self.collectionView];
    
    CGFloat w = (int)((Device_Width - self.flowlayout.sectionInset.left - self.flowlayout.sectionInset.right - self.flowlayout.minimumInteritemSpacing)/2);
    self.flowlayout.itemSize = CGSizeMake(w, w);
    
    self.collectionView.contentInset = UIEdgeInsetsMake(44.f+64.f, 0, 0, 0);
    
    ygweakify(self);
    [self.collectionView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        BOOL isMore = type==YGRefreshTypeFooter;
        [self refresh:self.provider.categoryBean isMore:isMore];
    }];
    
    [self.segmentView setTitles:[self.columnBean allCategoryNames]];
}

#pragma mark - Data
- (void)loadData
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initWithColumn:self.columnBean];
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (!self.provider.isCacheData) {
            [self.loadingIndicator stopAnimating];
        }
        if (suc) {
            [self.collectionView reloadData];
            if (!isMore && !self.provider.isCacheData){
                [self.collectionView.mj_header endRefreshing];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
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

- (void)loadCategoryData:(YueduCategoryBean *)category checkExpire:(BOOL)checkExpire
{
    BOOL cached = [self.provider haveCacheData:category];
    if (!cached) {
        [self.loadingIndicator startAnimating];
    }
    
    BOOL shouldRefresh = YES;
    if (checkExpire) {
        shouldRefresh = [self.provider dataExpiredOfCategory:category];
    }
    if (category.id == 0 || category.id != self.provider.categoryBean.id) {
        self.collectionView.mj_header.state = MJRefreshStateIdle;
//        [self.collectionView.mj_header endRefreshing]; //这里不要用endRefreshing. 在UICollectioView里 endRefreshing有0.2秒延迟，会导致状态不正常。
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
    
    //悦读埋点
    int32_t p = 10000 + self.provider.columnBean.id;
    YGPostBuriedPoint(p);
}

@end
