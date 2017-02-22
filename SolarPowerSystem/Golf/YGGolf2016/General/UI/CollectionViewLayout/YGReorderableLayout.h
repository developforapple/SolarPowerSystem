//
//  YGReorderableLayout.h
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGReorderableLayout;

@protocol YGReorderableLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
- (BOOL)collectionView:(UICollectionView *)collectionView allowMoveItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)at toIndexPath:(NSIndexPath *)to;
- (void)collectionView:(UICollectionView *)collectionView willMoveItemAtIndexPath:(NSIndexPath *)at toIndexPath:(NSIndexPath *)to;
- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)at toIndexPath:(NSIndexPath *)to;
- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout didBeginDraggingItemAt:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout willEndDraggingItemTo:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout didEndDraggingItemTo:(NSIndexPath *)indexPath;
@end

@protocol YGReorderableLayoutDataSource <UICollectionViewDataSource>
@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView reorderingItemAlphaInSection:(NSInteger)section;
- (UIEdgeInsets)scrollTrigerEdgeInsetsInCollectionView:(UICollectionView *)collectionView;
- (UIEdgeInsets)scrollTrigerPaddingInCollectionView:(UICollectionView *)collectionView;
- (CGFloat)scrollSpeedValueInCollectionView:(UICollectionView *)collectionView;
@end

@interface YGReorderableLayout : UICollectionViewFlowLayout

// default 0.f
@property (assign, nonatomic) CGFloat reorderingItemAlpha;

// default YES
@property (assign, nonatomic) BOOL dragEnabled;

@property (weak, nonatomic) id<YGReorderableLayoutDelegate> delegate;
@property (weak, nonatomic) id<YGReorderableLayoutDataSource> dataSource;

@end
