//
//  UIImage+scale.m
//  Golf
//
//  Created by user on 13-11-12.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

- (UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)ablongToSquareImage:(UIImage *)image image:(UIImage *)imageOther
{
    CGSize size;
    CGSize imageSize=image.size;
    CGPoint point;
    if (imageSize.width/imageSize.height > 1) {
        point.x=(imageSize.height-imageSize.width)/2;
        point.y=0;
        size.height=imageSize.height;
        size.width=imageSize.height;
    }else{
        point.x=0;
        point.y=(imageSize.width-imageSize.height)/2;
        size.height=imageSize.width;
        size.width=imageSize.width;
    }
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(point.x, point.y, size.width-point.x*2, size.height-point.y*2);
    [image drawInRect:rect];
    CGFloat a = MIN(size.width, size.height)/2;
    [imageOther drawInRect:CGRectMake(a/2, a/2, a, a)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSData *)scaleImageData:(UIImage *) sourceImage withDataSize:(double) toDataSize
{
    NSData *scaleImageData = nil;
    if (sourceImage) {
        //压缩比例
        NSData *sourceImageData = UIImageJPEGRepresentation(sourceImage,1);
        
        // 特别注意，这里是字节数
        double sourceImageByteSize = [sourceImageData length];
        
        // 要压缩的比例
        if (toDataSize <= 0) {
            toDataSize = kYGUploadImageDataSize;
        }
        
        //根据图片上传的大小计算比例
        double scaleSize = toDataSize * 1024.0f / sourceImageByteSize;
        
        // 如果大于1，直接取1.0，即取原图
        if(scaleSize >= 1.0){
            scaleSize = 1.0;
        }
        
        // 压缩图片，把压缩好的图片返回回去
        if (sourceImageData) {
            scaleImageData = UIImageJPEGRepresentation(sourceImage,scaleSize);//压缩比例
        }
        
    }
    return scaleImageData;
}


@end
