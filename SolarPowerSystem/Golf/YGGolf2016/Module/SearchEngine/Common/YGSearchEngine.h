//
//  YGSearchEngine.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGSearch.h"

NS_ASSUME_NONNULL_BEGIN

@class YGSearchCondition;

/*!
 *  @brief 提供结果
 */
@interface YGSearchEngine : NSObject

/*!
 *  @brief 当前搜索条件。默认条件下是没有条件的。
 */
@property (strong, readonly, nullable, nonatomic) YGSearchCondition *condition;

/*!
 *  @brief 搜索结果
 */
@property (strong, readonly, nullable, nonatomic) NSDictionary<NSNumber *,NSArray *> *resultData;

/*!
 *  @brief 数据更新的回调
 */
@property (copy, nonatomic) void (^updateCallback)(BOOL suc,BOOL isMore);

/*!
 *  @brief 标记没有更多数据了
 */
@property (assign, readonly, nonatomic) BOOL noMoreData;

/*!
 *  @brief 根据搜索条件进行搜索
 *
 *  @param condition条件
 */
- (void)search:(YGSearchCondition *)condition;

/*!
 *  @brief 加载更多。type为1时有效
 */
- (void)loadMore;

/*!
 *  @brief 重置内容
 */
- (void)reset;

/*!
 *  @brief 搜索结果类型列表
 *
 *  @return YGSearchType列表
 */
- (NSArray<NSNumber *> *)resultTypeList;

/*!
 *  @brief 当搜索类型为all时，通过此方法查询单个类型有没有更多的结果。
 *
 *  @param type 单个类型
 *
 *  @return YES，有更多结果。NO，没有更多。
 */
- (BOOL)hasMoreDataOfType:(YGSearchType)type;

@end


/*!
 搜索条件。当需要修改搜索条件时，需要创建新的实例。
 */
@interface YGSearchCondition : NSObject

- (instancetype)initWithType:(YGSearchType)type
                    keywords:(NSString *)keywords
                      pageNo:(NSUInteger)pageNo;

/*!
 *  @brief 下一页的实例
 *
 *  @return 搜索条件实例
 */
+ (instancetype)nextPage:(YGSearchCondition *)c;

@property (copy  , readonly, nullable, nonatomic) NSString *keywords;
@property (assign, readonly, nonatomic) YGSearchType type;
@property (assign, readonly, nonatomic) NSUInteger pageNo;

/*!
 *  @brief 是否是搜索全部
 */
- (BOOL)isAll;

/*!
 *  @brief 是否是加载更多
 */
- (BOOL)isMore;

@end

NS_ASSUME_NONNULL_END
