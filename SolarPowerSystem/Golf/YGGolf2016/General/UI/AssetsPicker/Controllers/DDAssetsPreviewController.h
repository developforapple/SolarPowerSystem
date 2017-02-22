//
//  DDAssetsPreviewController.h
//  Golf
//
//  Created by bo wang on 16/8/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAsset.h"

@class DDAssetsPreviewController;

typedef void (^DDAssetsPreviewBlock)(DDAssetsPreviewController *ctrl,DDAsset *asset);

// 简单的图片预览控制器。作为子控制器使用。
@interface DDAssetsPreviewController : UICollectionViewController

@property (strong, nonatomic) NSArray<DDAsset *> *assets;

// 首次显示的索引位置
@property (assign, nonatomic) NSUInteger firstIndex;
// 当资源显示时是否有动画。默认为NO
@property (assign, nonatomic) BOOL animatedWhenAssetDisplay;

// 点击
@property (copy, nonatomic) DDAssetsPreviewBlock tapAction;
// 双击
@property (copy, nonatomic) DDAssetsPreviewBlock doubleTapAction;
// 长按
@property (copy, nonatomic) DDAssetsPreviewBlock longPressAction;
// 缩放
@property (copy, nonatomic) DDAssetsPreviewBlock zoomAction;
// 显示资源
@property (copy, nonatomic) DDAssetsPreviewBlock willDisplayAsset;

- (void)displayAsset:(DDAsset *)asset;
- (void)displayAssetAtIndex:(NSUInteger)index;
- (void)removeAssetAtIndex:(NSUInteger)index;

@end
