//
//  DDAssetsInclude.h
//  JuYouQu
//
//  Created by Normal on 15/12/10.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#ifndef DDAssetsInclude_h
#define DDAssetsInclude_h

#import <AssetsLibrary/AssetsLibrary.h>

#import "DDAsset.h"
#import "DDAssetCategory.h"

/**
 *  是否支持Gif。
 *  如果支持。需要导入 SDWebImage 中的 UIImage+GIF.h 
 */
#ifndef DDSUPPORTGIF
    #define DDSUPPORTGIF 0 //0
#endif

#if DDSUPPORTGIF
    #import "DDGifSupport.h"
    #import <UIImage+GIF.h>
#endif

#ifndef RGBColor
#define RGBColor(R,G,B,A) [UIColor colorWithRed:(R)/255.f green:(G)/255.f blue:(B)/255.f alpha:(A)]
#endif
#ifndef iOS6
    #define iOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.f ? YES : NO)
#endif
#ifndef iOS7
    #define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f ? YES : NO)
#endif
#ifndef iOS8
    #define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.f ? YES : NO)
#endif
#ifndef iOS9
    #define iOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.f ? YES : NO)
#endif

FOUNDATION_EXTERN NSString *const kDDAssetsManagerSelectedAssetsCountChangedNotification;

#ifndef ddweakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define ddweakify(object) @autoreleasepool{} __weak __typeof__(object) weak##_##object = object
        #else
            #define ddweakify(object) @autoreleasepool{} __block __typeof__(object) block##_##object = object
        #endif
    #else
        #if __has_feature(objc_arc)
            #define ddweakify(object) @try{} @finally{} {} __weak __typeof__(object) weak##_##object = object
        #else
            #define ddweakify(object) @try{} @finally{} {} __block __typeof__(object) block##_##object = object
        #endif
    #endif
#endif

#ifndef ddstrongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define ddstrongify(object) @autoreleasepool{} __typeof__(object) object = weak##_##object
        #else
            #define ddstrongify(object) @autoreleasepool{} __typeof__(object) object = block##_##object
        #endif
    #else
        #if __has_feature(objc_arc)
            #define ddstrongify(object) @try{} @finally{} __typeof__(object) object = weak##_##object
        #else
            #define ddstrongify(object) @try{} @finally{} __typeof__(object) object = block##_##object
        #endif
    #endif
#endif

#endif /* DDAssetsInclude_h */
