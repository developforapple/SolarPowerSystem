//
//  YGCouponHelper.h
//  Golf
//
//  Created by bo wang on 2016/10/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGOrderCommon.h"

@class YGCouponFilter;
@class YGMallOrderModel;

//优惠券使用场景
typedef NS_ENUM(NSUInteger, YGCouponScene) {
    YGCouponSceneMall = 1,
    
    YGCouponSceneTourPackage = 4,
};

@interface YGCouponHelper : NSObject

/**
 请求优惠券列表。不做筛选

 @param isEnabled  YES：可用的优惠券列表。NO：全部列表
 @param pageNo     分页
 @param completion 回调
 */
+ (void)fetchCouponList:(BOOL)isEnabled
                 pageNo:(int)pageNo
             completion:(void (^)(BOOL suc,BOOL noMore,NSArray<CouponModel *> *list))completion;



/**
 向服务器请求最新的优惠券数据，根据filter计算出最合适的优惠券

 目前在商城订单下，使用服务器进行筛选，其他订单在app内部进行筛选。
 
 @param filter     条件
 @param completion 回调
 */
+ (void)bestCouponWithFilter:(YGCouponFilter *)filter
                  completion:(void (^)(BOOL suc, CouponModel *coupon))completion;


/**
 向服务器请求最新的优惠券数据。根据filter进行筛选
 
 这个方法是由服务器进行筛选优惠券

 @param filter 条件
 @param enabled 是否只返回有效的优惠券
 @param pageNo 分页
 @param completion 回调
 */
+ (void)fetchCouponListUseFilter:(YGCouponFilter *)filter
                   enabledCoupon:(BOOL)enabled
                          pageNo:(int)pageNo
                      completion:(void (^)(BOOL suc,BOOL noMore,NSArray<CouponModel *> *list))completion;

@end

@interface YGCouponFilter : NSObject
@property (strong, nonatomic) NSSet<NSNumber *> *categoryIds;
@property (strong, nonatomic) NSSet<NSNumber *> *brandIds;
@property (strong, nonatomic) NSSet<NSNumber *> *commodityIds;
@property (strong, nonatomic) NSSet<NSNumber *> *clubIds;
@property (strong, nonatomic) NSSet<NSNumber *> *productIds;
@property (strong, nonatomic) NSSet<NSNumber *> *academyIds;
@property (strong, nonatomic) NSSet<NSNumber *> *classTypes;
@property (strong, nonatomic) NSSet<NSNumber *> *tourPackageIds;    //旅行套餐id 7.4版加
@property (assign, nonatomic) NSInteger amount; //单位：分
@property (assign, nonatomic) YGOrderType type; //订单类型。
@property (assign, nonatomic) YGCouponScene scene;//优惠券使用场景。

// 根据商品订单创建过滤器
+ (instancetype)filterWithCommodityOrder:(YGMallOrderModel *)order;

/**
 从优惠券列表中找到最适合的优惠券，没有找到返回nil。调用前需要先设置匹配的各项属性

 @param couponList 优惠券列表

 @return 最适合的优惠券
 */
- (CouponModel *)getBestCouponInList:(NSArray<CouponModel *> *)couponList;

/**
 根据当前条件拆分优惠券列表，分为可用、不可用、无效。优惠券中相应属性也被修改

 @param couponList     全部优惠券
 @param usableResult   当前可用的优惠券
 @param unusableResult 当前不可用的优惠券
 @param invalidResult
 */
- (void)splitCouponList:(NSArray<CouponModel *> *)couponList
                 usable:(NSArray<CouponModel *> **)usableResult
               unusable:(NSArray<CouponModel *> **)unusableResult
                invalid:(NSArray<CouponModel *> **)invalidResult;


@end
