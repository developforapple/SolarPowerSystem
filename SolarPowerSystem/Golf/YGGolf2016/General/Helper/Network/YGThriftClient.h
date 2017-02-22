//
//  YGThriftClient.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <thrift/thrift.h>
#import "THTTPClient.h"
#import "TAsyncTransport.h"




/*!
 *  目前无法使用
 */



/**
 *  请求过程
 *
 *  @param p 进度 0~1
 */
typedef void(^YGReqeustProgressBlock)(CGFloat p);

/**
 *  响应过程
 *
 *  @param totalBytesWritten         总共接受了多少数据
 *  @param totalBytesExpectedToWrite 一共有多少数据
 */
typedef void(^YGResponseProcessBlock)(NSUInteger totalBytesWritten,
                                      NSUInteger totalBytesExpectedToWrite);
/**
 *  响应进度
 *
 *  @param p 进度0~1
 */
typedef void(^YGResponseProgressBlock)(CGFloat p);

/**
 *  使用了NSURLSession代替 NSURLConnection。 异步调用
 *
 *  @important 必须使用“thrift --gen cocoa:async_clients test.thrift” 命令生成.h.m文件，以支持异步操作。
 */
@interface YGThriftClient : THTTPClient <TAsyncTransport>

/**
 *  设置请求进度的回调。
 *  使用场景：上传数据时的上传进度
 */
@property (copy, nonatomic) YGReqeustProgressBlock requestProgress;

/**
 *  接收响应数据的过程的回调。这里返回详细数据量
 *  使用场景：下载数据时
 */
@property (copy, nonatomic) YGResponseProcessBlock responseProcess;

/**
 *  接收响应数据的过程的进度回调。这里返回简单的进度。
 *  使用场景：下载数据时。
 */
@property (copy, nonatomic) YGResponseProgressBlock responseProgress;

/**
 *  网络请求任务
 */
@property (strong, nonatomic) NSURLSessionDataTask *task;

@end
