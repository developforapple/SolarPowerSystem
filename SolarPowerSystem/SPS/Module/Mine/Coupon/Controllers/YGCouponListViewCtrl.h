//
//  YGCouponListViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "YGCouponHelper.h"

@interface YGCouponListViewCtrl : BaseNavController


#pragma mark - Selection
/**
 是普通列表，还是现金券选择列表。默认为NO，为普通列表。
 */
@property (assign, nonatomic) BOOL selectionMode;
/**
 当前优惠券
 */
@property (strong, nonatomic) CouponModel *curCoupon;
/**
 用于筛选出可用的券
 */
@property (strong, nonatomic) YGCouponFilter *filter;
/**
 选择优惠券的回调
 */
@property (copy, nonatomic) void (^didSelectedCoupon)(CouponModel *coupon);

@end
