//
//  YGCouponCell.h
//  Golf
//
//  Created by bo wang on 2016/10/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CouponModel;

UIKIT_EXTERN NSString *const kYGCouponCell;

@interface YGCouponCell : UITableViewCell

//是否有效，指的是该优惠券是仍然有效的优惠券。没有过期、已使用或者被赠送
@property (assign, readonly, nonatomic) BOOL enabled;

//是否可用，指的是在当前条件下，该优惠券是否可用。优惠券在特定商品等等条件下可能不可用。
@property (assign, readonly, nonatomic) BOOL usable;

//是否是选择模式。优惠券列表分为选择模式和普通模式。
@property (assign, nonatomic) BOOL selectionMode;

@property (strong, readonly, nonatomic) CouponModel *coupon;
- (void)configureWithCoupon:(CouponModel *)coupon;

@property (strong, nonatomic) NSString *descText;   //单独列出的描述文字。可在外部直接设置。

@end


UIKIT_EXTERN NSString *const kYGCouponInputCell;
@interface YGCouponInputCell : UITableViewCell
@property (copy, nonatomic) void (^didAddCoupon)(CouponModel *coupon);
@end

UIKIT_EXTERN NSString *const kYGCouponNonuseCell;
@interface YGCouponNonuseCell : UITableViewCell
@end
