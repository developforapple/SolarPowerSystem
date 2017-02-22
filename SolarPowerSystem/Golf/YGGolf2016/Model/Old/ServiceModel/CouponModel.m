//
//  CouponModel.m
//  Golf
//
//  Created by user on 13-6-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "CouponModel.h"
#import <YYModel/YYModel.h>

@interface CouponModel ()

@end

@implementation CouponModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"coupon_id"]) {
        self.couponId = [[dic objectForKey:@"coupon_id"] intValue];
    }
    if ([dic objectForKey:@"can_send"]) {
        self.canSend = [[dic objectForKey:@"can_send"] intValue] == 1 ? YES:NO;
    }
    if ([dic objectForKey:@"coupon_status"]) {
        self.couponStatus = [[dic objectForKey:@"coupon_status"] intValue];
    }
    if ([dic objectForKey:@"coupon_amount"]) {
        self.couponAmount = [[dic objectForKey:@"coupon_amount"] intValue]/100;
    }
    if ([dic objectForKey:@"expire_time"]) {
        NSString *expiretime = [dic objectForKey:@"expire_time"];
        self.expireTime = [Utilities getDateStringFromString:expiretime WithAllFormatter:@"yyyy-MM-dd"];
    }
    if ([dic objectForKey:@"tran_time"]) {
        NSString *trantime = [dic objectForKey:@"tran_time"];
        self.tranTime = [Utilities getDateStringFromString:trantime WithAllFormatter:@"yyyy-MM-dd"];
    }
    if ([dic objectForKey:@"limit_amount"]) {
        self.limitAmount = [[dic objectForKey:@"limit_amount"] intValue] / 100;
    }
    if ([dic objectForKey:@"coupon_name"]) {
        self.couponName = [dic objectForKey:@"coupon_name"];
    }
    if ([dic objectForKey:@"coupon_type"]) {
        self.couponType = [[dic objectForKey:@"coupon_type"] intValue];
    }
    if ([dic objectForKey:@"sub_type"]) {
        self.subType = [[dic objectForKey:@"sub_type"] intValue];
    }
    if ([dic objectForKey:@"limit_ids"]) {
        self.limitIds = [dic objectForKey:@"limit_ids"];
        
        NSArray *ids = [self.limitIds componentsSeparatedByString:@","];
        NSMutableSet *idSets = [NSMutableSet set];
        for (NSString *aId in ids) {
            NSInteger idV = aId.integerValue;
            if (idV != 0) {
                [idSets addObject:@(idV)];
            }
        }
        self.limitIdSets = idSets;
    }
    if ([dic objectForKey:@"coupon_description"]) {
        self.couponDescription = [dic objectForKey:@"coupon_description"];
    }
    
    if (dic[@"use_status"]) {
        self.use_status = [dic[@"use_status"] intValue];
    }else{
        self.use_status = 1;
    }
    
    return self;
}

+ (NSArray *)couponsWithData:(NSArray *)data
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSDictionary *dic in data) {
        id c = [[[self class] alloc] initWithDic:dic];
        if (c) {
            [tmp addObject:c];
        }
    }
    return tmp;
}

- (void)setUse_status:(int)use_status
{
    _use_status = use_status;
    _usable = use_status==1?YES:NO;
}

- (void)setUsable:(BOOL)usable
{
    _usable = usable;
    _use_status = usable?1:(self.couponStatus==CouponStatusEnabled?2:-1);
}

- (NSString *)couponAmountInfo
{
    NSString *info = [NSString stringWithFormat:@"%@ %d元",self.couponName,self.couponAmount];
    return info;
    
//    NSString *typeInfo = @"通用券";
//    switch (self.subType) {
//        case CouponSubTypeNormal:break;
//        case CouponSubTypeCategory: typeInfo = @"商品分类券";break;
//        case CouponSubTypeBrandId: typeInfo = @"品牌券";break;
//        case CouponSubTypeCommodity:typeInfo = @"商品券";break;
//        case CouponSubTypeTeetime: typeInfo = @"订场券";break;
//        case CouponSubTypeProduct: typeInfo = @"产品券";break;
//        case CouponSubTypeAcademy: typeInfo = @"学院券";break;
//        case CouponSubTypeClassType:typeInfo = @"课程券";break;
//        default:break;
//    }
//    
//    NSString *info = [NSString stringWithFormat:@"%@%d元",typeInfo,self.couponAmount];
//    return info;
}

@end
