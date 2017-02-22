//
//  UIViewController+Storyboard.m
//
//
//  Created by Normal on 15/11/17.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "UIViewController+Storyboard.h"

// 使用 YYCache 或 PINCache 时将把storyboard名进行本地缓存
#if (__has_include(<YYCache/YYCache.h>) || __has_include("YYCache.h"))
    #import <YYCache/YYCache.h>
    typedef YYCache _YGCache;
#elif (__has_include(<PINCache/PINCache.h>) || __has_include("PINCache.h"))
    #import <PINCache/PINCache.h>
    typedef PINCache _YGCache;
#else
    typedef NSCache _YGCache;

    @interface NSCache (_category)
    @end
    @implementation NSCache (_category)
    - (instancetype)initWithName:(NSString *)name
    {
        NSCache *cache = [self init];
        cache.name = name;
        return cache;
    }
    @end
#endif

@implementation UIViewController (Storyboard)

+ (NSSet<NSString *> *)storyboardList
{
    static NSSet *kBundleStoryboardNameList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *list = [NSBundle pathsForResourcesOfType:@"storyboardc" inDirectory:[NSBundle mainBundle].resourcePath];
        
        NSMutableSet *tmp = [NSMutableSet set];
        for (NSString *path in list) {
            NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
            NSString *realName = [[name componentsSeparatedByString:@"~"] firstObject];
            if (realName.length > 0) {
                [tmp addObject:realName];
            }
        }
        kBundleStoryboardNameList = tmp;
    });
    return kBundleStoryboardNameList;
}

+ (_YGCache *)cache
{
    static _YGCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[_YGCache alloc] initWithName:@"com.cgit.golf.UIViewController+Storyboard"];
    });
    return cache;
}

/**
 *  尝试从以storyboardName为名的storyboard中取
 *
 *  @param storyboardName storyboard文件名
 *  @param identifier     查找的对象id
 *
 *  @return 查找到的UIViewController实例。如果没有找到，返回nil
 */
+ (instancetype)tryTakeOutInstanceFromStoryboardNamed:(NSString *)storyboardName identifier:(NSString *)identifier
{
    if (!storyboardName || !identifier) return nil;
    
    /**
     *  这里需要捕获异常，否则程序会crash
     */
    @try {
        static SEL sel;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //identifierToNibNameMap 是UIStoryboard的一个私有属性
            NSString *selStr = [NSString stringWithFormat:@"%@%@%@%@%@",@"identifier",@"To",@"Nib",@"Name",@"Map"];
            sel = NSSelectorFromString(selStr);
        });

        UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id obj = [sb performSelector:sel];
#pragma clang diagnostic pop
        if (obj && [obj isKindOfClass:[NSDictionary class]] && [[(NSDictionary *)obj allValues] containsObject:identifier]) {
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:identifier];
            return vc;
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (instancetype)instanceFromStoryboardWithIdentifier:(NSString *)identifier
{
    if (!identifier) return nil;
    
    // 取缓存的storyboard名
    _YGCache *cache = [self cache];
    NSString *cacheStoryboardName = (NSString *)[cache objectForKey:identifier];
    if (cacheStoryboardName) {
        id vc = [self tryTakeOutInstanceFromStoryboardNamed:cacheStoryboardName identifier:identifier];
        if (vc) {
            return vc;
        }
        // 缓存的name不再有效
        [cache removeObjectForKey:identifier];
    }
    
    // 未缓存，遍历storyboard文件名列表，开始尝试取出实例。
    NSSet<NSString *> *nameList = [self storyboardList];
    for (NSString *name in nameList) {
        UIViewController *instance = [self tryTakeOutInstanceFromStoryboardNamed:name identifier:identifier];
        if (instance) {
            // 成功获取实例后，对storyboard名进行缓存
            [cache setObject:name forKey:identifier];
            return instance;
        }
    }
    return nil;
}

+ (instancetype)instanceFromStoryboard
{
    return [self instanceFromStoryboardWithIdentifier:NSStringFromClass([self class])];
}

@end
