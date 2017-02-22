//
//  YGUserDefaultsHelper.h
//  Golf
//
//  Created by 梁荣辉 on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 发布教学档案 同步到社区 记忆 key值【拼接用户Id】
extern NSString *const kYGTAPublishRemberSyncFeedFlag;
extern NSString *const kYGTAPublishRemberSyncWeixinFlag;

@interface YGUserDefaultsHelper : NSObject

// 由 key获得值
+ (id)getValueByKey:(NSString *) key;

// 设置值
+ (void)setValue:(id)value forKey:(NSString *)key;

/**
 *  由key获取BOOL
 *
 *  @param key key
 *
 *  @return 对应BOOL
 */
+ (BOOL)getBoolValueByKey:(NSString *)key;

/**
 *  设置BOOL
 *
 *  @param boolValue BOOL值
 *  @param key       key
 */
+ (void)setBoolValue:(BOOL)boolValue forKey:(NSString *)key;

/**
 *  清除某个key的值
 *
 *  @param key 需要清除的Key值
 */
+ (void)removeObjectForKey:(NSString *)key;

/**
 *  在某个Key的后面追加用户Id
 *
 *  @return 返回key + 用户Id的新key值
 */
+ (NSString *)appendCurrentLoginUserIdInLast:(NSString *)key;

@end
