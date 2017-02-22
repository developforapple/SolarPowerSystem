//
//  YGMallFlashSaleLogic.h
//  Golf
//
//  Created by bo wang on 2016/11/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCountdownTimer.h"

typedef NS_ENUM(NSUInteger, YGMallFlashSaleScene) {
    YGMallFlashSaleSceneList = 0,       //抢购列表
    YGMallFlashSaleSceneIndex = 1,      //APP首页
    YGMallFlashSaleSceneMallIndex = 2,  //商城首页
};

@interface YGMallFlashSaleLogic : NSObject

- (instancetype)initWithScene:(YGMallFlashSaleScene)scene;
@property (assign, nonatomic) YGMallFlashSaleScene scene;

@property (copy, nonatomic) void (^callback)(BOOL suc,BOOL isMore,id object);

@property (assign, nonatomic) BOOL hasMore;
@property (strong, readonly, nonatomic) NSArray *data;

- (void)refresh;
- (void)loadMore;

@property (assign, readonly, nonatomic) long long refreshTimestamp; //当前正在抢购时的下次刷新时间
@property (copy, readonly, nonatomic) NSString *flashSaleNotice;    //提示
@property (assign, readonly, nonatomic) long long nextTimestamp;    //下次抢购时间
@property (strong, readonly, nonatomic) YGCountdownTimer *timer;    //下次抢购倒计时
// 返回 -1 表示失败
- (void)refreshFlashSaleTimestamp:(void(^)(long long))completion;

- (NSArray<NSArray<CommodityModel *> *> *)sortedData;

@end
