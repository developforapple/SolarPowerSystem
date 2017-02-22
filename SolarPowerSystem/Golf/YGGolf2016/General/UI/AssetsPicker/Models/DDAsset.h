//
//  DDAsset.h
//  QuizUp
//
//  Created by Normal on 15/12/8.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYImage/YYImage.h>

@class ALAsset;
@class PHAsset;
@class DDAsset;

@protocol DDAssetProtocol <NSObject>
@required
// 生成合适的二进制数据
- (NSData *)uploadImageData;
// 生成缩略图。虽然是block返回，但是block是同步调用的。
- (void)thumbnailImage:(void(^)(UIImage *))callback;    //默认屏幕四分之一宽度的正方形大小
- (void)thumbnailImageRef:(void (^)(CGImageRef))callback;
- (void)thumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *))callback;
- (void)thumbnailImageRefWithSize:(CGSize)size completion:(void (^)(CGImageRef))callback;
// 生成预览图。callback为同步调用。可能从iCloud中获取图片，所以本方法需要在子线程中调用。
- (void)previewImage:(void(^)(UIImage *))callback;
// 是否是gif
- (BOOL)isGif;
// 尺寸
- (CGSize)size;
// 两个资源是否一致
- (BOOL)isEqualToAsset:(id<DDAssetProtocol>)object;
@end

/*!
 *  对各种图片资源的封装。
 */
@interface DDAsset : NSObject <DDAssetProtocol>

+ (instancetype)assetWithALAsset:(ALAsset *)asset; //iOS7相册资源
+ (instancetype)assetWithPHAsset:(PHAsset *)asset; //iOS8相册资源
+ (instancetype)assetWithImage:(UIImage *)image;   //UIImage资源
+ (instancetype)assetWithURL:(NSURL *)URL;         //网络图片
+ (instancetype)assetWithModel:(id<DDAssetProtocol>)imageModel;//自定义的图片模型

@property (strong, nonatomic) ALAsset *alAsset;
@property (strong, nonatomic) PHAsset *phAsset;
@property (strong, nonatomic) UIImage *imageAsset;
@property (strong, nonatomic) NSURL *URLAsset;
@property (strong, nonatomic) id<DDAssetProtocol> entityAsset;

// 请求预览图时将会更新下面两个属性。
@property (assign, nonatomic) BOOL isInCloud;   //是否是iCloud图片
@property (assign, nonatomic) BOOL needRequestFullImage;//需要向iCloud请求完整的图片
@property (assign, nonatomic) CGFloat progress; //iCloud图片下载进度

@property (assign, nonatomic) CGSize thumnailSize; //默认时为屏幕宽度/4的正方形
@end
