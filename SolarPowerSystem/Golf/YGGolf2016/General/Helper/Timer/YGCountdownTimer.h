//
//  YGCountdownTimer.h
//  Golf
//
//  Created by bo wang on 16/8/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用这个时间戳作为targetTime，可以使 YGCountdownTimer 作为一个普通定时器使用
#define kYGFutureTime [[NSDate distantFuture] timeIntervalSince1970]

// GCD定时器的封装。这个定时器可以在UI Runloop被占用时调用。NSTimer在UI被操作时会被暂停
// 会使用服务器时间对本地时间进行修正
// 推荐使用RAC进行监听
@interface YGCountdownTimer : NSObject

- (instancetype)initWithTime:(NSTimeInterval)targetTime;
- (instancetype)initWithTime:(NSTimeInterval)targetTime
                    callback:(void(^)(YGCountdownTimer *theTimer))callback;


/*!
 *  @brief 创建一个倒计时。倒计时每秒使用callback回调。
 *
 *  @param targetTime 目标时间戳。
 *  @param interval   倒计时间隔。默认1秒
 *  @param callback   回调。回调不是在主线程！
 *
 *  @return 定时器
 */
- (instancetype)initWithTime:(NSTimeInterval)targetTime
                    interval:(NSTimeInterval)interval
                    callback:(void(^)(YGCountdownTimer *theTimer))callback;

/**
 创建一个倒计时。倒计时每秒使用callback回调。

 @param targetTime 目标时间戳
 @param interval 倒计时间隔。默认1秒
 @param startBlock 倒计时是否应该启动
 @param callback 倒计时回调。子线程。
 @return
 */
- (instancetype)initWithTime:(NSTimeInterval)targetTime
                    interval:(NSTimeInterval)interval
                 shouldStart:(BOOL(^)(YGCountdownTimer *theTimer))startBlock
                    callback:(void(^)(YGCountdownTimer *theTimer))callback;

// 回调在子线程
@property (copy, nonatomic) void (^callback)(YGCountdownTimer *theTimer);

// 目标时间
@property (assign, readonly, nonatomic) NSTimeInterval targetTime;
// 是否到达目标时间
@property (assign, readonly, nonatomic) BOOL timeout;
// 剩余时间
@property (assign, readonly, nonatomic) NSTimeInterval countdown;
// 剩余小时
@property (assign, readonly, nonatomic) NSUInteger hour;
// 剩余分
@property (assign, readonly, nonatomic) NSUInteger minute;
// 剩余秒
@property (assign, readonly, nonatomic) NSUInteger second;

// 取消定时器。需要外部手动取消，内部定时器到达时间点时并不会自动停止。
- (void)cancel;

@end
