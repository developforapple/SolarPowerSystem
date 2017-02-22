//
//  DDAssetsManager.h
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAssetsInclude.h"
#import "DDAsset.h"

/**
 *  使用 AssetsLibrary 框架的manager
 */
@interface DDAssetsManager : NSObject

+ (BOOL)isPermissionDenied;

#pragma mark - Assets source
// 获取图片分组信息
+ (void)loadAssetsGroupsWithCompletion:(void (^)(NSArray<id <DDGroupProtocol>> *,NSError *error))completion;

// ALAssetsGroupType or PHAssetCollectionSubtype
+ (void)loadAssetsGroupType:(NSUInteger)type completion:(void (^)(id<DDGroupProtocol>, NSError *error))completion;

// 读取分组内的图片
+ (void)loadAssetsWithGroup:(id<DDGroupProtocol>)group completion:(void (^)(NSArray<DDAsset *> *)) completion;

- (instancetype)initWithExistAssets:(NSArray<DDAsset *> *)assets maxCount:(NSUInteger )count;

@property (readonly, assign, nonatomic) NSUInteger maxSelectCount;
@property (readonly, strong, nonatomic) NSMutableArray<DDAsset *> *selectedAssets;
@property (readonly, strong, nonatomic) NSNumber *kvoCount;

// 更新一个asset。
- (void)updateAsset:(DDAsset *)asset select:(BOOL)isSelect;
- (BOOL)isAssetSelected:(DDAsset *)asset;
- (DDAsset *)selectedAssetAtIndex:(NSInteger)index;
// 是否可以选择更多一个asset。会有一个提示
- (BOOL)canSelectMoreAsset;

// 当前资源库中的assets
@property (strong, nonatomic) NSArray <DDAsset *> *curAssets;

// ALAssetsGroupType or PHAssetCollectionSubtype
@property (assign, nonatomic) NSUInteger curGroupType;
// ALAssetsGroup or PHAssetColleciton
@property (strong, nonatomic) id<DDGroupProtocol> curGroup;

// 根据索引取得资源。在传入index之前，需要考虑是否会显示camera。
- (DDAsset *)assetAtIndex:(NSUInteger)index;
// 一个资源的索引。没有找到返回NSNotFound
- (NSUInteger)indexOfAsset:(DDAsset *)asset;

@end
