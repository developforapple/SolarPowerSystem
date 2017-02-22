//
//  YGOrderDataProvider.h
//  Golf
//
//  Created by bo wang on 16/9/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOrderCommon.h"

/**
 为订单列表提供数据源
 */
@interface YGOrderDataProvider : NSObject

- (instancetype)initWithType:(YGOrderType)type NS_DESIGNATED_INITIALIZER;

@property (assign, readonly, nonatomic) YGOrderType orderType;
@property (strong, readonly, nonatomic) NSArray<NSString *> *titles;
@property (strong, readonly, nonatomic) NSArray<NSNumber *> *countes;
@property (strong, readonly, nonatomic) NSArray<NSNumber *> *statues;
@property (strong, readonly, nonatomic) NSArray *orderList;
@property (assign, readonly, nonatomic) NSUInteger curStatus;

@property (strong, nonatomic) NSString *lastErrorMessage;

@property (copy, nonatomic) void (^updateCallback)(BOOL suc, BOOL isMore);

/**
 某个状态下的订单数据。数据获取完成后使用updateCallback回调

 @param status 订单状态。不同的订单类型有不同的状态。0 代表全部
 */
- (void)fetchDataOfStatus:(NSUInteger)status;

/**
 重新读取当前状态下的数据
 */
- (void)refresh;

/**
 当前状态下加载更多数据
 */
- (void)loadMore;

/**
 某个订单状态是否还有更多数据

 @param status 订单状态。0 代表全部。

 @return YES，可能有更多数据。NO，没有更多数据。
 */
- (BOOL)hasMoreDataOfStatus:(NSUInteger)status;

/**
 相对于订单类型，状态是否是有效的订单状态。0 代表全部，总是有效的

 @param status 订单状态。

 @return YES，有效状态。NO,无效的状态
 */
- (BOOL)isValidStatus:(NSUInteger)status;

/**
 索引index的订单内容
 */
- (id)orderAtIndex:(NSUInteger)index;

/**
 订单发生了变化

 @param order 订单
 */
- (void)updateOrder:(id)order;

/**
 订单被删除了

 @param order 订单
 */
- (void)deleteOrder:(id)order;

@end
