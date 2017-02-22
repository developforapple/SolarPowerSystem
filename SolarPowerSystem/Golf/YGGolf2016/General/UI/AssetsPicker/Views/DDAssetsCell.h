//
//  DDAssetsCell.h
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsManager.h"
#import "DDAssetCellContainer.h"

#define kDDAssetsCell @"DDAssetsCell"
#define kDDAssetsCell_BigCell @"DDAssetsCell_BigCell"

@interface DDAssetsCell : UICollectionViewCell

@property (strong, nonatomic) DDAssetsManager *manager;

@property (weak, nonatomic) IBOutlet DDAssetCellContainer *assetContainer;
@property (strong, nonatomic) DDAsset *asset;

- (void)configureWithAsset:(DDAsset *)asset;

/**
 *  让控制器告知cell，这个asset能不能被选中。
 *  如果返回NO，恢复asset为未选状态。返回YES，触发选中assetSelectedChanged回调。
 */
@property (copy, nonatomic) BOOL (^shouldSelectedAsset)(DDAsset *asset);
/**
 *  点击cell的右上角按钮时,选中或者取消选中这个asset。触发block。
 */
@property (copy, nonatomic) void (^assetSelectedChanged)(DDAsset *asset, BOOL isSelected);
/**
 *  点击容器右上角按钮之外的区域，将预览这个asset
 */
@property (copy, nonatomic) void (^assetWillPreviewBlock)(DDAsset *asset);

@end
