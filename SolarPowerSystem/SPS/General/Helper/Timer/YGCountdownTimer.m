//
//  YGCountdownTimer.m
//  Golf
//
//  Created by bo wang on 16/8/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCountdownTimer.h"

static dispatch_queue_t timerQueue;

@interface YGCountdownTimer ()
{
    dispatch_source_t _timer;
}
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, readwrite, nonatomic) NSTimeInterval targetTime;
@property (assign, readwrite, nonatomic) BOOL timeout;
@property (assign, readwrite, nonatomic) NSTimeInterval countdown;
@property (assign, readwrite, nonatomic) NSUInteger hour;
@property (assign, readwrite, nonatomic) NSUInteger minute;
@property (assign, readwrite, nonatomic) NSUInteger second;

@property (assign, readwrite, nonatomic) NSTimeInterval delay;

@property (assign, nonatomic) BOOL firstEventFlag;

@end

@implementation YGCountdownTimer

- (instancetype)initWithTime:(NSTimeInterval)targetTime
{
    return [self initWithTime:targetTime callback:nil];
}

- (instancetype)initWithTime:(NSTimeInterval)targetTime callback:(void (^)(YGCountdownTimer *))callback
{
    return [self initWithTime:targetTime interval:1.f callback:callback];
}

- (instancetype)initWithTime:(NSTimeInterval)targetTime
                    interval:(NSTimeInterval)interval
                    callback:(void(^)(YGCountdownTimer *theTimer))callback
{
    return [self initWithTime:targetTime interval:interval shouldStart:NULL callback:callback];
}

- (instancetype)initWithTime:(NSTimeInterval)targetTime
                    interval:(NSTimeInterval)interval
                 shouldStart:(BOOL(^)(YGCountdownTimer *theTimer))startBlock
                    callback:(void(^)(YGCountdownTimer *theTimer))callback
{
    self = [super init];
    if (self) {
        self.interval = interval;
        self.callback = callback;
        self.targetTime = targetTime;
//        if ([LoginManager sharedManager].timeInterGab == KDefaultTimeInterGab) {
//            ygweakify(self);
//            [ServerService getServerTimeWithSuccess:^(NSTimeInterval timeInterval) {
//                ygstrongify(self);
//                [LoginManager sharedManager].timeInterGab = timeInterval;
//                
//                [self estimateCountdown];
//                BOOL start = YES;
//                if (startBlock) {
//                    start = startBlock(self);
//                }
//                if (start) {
//                    [self initTimer];
//                }
//            } failure:nil];
//        }else
        {
            [self estimateCountdown];
            BOOL start = YES;
            if (startBlock) {
                start = startBlock(self);
            }
            if (start) {
                [self initTimer];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    self.callback = nil;
    [self stopTimer];
}

- (void)discreaseCountDown
{
    self.countdown -= self.interval;
    [self estimateTime];
}

- (void)estimateCountdown
{
//    NSTimeInterval timeInterGab = [LoginManager sharedManager].timeInterGab;
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970] + timeInterGab;
//    NSTimeInterval interval = self.targetTime - now;
//    self.countdown = (long long)interval;
//    // 倒计时的小数部分
//    CGFloat delay = interval - self.countdown;
//    self.delay = delay;
}

- (void)estimateTime
{
    long long countdown = self.countdown;
    NSInteger hour = countdown/3600;
    NSInteger minute = (countdown%3600)/60;
    NSInteger second = countdown%60;
    
    RunOnMainQueue(^{
        self.hour = MAX(0, hour);
        self.minute = MAX(0, minute);
        self.second = MAX(0, second);
        self.timeout = countdown<=0;
        
        if (self.callback) {
            __weak typeof(YGCountdownTimer) *weakSelf = self;
            self.callback(weakSelf);
        }
    });
}

- (void)initTimer
{
//    NSTimeInterval timeInterGab = [LoginManager sharedManager].timeInterGab;
//    NSLog(@"创建倒计时：\n目标时间：%.0f\n服务器时差：%f\n倒计时：%.1f",self.targetTime,timeInterGab,self.countdown);
//    RunAfter(self.delay, ^{
//        [self startTimer];
//    });
}

- (void)startTimer
{
    [self stopTimer];
    
    if (!timerQueue) {
        timerQueue = dispatch_queue_create("YGCountdownTimer", DISPATCH_QUEUE_CONCURRENT); //并行队列
    }

    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), self.interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        if (!self.firstEventFlag) {
            self.firstEventFlag = YES;
        }else{
            [self discreaseCountDown];
        }
    });
    dispatch_resume(_timer);
    NSLog(@"倒计时启动");
    
    [self estimateTime];//马上有一次回调
}

- (void)stopTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    self.firstEventFlag = NO;
}

- (void)cancel
{
    NSLog(@"取消倒计时");
    [self stopTimer];
}

- (void)setHour:(NSUInteger)hour
{
    if (_hour != hour) {
        [self willChangeValueForKey:@"hour"];
        _hour = hour;
        [self didChangeValueForKey:@"hour"];
    }
}

- (void)setMinute:(NSUInteger)minute
{
    if (_minute != minute) {
        [self willChangeValueForKey:@"minute"];
        _minute = minute;
        [self didChangeValueForKey:@"minute"];
    }
}

- (void)setSecond:(NSUInteger)second
{
    if (_second != second) {
        [self willChangeValueForKey:@"second"];
        _second = second;
        [self didChangeValueForKey:@"second"];
    }
}

@end
