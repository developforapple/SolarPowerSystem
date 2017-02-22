//
//  DDAssetsDetailViewController.h
//  QuizUp
//
//  Created by Normal on 15/12/9.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsManager.h"

@interface DDAssetsDetailViewController : UIViewController

// 资源管理
@property (strong, nonatomic) DDAssetsManager *manager;

// 预览模式，只显示被选中的资源。默认为NO。
@property (assign, nonatomic) BOOL onlyDisplaySelectedAssets;

/**
 *  显示详情页时立即显示的cell的index。默认为0。
 */
@property (nonatomic) NSUInteger firstDisplayedIndex;

#pragma mark 
// 资源选中状态更改的回调。在block里需要将asset加入或者移除出manager
@property (copy, nonatomic) void (^assetSelectedChanged)(DDAsset *asset, BOOL isSelected);
// 发送按钮的回调
@property (copy, nonatomic) void (^sendAction)(void);

@end
