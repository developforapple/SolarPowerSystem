//
//  YGMallOrderModel.m
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderModel.h"
#import "YGMallCartGroup.h"
#import "CouponModel.h"

@implementation YGMallOrderModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"order":[YGMallOrderModel class],
             @"commodity":[YGMallOrderCommodity class]};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    self.tempStatus = self.order_state;
    self.orderTime = self.orderTime/1000.f;
    return YES;
}

YYModelDefaultCode

+ (instancetype)createOrderModelInGroups:(NSArray<YGMallCartGroup *> *)groups
{
    if (groups.count == 0) {
        return nil;
    }
    
    NSMutableArray<YGMallOrderModel *> *children = [NSMutableArray array];
    NSInteger price = 0;
    NSInteger freight = 0;
    NSInteger yunbi = 0;
    NSInteger quantity = 0;
    
    for (YGMallCartGroup *aGroup in groups) {
        
        NSInteger childPrice = 0;
        NSInteger childFreight = 0;
        NSInteger childYunbi = 0;
        NSMutableArray *commodities = [NSMutableArray array];
        for (CommodityModel *commodity in aGroup.commodity) {
            YGMallOrderCommodity *orderCommodity = [YGMallOrderCommodity createWithCommodity:commodity];
            if (orderCommodity) {
                [commodities addObject:orderCommodity];
                childFreight = MAX(childFreight, commodity.freight*100);
                childPrice += (commodity.sellingPrice * commodity.quantity * 100);
                childYunbi += (commodity.giveYunbi * 100);
            }
        }
        
        YGMallOrderModel *childOrder = [YGMallOrderModel new];
        childOrder.order_state = YGMallOrderStatusCreating;
        childOrder.orderType = 1;
        childOrder.commodity = commodities;
        childOrder.agentName = aGroup.agentName;
        childOrder.quantity = commodities.count;
        childOrder.order_total = childPrice + childFreight;
        childOrder.give_yunbi = childYunbi;
        childOrder.freight = childFreight;
        childOrder.tempStatus = YGMallOrderStatusCreating;
        [children addObject:childOrder];
        
        price += childPrice;
        freight += childFreight;
        yunbi += childYunbi;
        quantity += childOrder.quantity;
    }
    
    YGMallOrderModel *order = [YGMallOrderModel new];
    order.order_state = YGMallOrderStatusCreating;
    order.orderType = 2;
    order.order = children;
    order.quantity = quantity;
    order.order_total = price + freight;
    order.give_yunbi = yunbi;
    order.freight = freight;
    order.tempStatus = YGMallOrderStatusCreating;
    order.order_id = order.tempOrderId = [[NSDate date] timeIntervalSince1970];
    
    if ([order isVirtualOrder]) {
        //虚拟订单
        order.link_phone = [LoginManager sharedManager].session.mobilePhone;
    }
    
    return order;
}

+ (instancetype)createOrderModelWithCommodity:(CommodityInfoModel *)cim
                                          sku:(CommoditySpecSKUModel *)sku
                                     quantity:(NSInteger)quantity
{
    BOOL isAuction = cim.auctionId > 0 && cim.auctionStatus == 2;
    
    YGMallOrderCommodity *commodity = [YGMallOrderCommodity createWithCommodityInfo:cim];
    commodity.spec_name = isAuction?cim.spec_name:sku.skuName;
    commodity.quantity = quantity;
    commodity.sku_id = isAuction?cim.specId:sku.skuId;
    
    CGFloat freight = 0.f;
    if (cim.auctionId > 0 && (cim.auctionStatus == 2 || cim.auctionStatus == 5)) {
        freight = cim.auctionFreight * 100;
    }else{
        freight = cim.freight * 100;
    }
    
    YGMallOrderModel *inOrder = [YGMallOrderModel new];
    inOrder.commodity = @[commodity];
    
    YGMallOrderModel *outOrder = [YGMallOrderModel new];
    outOrder.order = @[inOrder];
    
    outOrder.order_state    = inOrder.order_state   = YGMallOrderStatusCreating;
    outOrder.orderType      = inOrder.orderType     = 0;
    outOrder.agentName      = inOrder.agentName     = cim.agent_name;
    outOrder.quantity       = inOrder.quantity      = quantity;
    outOrder.order_total    = inOrder.order_total   = (commodity.price * quantity) + freight;
    outOrder.give_yunbi     = inOrder.give_yunbi    = commodity.give_yunbi;
    outOrder.freight        = inOrder.freight       = freight;
    outOrder.tempStatus     = inOrder.tempStatus    = YGMallOrderStatusCreating;
    if ([outOrder isVirtualOrder]) {
        //虚拟订单
        outOrder.link_phone = inOrder.link_phone = [LoginManager sharedManager].session.mobilePhone;
    }
    return outOrder;
}

- (NSSet *)commodityIdSets
{
    NSMutableSet *set = [NSMutableSet set];
    if (self.order) {
        for (YGMallOrderModel *childOrder in self.order) {
            [set unionSet:[childOrder commodityIdSets]];
        }
    }else{
        for (YGMallOrderCommodity *commodity in self.commodity) {
            [set addObject:@(commodity.commodity_id)];
        }
    }
    return set;
}

- (NSSet *)commodityCategoryIdSets
{
    NSMutableSet *set = [NSMutableSet set];
    if (self.order) {
        for (YGMallOrderModel *childOrder in self.order) {
            [set unionSet:[childOrder commodityCategoryIdSets]];
        }
    }else{
        for (YGMallOrderCommodity *commodity in self.commodity) {
            [set addObject:@(commodity.category_id)];
        }
    }
    return set;
}

- (NSSet *)commodityBrandIdSets
{
    NSMutableSet *set = [NSMutableSet set];
    if (self.order) {
        for (YGMallOrderModel *childOrder in self.order) {
            [set unionSet:[childOrder commodityBrandIdSets]];
        }
    }else{
        for (YGMallOrderCommodity *commodity in self.commodity) {
            [set addObject:@(commodity.brand_id)];
        }
    }
    return set;
}

- (BOOL)isVirtualOrder
{
    if (self.order) {
        for (YGMallOrderModel *childOrder in self.order) {
            BOOL childIsVirtualOrder = [childOrder isVirtualOrder];
            if (!childIsVirtualOrder) {
                return NO;
            }
        }
        return YES;
    }else{
        for (YGMallOrderCommodity *commodity in self.commodity) {
            if (commodity.commodity_type != 2) {
                return NO;
            }
        }
        return YES;
    }
}

- (BOOL)isCombinedOrder
{
    return self.orderType == 2;
}

- (BOOL)isInCombinedOrder
{
    return self.orderType == 1;
}

- (BOOL)isMultiCommodityOrder
{
    if (self.order) {
        if (self.order.count <= 1) {
            YGMallOrderModel *order = [self.order firstObject];
            return [order isMultiCommodityOrder];
        }
        return YES;
    }else{
        return self.commodity.count > 1;
    }
}

- (NSArray<YGMallOrderCommodity *> *)commodityList
{
    if (self.order) {
        NSMutableArray *list = [NSMutableArray array];
        for (YGMallOrderModel *childOrder in self.order) {
            [list addObjectsFromArray:childOrder.commodity];
        }
        return list;
    }else{
        return self.commodity;
    }
}

- (NSInteger)couponAmount    //优惠券抵扣
{
    if (self.coupon) {
        return self.coupon.couponAmount * 100;
    }
    return self.couponPayAmount;
}

- (NSInteger)needToPayAmount //实际支付
{
    return MAX(0, self.order_total - (NSInteger)[self couponAmount]);
}

- (NSDictionary *)prepareSubmitData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[@"link_phone"] = self.link_phone;
    dict[@"link_man"] = self.link_man;
    dict[@"address"] = self.address;
    dict[@"price"] = @(self.order_total);
    dict[@"couponId"] = @(self.coupon.couponId);
    
    NSMutableArray *childOrderInfos = [NSMutableArray array];
    for (YGMallOrderModel *childOrder in self.order) {
        
        NSMutableArray *childCommodities = [NSMutableArray array];
        for (YGMallOrderCommodity *commodity in childOrder.commodity) {
            NSDictionary *info = @{@"commodityId":@(commodity.commodity_id),
                                   @"skuId":@(commodity.sku_id),
                                   @"quantity":@(commodity.quantity)};
            [childCommodities addObject:info];
        }
        
        NSDictionary *aChildOrderInfo = @{@"commodity":childCommodities,
                                          @"user_memo":childOrder.user_memo?:@""};
        [childOrderInfos addObject:aChildOrderInfo];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:childOrderInfos options:kNilOptions error:nil];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dict[@"order"] = text;
    return dict;
}

- (BOOL)isInOrderCreating
{
    return self.tempStatus == YGMallOrderStatusCreating;
}

- (BOOL)isInRefundCreating
{
    return self.tempStatus == YGMallOrderStatusCreatingRefund;
}

- (BOOL)isCouponVisible
{
    YGMallOrderStatus status = self.tempStatus;
    return status == YGMallOrderStatusCreating;
}

- (BOOL)isLogisticsVisible
{
    YGMallOrderStatus status = self.tempStatus;
    return (status == YGMallOrderStatusShipped  ||
            status == YGMallOrderStatusReceived ||
            status == YGMallOrderStatusReviewed ||
            status == YGMallOrderStatusApplyRefund ||
            status == YGMallOrderStatusRefunded) &&
           (self.delivery_number.length != 0);
}

- (BOOL)isYunbiVisible
{
    return self.give_yunbi > 0;
}

- (BOOL)canDeleteOrder
{
    return  self.order_state == YGMallOrderStatusClosed ||
            self.order_state == YGMallOrderStatusReceived ||
            self.order_state == YGMallOrderStatusReviewed ||
            self.order_state == YGMallOrderStatusRefunded;
}

- (BOOL)canEditUserMemo
{
    // 未发货即可修改留言
    return  self.tempStatus == YGMallOrderStatusCreating ||
            self.tempStatus == YGMallOrderStatusUnpaid ||
            self.tempStatus == YGMallOrderStatusPaid;
}

- (BOOL)canApplyRefund
{
    // 已付款未收货即可提交申请
    return  self.order_state == YGMallOrderStatusPaid ||
            self.order_state == YGMallOrderStatusShipped;
}

- (BOOL)canCancelApplyRefund
{
    return self.order_state == YGMallOrderStatusApplyRefund;
}

- (BOOL)isCreatingCancelRefund
{
    return self.order_state == YGMallOrderStatusApplyRefund &&
           self.tempStatus == YGMallOrderStatusCreatingRefund;
}

- (BOOL)isCreatingRefund
{
    return self.order_state != YGMallOrderStatusApplyRefund &&
           self.tempStatus == YGMallOrderStatusCreatingRefund;
}

- (NSString *)paymentTitle
{
    NSString *text;
    switch (self.tempStatus) {
        case YGMallOrderStatusPaid:
        case YGMallOrderStatusShipped:
        case YGMallOrderStatusReceived:
        case YGMallOrderStatusReviewed:
            text = @"实付款";
            break;
        case YGMallOrderStatusCreating:
        case YGMallOrderStatusUnpaid:
            text = @"待付款";
            break;
        case YGMallOrderStatusCreatingRefund:
        case YGMallOrderStatusApplyRefund:
            text = @"待退款";
            break;
        case YGMallOrderStatusRefunded:
            text = @"已退款";
            break;
        case YGMallOrderStatusClosed:
            text = @"订单总计";
            break;
    }
    return text;
}

- (NSInteger)unreviewedCommodityAmount
{
    NSInteger amount = 0;
    if (self.order) {
        for (YGMallOrderModel *subOrder in self.order) {
            amount += [subOrder unreviewedCommodityAmount];
        }
    }else{
        for (YGMallOrderCommodity *commodity in self.commodity) {
            if (!commodity.comment_status) {
                amount++;
            }
        }
    }
    return amount;
}

@end

@implementation YGMallOrderCommodity
YYModelDefaultCode

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"evidence_list":[YGMallOrderEvidence class]};
}

- (CGFloat)evidenceHeight:(CGFloat)unitH spacing:(CGFloat)spacing
{
    NSInteger amount = self.evidence_list.count;
    return amount==0?0.f:(amount+1) * unitH + (amount+2) * spacing;
}

+ (instancetype)createWithCommodity:(CommodityModel *)commodity
{
    if (!commodity) {
        return nil;
    }
    
    YGMallOrderCommodity *oc = [YGMallOrderCommodity new];
    oc.spec_name = commodity.specName;
    oc.price = commodity.sellingPrice * 100;
    oc.photo_image = commodity.photoImage;
    oc.quantity = commodity.quantity;
    oc.commodity_name = commodity.commodityName;
    oc.commodity_id = commodity.commodityId;
    oc.commodity_type = commodity.commodityType;
    oc.give_yunbi = commodity.giveYunbi * 100;
    oc.brand_id = commodity.brandId;
    oc.category_id = commodity.categoryId;
    oc.sku_id = commodity.skuid;
    
    return oc;
}

+ (instancetype)createWithCommodityInfo:(CommodityInfoModel *)commodity
{
    if (!commodity) {
        return nil;
    }
    
    YGMallOrderCommodity *oc = [YGMallOrderCommodity new];
    oc.photo_image = commodity.photoImage;
    oc.commodity_name = commodity.commodityName;
    oc.commodity_id = commodity.commodityId;
    oc.commodity_type = commodity.commodityType;
    oc.give_yunbi = commodity.yunbi * 100;
    oc.brand_id = commodity.brand_id;
    oc.category_id = commodity.categoryId;
    
    if (commodity.auctionId > 0 && commodity.auctionStatus == 2) {
        oc.price = commodity.lastPrice * 100;
    }else{
        oc.price = commodity.sellingPrice * 100;
    }
    return oc;
}

@end

@implementation YGMallOrderEvidence
YYModelDefaultCode
@end
