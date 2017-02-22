//
//  APIClient.h
//  Golf
//
//  Created by 黄希望 on 15/7/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//
#import "AFHTTPSessionManager.h"

@interface APIClient : AFHTTPSessionManager

// 创建单例对象
+ (instancetype)sharedClient;

// 抛出错误
+ (HttpErroCodeModel *)errorWithAFHTTPRequestOperation:(NSDictionary *)operation error:(NSError *)error;


/**
 *  生成md5加密串
 *
 *  @param mode     接口名
 *  @param params   参数列表
 *  @param encrypt  是否加密
 *
 *  @return 生成md5加密串
 */
+ (NSString *)md5ParamsWithMode:(NSString*)mode params:(NSDictionary *)params;

/**
 *  生成urlstring
 *
 *  @param mode     接口名
 *  @param params   参数列表
 *  @param encrypt  是否加密
 *
 *  @return urlstring
 */
+ (NSString *)urlStringWithMode:(NSString*)mode params:(NSDictionary *)params;

@end
