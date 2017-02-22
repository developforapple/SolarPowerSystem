//
//  YGUserDefaultsHelper.m
//  Golf
//
//  Created by 梁荣辉 on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGUserDefaultsHelper.h"

NSString *const kYGTAPublishRemberSyncFeedFlag = @"kYGTAPublishRemberSyncFeedFlag";
NSString *const kYGTAPublishRemberSyncWeixinFlag = @"kYGTAPublishRemberSyncWeixinFlag";

@implementation YGUserDefaultsHelper

// 由 key获得值
+ (id)getValueByKey:(NSString *) key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [userDefaults  objectForKey:key];
}

// 设置值
+ (void)setValue:(id)value forKey:(NSString *)key
{
    if (value && key) {
        
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:value forKey:key];
        [userDefaults synchronize];
    }
}

/**
 *  由key获取BOOL
 *
 *  @param key key
 *
 *  @return 对应BOOL
 */
+ (BOOL)getBoolValueByKey:(NSString *)key {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [userDefaults  boolForKey:key];
}

/**
 *  设置BOOL
 *
 *  @param boolValue BOOL值
 *  @param key       key
 */
+ (void)setBoolValue:(BOOL)boolValue forKey:(NSString *)key {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:boolValue forKey:key];
    [userDefaults synchronize];
}

/**
 *  清除某个key的值
 *
 *  @param key 需要清除的Key值
 */
+ (void)removeObjectForKey:(NSString *)key
{
    if (key != nil && [key length] > 0) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:key];
    }
}

/**
 *  在某个Key的后面追加用户Id
 *
 *  @return 返回key + 用户Id的新key值
 */
+ (NSString *)appendCurrentLoginUserIdInLast:(NSString *)key
{
    if (key != nil && [key length] > 0) {
//        key = [NSString stringWithFormat:@"%@_%d",key,[LoginManager sharedManager].session.memberId];
    }
    
    return key;
}


@end
