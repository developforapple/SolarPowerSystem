//
//  NSData+HKPDataImage.m
//  LekuIndiana
//
//  Created by FlyGo on 16/2/25.
//  Copyright © 2016年 HKP_FlyGo. All rights reserved.
//

#import "NSData+HKPDataImage.h"

@implementation NSData (HKPDataImage)

/**
 *  缩放图片数据
 *
 *  @param imageData 图片数据
 *  @param toWidth   宽
 *  @param toHeight  高
 *
 *  @return 返回图片数据对象
 */
-(NSData *)scaleData:(NSInteger)toWidth toHeight:(NSInteger)toHeight
{
    NSData *imageData = self;
    if (!imageData) {
        return imageData;
    }
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    NSInteger width = 0;
    NSInteger height = 0;
    NSInteger x = 0;
    NSInteger y = 0;
    
    if (image.size.width<toWidth){
        width = toWidth;
        height = image.size.height*(toWidth/image.size.width);
        y = (height - toHeight)/2;
    }else if (image.size.height<toHeight){
        height = toHeight;
        width = image.size.width*(toHeight/image.size.height);
        x = (width - toWidth)/2;
    }else if (image.size.width>toWidth){
        width = toWidth;
        height = image.size.height*(toWidth/image.size.width);
        y = (height - toHeight)/2;
    }else if (image.size.height>toHeight){
        height = toHeight;
        width = image.size.width*(toHeight/image.size.height);
        x = (width - toWidth)/2;
    }else{
        height = toHeight;
        width = toWidth;
    }
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize subImageSize = CGSizeMake(toWidth, toHeight);
    CGRect subImageRect = CGRectMake(x, y, toWidth, toHeight);
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, subImageRect);
    UIGraphicsBeginImageContext(subImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subImageRect, subImageRef);
    UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    NSData *data = UIImageJPEGRepresentation(subImage,0.9);
    
    return data;
}


@end
