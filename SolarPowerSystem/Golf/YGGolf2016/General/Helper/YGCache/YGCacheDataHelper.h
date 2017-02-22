//
//  YGCacheDataHelper.h
//  Golf
//
//  Created by 梁荣辉 on 2016/10/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 缓存全部球场的DB名称
extern NSString *const kYGGolfClubAllListDBName;

// 缓存的球会Model数据Key值
extern NSString *const kYGSearchClubModelKeyName;

// 缓存球会的最后拉取时间
extern NSString *const kYGGolfClubLastUpdateTimeKey;


@interface YGCacheDataHelper : NSObject

+ (instancetype)shared;

/**
 缓存所有的球场信息

 @param searchClubModelArray 球场信息
 */
-(void) cacheAllSearchClubModel:(NSMutableArray *) searchClubModelArray;

/**
 根据球场Id获取缓存的球场信息

 @param clubId 球场Id
 */
-(SearchClubModel *) getCacheSearchClubModelByClubId:(int) clubId;

@end
