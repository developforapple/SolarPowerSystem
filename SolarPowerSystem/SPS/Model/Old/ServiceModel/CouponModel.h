//
//  CouponModel.h
//  Golf
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CouponSubType){
    CouponSubTypeNormal = 1,
    CouponSubTypeCategory = 2,
    CouponSubTypeBrandId = 3,
    CouponSubTypeCommodity = 4,
    CouponSubTypeTeetime = 5,
    CouponSubTypeProduct = 6,
    CouponSubTypeAcademy = 7,
    CouponSubTypeClassType = 8,
};

typedef NS_ENUM(NSUInteger, CouponStatus) {
    CouponStatusEnabled = 1,     //可用
    CouponStatusUsed = 2,       //已使用
    CouponStatusExpired = 3,    //已过期
    CouponStatusPresented = 4,  //已赠送
};

@interface CouponModel : NSObject

@property (nonatomic) int couponId;
@property (nonatomic,copy) NSString *couponName;
@property (nonatomic) int couponAmount; //单位 元
@property (nonatomic) int limitAmount;  //单位 元
@property (nonatomic) CouponStatus couponStatus;
@property (nonatomic,copy) NSString *expireTime;
@property (nonatomic,copy) NSString *tranTime;
@property (nonatomic) BOOL canSend;
@property (nonatomic) int couponType;
@property (nonatomic) CouponSubType subType;//1.通用 2.类别 3.品牌 4.商品券 5.订场 6.产品 7.学院 8.课程
@property (nonatomic,copy) NSString *limitIds;
@property (nonatomic,copy) NSString *couponDescription;

// 7.2 新增服务器字段。1 可使用 0 不可使用 -1已使用或者已过期
@property (nonatomic) int use_status;

// 7.2 新增临时字段，将 limitIds 拆分为单独的id
@property (nonatomic, strong) NSSet<NSNumber *> *limitIdSets;
// 7.2 新增临时字段，临时标记优惠券能否使用。这里不是指优惠券是否是有效状态。 此值和use_status意义相同
@property (nonatomic, assign) BOOL usable;

- (id)initWithDic:(id)data;
+ (NSArray *)couponsWithData:(NSArray *)data;

- (NSString *)couponAmountInfo;

@end
