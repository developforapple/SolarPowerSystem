//
//  YGCacheDataHelper.m
//  Golf
//
//  Created by 梁荣辉 on 2016/10/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCacheDataHelper.h"
#import "YYCache.h"

// 缓存全部球场的DB名称
NSString *const kYGGolfClubAllListDBName = @"YGGolfClubAllListDB";

// 缓存的球会Model数据Key值
NSString *const kYGSearchClubModelKeyName = @"kYGSearchClubModel";

// 缓存球会的最后拉取时间
NSString *const kYGGolfClubLastUpdateTimeKey = @"kYGGolfClubLastUpdateTimeKey";

@interface YGCacheDataHelper ()

@property (strong, nonatomic) YYDiskCache *cache;

@end

@implementation YGCacheDataHelper

+ (instancetype)shared
{
    static YGCacheDataHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [YGCacheDataHelper new];
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
        basePath = [basePath stringByAppendingPathComponent:@"YGCache"];
        helper.cache = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:kYGGolfClubAllListDBName]];
    });
    return helper;
}

/**
 缓存所有的球场信息
 
 @param searchClubModelArray 球场信息
 */
-(void) cacheAllSearchClubModel:(NSMutableArray *) searchClubModelArray
{
    if (searchClubModelArray && [searchClubModelArray count] > 0) {
        ygweakify(self)
        RunOnGlobalQueue(^{
            ygstrongify(self)
            for (SearchClubModel *model in searchClubModelArray) {
                @autoreleasepool {
                    if (model && [model isKindOfClass:[SearchClubModel class]]) {
                        NSString *keyName = [NSString stringWithFormat:@"%@%d",kYGSearchClubModelKeyName,model.clubId];
                        [self.cache setObject:model forKey:keyName withBlock:^{}];
                    }
                }
            }
        });
    }
}

/**
 根据球场Id获取缓存的球场信息
 
 @param clubId 球场Id
 */
- (SearchClubModel *) getCacheSearchClubModelByClubId:(int) clubId
{
    SearchClubModel *model = nil;
    NSString *keyName = [NSString stringWithFormat:@"%@%d",kYGSearchClubModelKeyName,clubId];
    if (keyName && [self.cache containsObjectForKey:keyName]) {
        model = (SearchClubModel *)[self.cache objectForKey:keyName];
    }
    
    return model;
}

@end
