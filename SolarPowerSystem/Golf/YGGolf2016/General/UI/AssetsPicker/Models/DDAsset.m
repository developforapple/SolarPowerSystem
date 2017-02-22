//
//  DDAsset.m
//  QuizUp
//
//  Created by Normal on 15/12/8.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define kReferWidth 960.f
#define kReferHeight 1280.f

#define PHRequest [PHImageManager defaultManager]

@interface ALAsset (Protocol)

- (NSData *)uploadImageData;

- (BOOL)isGif;

@end

@interface DDAsset ()
@property (strong, nonatomic) UIImage *thumbnailImage;
@end

@implementation DDAsset

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.thumnailSize = CGSizeMake(Device_Width/4, Device_Width/4);
    }
    return self;
}

+ (instancetype)assetWithALAsset:(ALAsset *)asset
{
    DDAsset *instance = [DDAsset new];
    instance.alAsset = asset;
    return instance;
}

+ (instancetype)assetWithPHAsset:(PHAsset *)asset
{
    DDAsset *instance = [DDAsset new];
    instance.phAsset = asset;
    return instance;
}

+ (instancetype)assetWithImage:(UIImage *)image
{
    DDAsset *instance = [DDAsset new];

    UIImage *i3;
    if (image.size.width < kReferWidth || image.size.height < kReferHeight) {
        i3 = [image imageByResizeToSize:image.size contentMode:UIViewContentModeScaleAspectFit];
    }else{
        CGRect rect = YYCGRectFitWithContentMode(CGRectMake(0, 0, kReferWidth, kReferHeight),image.size,UIViewContentModeScaleAspectFit);
        UIImage *i2 = [image imageByResizeToSize:CGSizeMake(kReferWidth, kReferHeight) contentMode:UIViewContentModeScaleAspectFit];
        i3 = [i2 imageByCropToRect:rect];
    }
    
    instance.imageAsset = i3;
    instance.thumnailSize = [instance.imageAsset size];
    return instance;
}

+ (instancetype)assetWithURL:(NSURL *)URL
{
    DDAsset *instance = [DDAsset new];
    instance.URLAsset = URL;
    return instance;
}

+ (instancetype)assetWithModel:(id<DDAssetProtocol>)imageModel
{
    DDAsset *instance = [DDAsset new];
    instance.entityAsset = imageModel;
    return instance;
}

#pragma mark - Protocol
- (NSData *)uploadImageData
{
    __block NSData *data;
    
    if (self.alAsset) {
        data = [self.alAsset uploadImageData];
    }else if(self.phAsset){
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = YES;
        options.synchronous = YES;
        
        [PHRequest requestImageDataForAsset:self.phAsset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
            data = imageData;
        }];
    }else if (self.imageAsset){
        data = [self.imageAsset yy_imageDataRepresentation];
    }else if (self.URLAsset){
        data = nil;//TODO 读取缓存
    }else if (self.entityAsset){
        data = [self.entityAsset uploadImageData];
    }
    return data;
}

- (void)thumbnailImage:(void(^)(UIImage *))callback
{
    [self thumbnailImageWithSize:self.thumnailSize completion:callback];
}

- (void)thumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *))callback
{
    [self thumbnailImageRefWithSize:size completion:^(CGImageRef ref) {
        if (callback) {
            callback([UIImage imageWithCGImage:ref]);
        }
    }];
}

- (void)thumbnailImageRef:(void (^)(CGImageRef))callback
{
    [self thumbnailImageRefWithSize:self.thumnailSize completion:callback];
}

- (void)thumbnailImageRefWithSize:(CGSize)size completion:(void (^)(CGImageRef))callback
{
    [self thumbnailImageRefWithSize:size crop:YES completion:callback];
}

- (void)thumbnailImageRefWithSize:(CGSize)size crop:(BOOL)crop completion:(void (^)(CGImageRef))callback
{
    CGImageRef ref;
    if (self.alAsset) {
        
        if (crop) {
            ref = self.alAsset.thumbnail;
        }else{
            ref = self.alAsset.aspectRatioThumbnail;
        }
        callback?callback(ref):0;
    }else if (self.phAsset){
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.networkAccessAllowed = YES;
        options.synchronous = YES;
        
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        size.width *= screenScale;
        size.height *= screenScale;
        
        [PHRequest requestImageForAsset:self.phAsset
                             targetSize:size
                            contentMode:crop?PHImageContentModeAspectFill:PHImageContentModeDefault
                                options:options
                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                    CGImageRef imageRef = result.CGImage;
                                    if (imageRef && callback) {
                                        callback(imageRef);
                                    }
                                }];
    }else if(self.imageAsset){
        ref = self.imageAsset.CGImage;
        callback?callback(ref):0;
    }else if(self.URLAsset){
        //TODO
    }else if(self.entityAsset){
        //TODO
    }
}

- (void)previewImage:(void(^)(UIImage *img))callback
{
    if (self.alAsset) {
        CGImageRef ref = [self.alAsset.defaultRepresentation fullScreenImage];
        callback?callback([UIImage imageWithCGImage:ref]):0;
    }else if(self.phAsset){
        
        
        // 图片缩放规则
        
        // 1 参考宽度960 参考高度 1280。 参照微信。
        // 2 如果宽高有一项小于参考尺寸，图片不缩放。使用原图
        // 3 宽高均大于参考尺寸时，图片进行缩放。缩放目标尺寸的大小根据以下规则来定
        // 4 如果宽/高 大于 960/1280 那么目标尺寸高度为参考高度，宽度根据图片比例进行缩放
        // 5 否则，目标尺寸宽度为参考宽度，高度根据图片比例进行缩放
        
        ygweakify(self);
        void (^callCallbackBlock)(UIImage *image,void(^callback)(UIImage *)) = ^(UIImage *image,void(^theCallback)(UIImage *)){
            ygstrongify(self);
            if (!image) {
                // 没取到目标图片，使用缩略图
                [self thumbnailImage:^(UIImage *result2) {
                    if (result2 && theCallback) {
                        theCallback(result2);
                    }
                }];
            }else if(theCallback){
                theCallback(image);
            }
        };
        
        static CGFloat referWidth = kReferWidth;
        static CGFloat referHeight = kReferHeight;
        CGFloat referRatio = referWidth/referHeight;
        
        CGFloat width = self.phAsset.pixelWidth;
        CGFloat height = self.phAsset.pixelHeight;
        
        if (width > referWidth && height > referHeight) {
            // 缩放
            
            CGFloat targetSizeWidth,targetSizeHeight;
            
            if (width / height > referRatio) {
                //以高为准
                targetSizeWidth = CGFLOAT_MAX;
                targetSizeHeight = referHeight;
            }else{
                targetSizeWidth = referWidth;
                targetSizeHeight = CGFLOAT_MAX;
            }
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.networkAccessAllowed = YES;
            options.synchronous = YES;
            
            [PHRequest requestImageForAsset:self.phAsset
                                 targetSize:CGSizeMake(targetSizeWidth, targetSizeHeight)
                                contentMode:PHImageContentModeAspectFit
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  UIImage *fixImage = [self fixOrientation:result];
                                  self.isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
                                  self.needRequestFullImage = !fixImage;
                                  callCallbackBlock(fixImage,callback);
                              }];
            
        }else{
            //原始图片
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            options.networkAccessAllowed = YES;
            [PHRequest requestImageForAsset:self.phAsset
                                 targetSize:PHImageManagerMaximumSize
                                contentMode:PHImageContentModeDefault
                                    options:options
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  UIImage *fixImage = [self fixOrientation:result];
                                  self.isInCloud = [info[PHImageResultIsInCloudKey] boolValue];
                                  self.needRequestFullImage = !fixImage;
                                  callCallbackBlock(fixImage,callback);
                              }];
        }
        
    }else if(self.imageAsset){
        callback?callback(self.imageAsset):0;
    }else{
        //TODO
    }
}

- (UIImage *)fixOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;

    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (BOOL)isGif
{
    //TODO
    return NO;
    
//    if (self.alAsset) {
//        return [self.alAsset isGif];
//    }
//    return self.imageAsset.animatedImageFrameCount>1;
}

- (CGSize)size
{
    //TODO
    return CGSizeZero;
    
//    if (self.libraryAsset) {
//        return [self.libraryAsset defaultRepresentation].dimensions;
//    }
//    return self.imageAsset.size;
}

- (BOOL)isEqualToAsset:(DDAsset *)object
{
    if (self.alAsset) {
        if (!object.alAsset) return NO;
        
        NSString *URL = [[self.alAsset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        NSString *URL2 = [[object.alAsset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
        
        return !URL && !URL2 && [URL isEqualToString:URL2];
    }
    
    if (self.phAsset){
        if (!object.phAsset) return NO;
        
        return [[self.phAsset localIdentifier] isEqualToString:[object.phAsset localIdentifier]];
    }
    
    if (self.imageAsset){
        if (!object.imageAsset) return NO;
        
        return [self.imageAsset isEqual:object.imageAsset];
    }
    
    if (self.URLAsset){
        if (!object.URLAsset) return NO;
        
        return [self.URLAsset.absoluteString isEqualToString:object.URLAsset.absoluteString];
    }
    
    if(self.entityAsset){
        if (!object.entityAsset) return NO;
        
        return [self.entityAsset isEqualToAsset:object.entityAsset];
    }
    
    return [super isEqual:object];
}

@end

@implementation ALAsset (Protocol)

- (NSData *)uploadImageData
{
    @autoreleasepool {
        
        ALAssetRepresentation *re = self.defaultRepresentation;
        CGSize size = re.dimensions;
        if (self.isGif || size.width == 0) {
            NSData *data = [self data];
            return data;
        }
        
        UIImage *frImage = [UIImage imageWithCGImage:re.fullResolutionImage scale:re.scale orientation:(UIImageOrientation)(re.orientation)];
        CGSize frImageSize = frImage.size;
        
        CGFloat maxH = Device_Height * 2;
        CGFloat maxW = Device_Width * 3;
        
        CGFloat frImageRatio = frImageSize.height / frImageSize.width;
        CGFloat maxRatio = maxH / maxW;
        
        //
        //      |   | 5 /
        //      | 3 |  /
        //      |   | /
        //      |   |/  6
        //  maxH|---------
        //      |1 /|
        //      | / |   4
        //      |/ 2|
        //      ----------
        //         maxW
        //    根据不同的尺寸大小和比例 执行不同的图片压缩策略。 尺寸按照 屏幕宽*3 和屏幕高*2 来划分
        //    1~4不需要压缩尺寸 5 6需要压缩尺寸
        //    1 2 为小图。预设data压缩比 0.9
        //    3 4 为长图和宽图 预设data压缩比 0.65
        //    5 6 为大图   预设data压缩比 0.8
        
        enum ResizeType {
            ResizeType_1 = 1,   // w <= max h <= max ratio > max
            ResizeType_2,       // w <= max h <= max ratio <= max
            ResizeType_3,       // w <= max h > max
            ResizeType_4,       // w > max  h <= max
            ResizeType_5,       // w > max  h > max  ratio > max
            ResizeType_6,       // w > max  h > max  ratio <= max
        };
        
        BOOL wFlag = frImageSize.width <= maxW;
        BOOL hFlag = frImageSize.height <= maxH;
        BOOL ratioFlag = frImageRatio <= maxRatio;
        
        enum ResizeType type = ResizeType_1;
        if (wFlag) {
            
            if (hFlag && ratioFlag) {
                type = ResizeType_2;
            }else if (!hFlag){
                type = ResizeType_3;
            }
        }else{
            
            if (hFlag) {
                type = ResizeType_4;
            }else{
                if (!ratioFlag) {
                    type = ResizeType_5;
                }else{
                    type = ResizeType_6;
                }
            }
        }
        
        NSData *data;
        
        CGFloat compressionQuality = 1.f;
        switch (type) {
            case ResizeType_1:
            case ResizeType_2:{
                compressionQuality = 0.9f;
                
                data = UIImageJPEGRepresentation(frImage, compressionQuality);
                NSLog(@"上传的图片大小：%.2f kb。 压缩比：%.2f 实际压缩：%.2f",data.length/1024.f,compressionQuality,(CGFloat)data.length/re.size);
                
            }break;
            case ResizeType_3:
            case ResizeType_4:{
                compressionQuality = 0.65f;
                
                data = UIImageJPEGRepresentation(frImage, compressionQuality);
                NSLog(@"上传的图片大小：%.2f kb。 压缩比：%.2f 实际压缩：%.2f",data.length/1024.f,compressionQuality,(CGFloat)data.length/re.size);
                
            }break;
            case ResizeType_5:
            case ResizeType_6:{
                compressionQuality = 0.8f;
                
                CGFloat resizeW = 0.f;
                CGFloat resizeH = 0.f;
                
                if (ratioFlag) {
                    resizeH = maxH;
                    resizeW = resizeH / frImageRatio;
                }else{
                    resizeW = maxW;
                    resizeH = frImageRatio * resizeW;
                }
                UIGraphicsBeginImageContext(CGSizeMake(resizeW, resizeH));
                [frImage drawInRect:CGRectMake(0, 0, resizeW, resizeH)];
                UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                data = UIImageJPEGRepresentation(reSizeImage, compressionQuality);
                NSLog(@"上传的图片大小：%.2f kb 压缩比：%.2f 实际压缩:%.2f 尺寸：%.0f*%.0f",data.length/1024.f,compressionQuality,(CGFloat)data.length/re.size,resizeW,resizeH);
            }   break;
            default:break;
        }
        return data;
    }
}

- (BOOL)isGif
{
    ALAssetRepresentation *re = [self representationForUTI: (__bridge NSString *)kUTTypeGIF];
    return (BOOL)re;
}

- (nullable NSData *)data
{
    ALAssetRepresentation *re = [self defaultRepresentation];
    long long size = re.size;
    uint8_t *buffer = malloc(size);
    NSError *error;
    NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
    NSData *data = [NSData dataWithBytes:buffer length:bytes];
    free(buffer);
    return data;
}

@end
