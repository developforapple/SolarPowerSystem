//
//  DDAssetsViewController.h
//  QuizUp
//
//  Created by Normal on 15/12/5.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsInclude.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDAssetsPicker : UINavigationController

+ (instancetype)instanceFromStoryboard;

/**
 *  present之前传入上一次被选中的assets数据.
 *  类型为DDAsset。包含 ALAsset 和 UIImage
 */
@property (nullable, strong, nonatomic) NSArray<DDAsset *> *existAssets;

/**
 选择从相机拍摄图片时是否显示编辑 默认为NO
 */
@property (assign, nonatomic) BOOL allowsEditingCameraImage;

/**
 *  最大可选数量。默认为0，不限制数量。
 */
@property (nonatomic) NSUInteger maxSelectCount;

/**
 *  当选择的资源数量达到了 maxSelectCount 时，自动回调。默认YES。
 *  当 maxSelectCount 为0时忽略这个属性。
 *  当从摄像头获取图片时，忽略这个属性，总是自动回调。
 */
@property (nonatomic) BOOL autoCallbackWhenSelectedEnoughAssets;

/**
 *  完成资源选择时的回调。
 *  @warning DDAssetsPicker 不会自动隐藏。
 */
@property (nullable, copy, nonatomic) void (^didSelectedAssetsBlock)(DDAssetsPicker *picker,NSArray<DDAsset *> *assets);

#pragma mark - Camera
/**
 *  是否显示摄像头。默认为YES
 */
@property (getter=isDisplayCamera, nonatomic) BOOL displayCamera;

/**
 *  是否显示摄像头实时画面。默认为NO，当 displayCamera为NO时忽略此属性。
 */
@property (getter=isDisplayRealtimePicture, nonatomic) BOOL displayRealtimePicture;


#pragma mark - UNAVAILABLE
// 唯一初始化方法 +instanceFromStoryboard
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNavigationBarClass:(nullable Class)navigationBarClass toolbarClass:(nullable Class)toolbarClass NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
