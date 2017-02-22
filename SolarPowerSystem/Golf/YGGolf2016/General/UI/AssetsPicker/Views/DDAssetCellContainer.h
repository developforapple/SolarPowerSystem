//
//  DDAssetCellContainer.h
//  JuYouQu
//
//  Created by Normal on 15/12/10.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsManager.h"

@interface DDAssetCellContainer : UIView

@property (weak, nonatomic) IBOutlet UIImageView *assetsImageView;
@property (weak, nonatomic) IBOutlet UIView *assetSelectedView;
@property (weak, nonatomic) IBOutlet UIImageView *assetSelectIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *gifIndicator;

@property (readonly, strong, nonatomic) DDAsset *asset;
- (void)configureWithAsset:(DDAsset *)asset;


/**
 *  让cell告知容器，这个asset能不能被选中。
 *  如果返回NO，恢复asset为未选状态。返回YES，触发选中assetSelectedChanged回调。
 */
@property (copy, nonatomic) BOOL (^shouldSelectedAsset)(DDAsset *asset);
/**
 *  点击右上角按钮时,选中或者取消选中这个asset。触发block。
 */
@property (copy, nonatomic) void (^assetSelectedChanged)(DDAsset *asset, BOOL isSelected);

/**
 *  点击右上角之外的区域，告知cell将预览这个asset
 */
@property (copy, nonatomic) void (^assetWillPreviewBlock)(DDAsset *asset);

/**
 *  只有右上角按钮亮起的时候，资源才被选中。直接点击容器，将进行预览，不会选中资源。
 *  设置属性时不会调用block回调。
 */
@property (getter=isAssetSelected, nonatomic) BOOL assetSelected;

@end
