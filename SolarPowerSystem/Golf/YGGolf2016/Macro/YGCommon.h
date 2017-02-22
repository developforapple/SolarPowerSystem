//
//  YGCommon.h
//  Golf
//
//  Created by wwwbbat on 16/5/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGCommon_h
#define YGCommon_h

#pragma mark - Block weakify self
#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>) || \
    __has_include(<libextobjc/EXTScope.h>)
    #ifndef ygweakify
        #define ygweakify(...) @weakify(__VA_ARGS__)
    #endif  /*ygweakify*/
    #ifndef ygstrongify
        #define ygstrongify(...) @strongify(__VA_ARGS__)
    #endif  /*ygstrongify*/
#else
    #ifndef ygweakify
        #if DEBUG
            #define ygweakify(object) @autoreleasepool{} __weak __typeof__(object) weak##_##object = object
        #else
            #define ygweakify(object) @try{} @finally{} {} __weak __typeof__(object) weak##_##object = object
        #endif  /*DEBUG*/
    #endif  /*ygweakify*/
    #ifndef ygstrongify
        #if DEBUG
            #define ygstrongify(object) @autoreleasepool{} __typeof__(object) object = weak##_##object
        #else   /*DEBUG*/
            #define ygstrongify(object) @try{} @finally{} __typeof__(object) object = weak##_##object
        #endif  /*ygstrongify*/
    #endif
#endif  /*__has_include(<ReactiveCocoa/ReactiveCocoa.h>)*/

#pragma mark - Device

#define Device_Width  (CGRectGetWidth([UIScreen mainScreen].bounds))
#define Device_Height (CGRectGetHeight([UIScreen mainScreen].bounds))
#define Device_SysVersion  ([UIDevice currentDevice].systemVersion.floatValue)
#define Device_Model ([UIDevice currentDevice].model)

#define IS_iPhone_UI (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IS_iPad_UI (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#define IS_Simulator ([Device_Model containsString:@"simulator"])
#define IS_iPhone ([Device_Model containsString:@"iPhone"])
#define IS_iPad ([Device_Model containsString:@"iPad"])
#define IS_iPod ([Device_Model containsString:@"iPod"])

#define IS_3_5_INCH_SCREEN (IS_iPhone_UI && ((int)MAX(Device_Width, Device_Height)<568))
#define IS_4_0_INCH_SCREEN (IS_iPhone_UI && ((int)MAX(Device_Width, Device_Height)==568))
#define IS_4_7_INCH_SCREEN (IS_iPhone_UI && ((int)MAX(Device_Width, Device_Height)==667))
#define IS_5_5_INCH_SCREEN (IS_iPhone_UI && ((int)MAX(Device_Width, Device_Height)>667))

#define iOSLater(v) (Device_SysVersion >= (float)(v))
#define iOS7    (Device_SysVersion >= 7.0f)
#define iOS8    (Device_SysVersion >= 8.0f)
#define iOS9    (Device_SysVersion >= 9.0f)
#define iOS10   (Device_SysVersion >= 10.0f)

// 在BuildSetting的Preprocessor Macros中定义了 LOG_SUPPORT
#if LOG_SUPPORT
#define NSLog(format, ...) do {                                             \
    fprintf(stderr, "<%s : %d> %s",                                           \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __func__);                                                        \
    (NSLog)((format), ##__VA_ARGS__);                                           \
    fprintf(stderr, "       \n");                                               \
    } while (0)
#else
    #define NSLog(...)
#endif

#pragma mark - Convenient Macro

// 确保在max和min确定的范围内取值
#define Confine(value,maxV,minV) (MAX((minV),MIN((maxV),(value))))
#define Equal(A,B) ([(A) isEqualToString:(B)])

#ifndef RGBColor
// RGBA颜色
NS_INLINE UIColor *RGBColor(int R,int G,int B,float A){
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_9_3  //Xcode8环境下的SDK
//    if (iOS10) {
//        return [UIColor colorWithDisplayP3Red:R/255.f green:G/255.f blue:B/255.f alpha:A];
//    }
    return [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A];
#else   //Xcode7及之前版本的SDK
    return [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A];
#endif
}
#endif

#define RandomColor RGBColor(arc4random_uniform(255),arc4random_uniform(255),arc4random_uniform(255),1)

// 在主线程执行block
NS_INLINE void RunOnMainQueue(dispatch_block_t x){
    if ([NSThread isMainThread]){ if (x)x(); }else dispatch_async(dispatch_get_main_queue(),x);
}

// 在通用子线程执行block
NS_INLINE void RunOnGlobalQueue(dispatch_block_t x){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), x);
}

// 在主线程延迟若干秒执行block
NS_INLINE void RunAfter(NSTimeInterval time,dispatch_block_t x){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((time) * NSEC_PER_SEC)), dispatch_get_main_queue(), x);
}

typedef void(^BlockReturn)(id data);  // 通用Block回调
typedef id (^BlockReturnValue)(id data);

#pragma mark - YYModel
// YYModel 实现 NSCoding NSCopying hash euqal的方法
#define YYModelDefaultCode -(void)encodeWithCoder:(NSCoder*)aCoder{[self yy_modelEncodeWithCoder:aCoder];}-(id)initWithCoder:(NSCoder*)aDecoder{self=[super init];return [self yy_modelInitWithCoder:aDecoder];}-(id)copyWithZone:(NSZone *)zone{return[self yy_modelCopy];}-(NSUInteger)hash{return[self yy_modelHash];}-(BOOL)isEqual:(id)object{return [self yy_modelIsEqual:object];}

#pragma mark - Swizzle
#ifndef DDSwizzleMethod
// 快速添加方法转换的类方法
#define DDSwizzleMethod +(void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector{Method originalMethod = class_getInstanceMethod(self, originalSelector);Method newMethod = class_getInstanceMethod(self, newSelector);BOOL methodAdded = class_addMethod([self class],originalSelector,method_getImplementation(newMethod),method_getTypeEncoding(newMethod));if (methodAdded){class_replaceMethod([self class],newSelector,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));}else{method_exchangeImplementations(originalMethod, newMethod);}}
#endif //DDSwizzleMethod

#endif /* YGCommon_h */


