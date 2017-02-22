//
//  YGOrderManager.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOrderCommon.h"

@class YGOrdersSummaryItem;

@interface YGOrderManager : NSObject

// 原始数据
@property (strong, readonly, nonatomic) NSArray<YGOrdersSummaryItem *> *items;

// 最近订单
@property (strong, readonly, nonatomic) NSArray<id<YGOrderModel>> *orderList;

@property (assign, readonly, nonatomic) BOOL noMore;

// reload后的回调
@property (copy, nonatomic) void (^didLoadDataBlock)(BOOL suc,BOOL isMore);

- (void)reload;
- (void)loadMore;

@end

@interface YGOrdersSummaryItem : NSObject

@property (assign, nonatomic) YGOrderType type;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconName;
@property (assign, nonatomic) NSInteger amount YG_DEPRECATED(7.31, "无用");
@property (assign, nonatomic) NSInteger waitpayAmount;
@property (strong, nonatomic) NSMutableArray<id<YGOrderModel>> *orders YG_DEPRECATED(7.31, "无用");

- (instancetype)initWithType:(YGOrderType)type;
+ (NSArray<YGOrdersSummaryItem *> *)defaultSummaryItems;

@end
