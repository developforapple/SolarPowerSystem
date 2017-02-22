//
//  YGCouponHelper.m
//  Golf
//
//  Created by bo wang on 2016/10/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCouponHelper.h"
#import "CouponModel.h"

#define kDefaultPageSize (20)

@implementation YGCouponHelper

+ (void)fetchCouponList:(BOOL)isEnabled
                 pageNo:(int)pageNo
             completion:(void (^)(BOOL suc,BOOL noMore,NSArray<CouponModel *> *list))completion
{
    if (!completion) return;
    
    [ServerService fetchCouponList:isEnabled?1:0 pageNo:pageNo pageSize:kDefaultPageSize callBack:^(id obj) {
        
        NSArray *list = obj;
        if ([list isKindOfClass:[NSArray class]]) {
            completion(YES,list.count<kDefaultPageSize,list);
        }else{
            completion(NO,NO,nil);
        }
        
    } failure:^(id error) {
        completion(NO,NO,nil);
    }];
}

+ (void)bestCouponWithFilter:(YGCouponFilter *)filter
                  completion:(void (^)(BOOL suc, CouponModel *coupon))completion
{
    if (!completion) return;
    
    [self fetchCouponListUseFilter:filter enabledCoupon:YES pageNo:1 completion:^(BOOL suc, BOOL noMore, NSArray<CouponModel *> *list) {
        if (suc) {
            
            CouponModel *coupon;
            if ( filter.type == YGOrderTypeMall ||
                (filter.type == YGOrderTypeCourse && filter.scene == YGCouponSceneTourPackage)) {
                for (CouponModel *aCoupon in list) {
                    if (aCoupon.usable) {
                        coupon = aCoupon;
                        break;
                    }
                }
            }else{
                coupon = [filter getBestCouponInList:list];
            }
            completion(YES,coupon);
            
        }else{
            completion(NO,nil);
        }
    }];
}

+ (void)fetchCouponListUseFilter:(YGCouponFilter *)filter
                   enabledCoupon:(BOOL)enabled
                          pageNo:(int)pageNo
                      completion:(void (^)(BOOL suc,BOOL noMore,NSArray<CouponModel *> *list))completion
{
    if (!completion) return;
    
    if (filter && (filter.type == YGOrderTypeMall || (filter.type == YGOrderTypeCourse && filter.scene == YGCouponSceneTourPackage))) {
        NSSet *ids;
        switch (filter.scene) {
            case YGCouponSceneMall:
                ids = filter.commodityIds;
                break;
            case YGCouponSceneTourPackage:{
                ids = filter.tourPackageIds;
            }   break;
        }
        [ServerService fetchCouponFilteredList:1 pageNo:pageNo pageSize:100 scene:filter.scene price:filter.amount ids:ids callBack:^(id obj) {
            NSArray *list = obj;
            if ([list isKindOfClass:[NSArray class]]) {
                completion(YES,YES,list);
            }else{
                completion(NO,NO,nil);
            }
        } failure:^(id error) {
            completion(NO,NO,nil);
        }];
    }else{
        [ServerService fetchCouponList:enabled?1:0 pageNo:pageNo pageSize:kDefaultPageSize callBack:^(id obj) {
            
            NSArray *list = obj;
            if ([list isKindOfClass:[NSArray class]]) {
                
                if (filter) {
                    NSArray *usableList;
                    NSArray *unusableList;
                    [filter splitCouponList:list usable:&usableList unusable:&unusableList invalid:NULL];
                    
                    NSMutableArray *tmp = [NSMutableArray arrayWithArray:usableList];
                    [tmp addObjectsFromArray:unusableList];
                    
                    completion(YES,list.count<kDefaultPageSize,tmp);
                }else{
                    completion(YES,list.count<kDefaultPageSize,list);
                }

            }else{
                completion(NO,NO,nil);
            }
            
        } failure:^(id error) {
            completion(NO,NO,nil);
        }];
    }
}

@end

#import "YGMallOrderModel.h"

@implementation YGCouponFilter

+ (instancetype)filterWithCommodityOrder:(YGMallOrderModel *)order
{
    if (!order) return nil;
    
    YGCouponFilter *filter = [YGCouponFilter new];
    filter.amount = order.order_total;
    filter.commodityIds = [order commodityIdSets];
    filter.categoryIds = [order commodityCategoryIdSets];
    filter.brandIds = [order commodityBrandIdSets];
    filter.type = YGOrderTypeMall;
    filter.scene = YGCouponSceneMall;
    return filter;
}

- (CouponModel *)getBestCouponInList:(NSArray *)couponList
{
    NSArray *usableList;
    [self splitCouponList:couponList usable:&usableList unusable:NULL invalid:NULL];
    
    CouponModel *bestOne;
    for (CouponModel *coupon in usableList) {
        if (!bestOne || bestOne.couponAmount < coupon.couponAmount) {
            bestOne = coupon;
        }
    }
    return bestOne;
}

- (void)splitCouponList:(NSArray<CouponModel *> *)couponList
                 usable:(NSArray<CouponModel *> **)usableResult
               unusable:(NSArray<CouponModel *> **)unusableResult
                invalid:(NSArray<CouponModel *> **)invalidResult
{
    NSMutableArray *result1 = [NSMutableArray array];   //可用
    NSMutableArray *result2 = [NSMutableArray array];   //不可用
    NSMutableArray *result3 = [NSMutableArray array];   //无效
    
    
    for (CouponModel *coupon in couponList) {
        if (coupon.couponStatus != CouponStatusEnabled) {
            [result3 addObject:coupon];
        }else{
            BOOL usable = coupon.limitAmount * 100 <= self.amount;
            if (usable) {
                switch (coupon.subType) {
                    case CouponSubTypeNormal: usable = YES;  break;
                    case CouponSubTypeCategory:{
                        usable = [self.categoryIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeBrandId:{
                        usable = [self.brandIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeCommodity:{
                        usable = [self.commodityIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeTeetime:{
                        usable = [self.clubIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeProduct:{
                        usable = [self.productIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeAcademy:{
                        usable = [self.academyIds intersectsSet:coupon.limitIdSets];
                    }   break;
                    case CouponSubTypeClassType:{
                        usable = [self.classTypes intersectsSet:coupon.limitIdSets];
                    }   break;
                }
            }
            coupon.usable = usable;
            if (usable) {
                [result1 addObject:coupon];
            }else{
                [result2 addObject:coupon];
            }
        }
    }
    
    if (usableResult != NULL) {
        *usableResult = result1;
    }
    if (unusableResult != NULL) {
        *unusableResult = result2;
    }
    if (invalidResult != NULL) {
        *invalidResult = result3;
    }
}

@end
