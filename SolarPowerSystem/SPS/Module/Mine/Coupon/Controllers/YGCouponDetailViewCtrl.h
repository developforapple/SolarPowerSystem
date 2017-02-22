//
//  YGCouponDetailViewCtrl.h
//  Golf
//
//  Created by 廖瀚卿 on 15/4/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class CouponModel;

@interface YGCouponDetailViewCtrl : BaseNavController

@property (strong, nonatomic) CouponModel *couponModel;
@property (nonatomic) BOOL isModal;
@end
