//
//  YGMallFlashSaleLogic.m
//  Golf
//
//  Created by bo wang on 2016/11/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallFlashSaleLogic.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define kPageSize 20

@interface YGMallFlashSaleLogic ()
@property (strong, readwrite, nonatomic) NSMutableArray *data;
@property (assign, nonatomic) NSInteger pageNo;
@property (copy, readwrite, nonatomic) NSString *flashSaleNotice;
@property (assign, readwrite, nonatomic) long long refreshTimestamp;
@property (assign, readwrite, nonatomic) long long nextTimestamp;
@property (strong, readwrite, nonatomic) YGCountdownTimer *timer;

@property (strong, nonatomic) YGCountdownTimer *refreshTimer;

@end

@implementation YGMallFlashSaleLogic

- (instancetype)initWithScene:(YGMallFlashSaleScene)scene
{
    self = [super init];
    if (self) {
        self.scene = scene;
        self.pageNo = 1;
        self.nextTimestamp = -1;
        
        ygweakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil]
         subscribeNext:^(id x) {
             //返回前台时刷新
             ygstrongify(self);
             [self refresh];
         }];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"");
    [self.timer cancel];
    self.timer = nil;
    [self.refreshTimer cancel];
    self.refreshTimer = nil;
}

- (void)refresh
{
    NSInteger pageNo = 1;
    ygweakify(self);
    [ServerService fetchMallFlashSaleList:self.scene pageNo:pageNo pagSize:kPageSize callBack:^(NSArray *obj) {
        ygstrongify(self);
        if ([obj isKindOfClass:[NSArray class]]) {
            self.data = [obj mutableCopy];
            self.pageNo = 1;
            self.hasMore = obj.count>=kPageSize;
            [self callCallback:YES :NO :obj];
        }else{
            [self callCallback:NO :NO :@"数据错误"];
        }
    } failure:^(id error) {
        ygstrongify(self);
        [self callCallback:NO :NO :@"当前网络不可用"];
    }];
}

- (void)loadMore
{
    NSInteger pageNo = self.pageNo+1;
    
    ygweakify(self);
    [ServerService fetchMallFlashSaleList:self.scene pageNo:pageNo pagSize:kPageSize callBack:^(NSArray *obj) {
        ygstrongify(self);
        if ([obj isKindOfClass:[NSArray class]]) {
            [_data addObjectsFromArray:obj];
            self.hasMore = obj.count>=kPageSize;
            self.pageNo = pageNo;
            [self callCallback:YES :YES :obj];
        }else{
            [self callCallback:NO :YES :@"数据错误"];
        }
    } failure:^(id error) {
        ygstrongify(self);
        [self callCallback:NO :YES :@"当前网络不可用"];
    }];
}

- (void)callCallback:(BOOL)suc :(BOOL)isMore :(id)object
{
    if (self.callback) {
        self.callback(suc,isMore,object);
    }
}

- (NSArray<NSArray<CommodityModel *> *> *)sortedData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    static NSInteger perDay = 24 * 60 * 60;
    
    for (NSInteger idx = 0; idx < self.data.count; idx++) {
        
        CommodityModel *commodity = self.data[idx];
        YGFlashSaleModel *flashSale = commodity.flash_sale;
        
        if (!flashSale) {
            continue;
        }
        long long time = flashSale.flash_time;
        long long serverTime = flashSale.server_time;
        
        NSInteger day;
        
        if (time <= serverTime) {
            //之前的抢购都算今天的
            day = serverTime / perDay;
        }else{
            day = time / perDay;
        }
        
        NSMutableArray *tmp = dic[@(day)];
        if (!tmp) {
            tmp = [NSMutableArray array];
        }
        [tmp addObject:commodity];
        dic[@(day)] = tmp;
    }
    
    NSArray *allKeys = [dic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1,NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSArray *result = [dic objectsForKeys:allKeys notFoundMarker:@[]];
    return result;
}

- (void)refreshFlashSaleTimestamp:(void(^)(long long))completion
{
    ygweakify(self);
    [ServerService fetchMallFlashSaleTimestamp:^(NSDictionary *obj) {
        ygstrongify(self);
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            [self.timer cancel];
            self.timer = nil;
            NSLog(@"%@",obj);
            long long nextFlashTimestamp = [obj[@"next_flash_time"] longLongValue]/1000;
            long long refreshTimestamp = [obj[@"refresh_time"] longLongValue]/1000;
            long long serverTime = [obj[@"server_time"] longLongValue]/1000;
            self.flashSaleNotice = obj[@"text"];
            self.nextTimestamp = nextFlashTimestamp;
            self.refreshTimestamp = refreshTimestamp;
            
            if (nextFlashTimestamp != 0) {
                self.timer = [[YGCountdownTimer alloc] initWithTime:nextFlashTimestamp];
            }
            
            [self.refreshTimer cancel];
            self.refreshTimer = nil;
            
            if (self.refreshTimestamp != 0) {
                if (serverTime == 0) {
                    serverTime = [[NSDate date] timeIntervalSince1970];
                }
                NSInteger interval = self.refreshTimestamp - serverTime;
                self.refreshTimer = [[YGCountdownTimer alloc] initWithTime:self.refreshTimestamp interval:interval callback:^(YGCountdownTimer *theTimer) {
                    ygstrongify(self);
                    if (theTimer.timeout) {
                        [theTimer cancel];
                        [self refresh];
                    }
                }];
            }
            
            if (completion) {
                completion(nextFlashTimestamp);
            }
            
        }else{
            if (completion) {
                completion(0);
            }
        }
        
    } failure:^(id error) {
        if (completion) {
            completion(0);
        }
    }];
}

@end
