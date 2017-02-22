//
//  UIImage+scale.h
//  Golf
//
//  Created by user on 13-11-12.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

// 上传图片的大小，默认为500KB
#define kYGUploadImageDataSize               500.0

@interface UIImage (scale)

- (UIImage*)scaleToSize:(CGSize)size;

/**
 对图片相关裁剪

 @param image      图片数据
 @param imageOther 可以添加一个图片数据

 @return 返回裁剪好的图片
 */
- (UIImage *)ablongToSquareImage:(UIImage *)image image:(UIImage *)imageOther;

/**
 *  按大小压缩图片
 *
 *  @param toDataSize 要压缩的大小(单位为KB)
 *
 *  @return 返回压缩好的图片
 */
- (NSData *)scaleImageData:(UIImage *) sourceImage withDataSize:(double) toDataSize;


@end
