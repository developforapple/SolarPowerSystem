//
//  DDAssetsPreviewController.m
//  Golf
//
//  Created by bo wang on 16/8/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DDAssetsPreviewController.h"
#import "DDAssetsPreviewCell.h"
#import "DDAssetsInclude.h"

@interface DDAssetsPreviewController ()
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@end

@implementation DDAssetsPreviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.firstIndex != 0) {
        self.collectionView.hidden = YES;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.flowLayout.itemSize = self.collectionView.bounds.size;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.collectionView.hidden && self.firstIndex != 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.firstIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.collectionView.hidden = NO;
        });
    }
}

#pragma mark
- (void)displayAsset:(DDAsset *)asset
{
    [self displayAssetAtIndex:[self.assets indexOfObject:asset]];
}

- (void)displayAssetAtIndex:(NSUInteger)index
{
    if (index >= self.assets.count) return;

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)removeAssetAtIndex:(NSUInteger)index
{
    if (index >= self.assets.count) return;
    
    NSMutableArray *assets = [NSMutableArray arrayWithArray:self.assets];
    [assets removeObjectAtIndex:index];
    self.assets = assets;
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ddweakify(self);
    DDAssetsPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDDAssetsPreviewCell forIndexPath:indexPath];
    cell.animatedWhenAssetDisplay = self.animatedWhenAssetDisplay;
    [cell setTapAction:^(DDAsset *asset){
        ddstrongify(self);
        if (self.tapAction) {
            self.tapAction(self,asset);
        }
    }];
    if (!iOS8) {
        [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DDAssetsPreviewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDAsset *asset = self.assets[indexPath.row];
    [cell configureWithALAssset:asset];
    if (self.willDisplayAsset) {
        ddweakify(self);
        self.willDisplayAsset(weak_self,asset);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *indexPath = [indexPaths firstObject];
    if (indexPaths && self.willDisplayAsset) {
        DDAsset *asset = self.assets[indexPath.row];
        ddweakify(self);
        self.willDisplayAsset(weak_self,asset);
    }
}
@end
