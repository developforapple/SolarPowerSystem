//
//  CommodityModel.m
//  Golf
//
//  Created by 黄希望 on 15/12/4.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "CommodityModel.h"

@implementation CommodityModel

- (id)initWithDic:(id)data
{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(self) {
        NSDictionary *dic = (NSDictionary *)data;
        if (dic[@"commodity_id"]) {
            self.commodityId = [dic[@"commodity_id"] integerValue];
        }
        if (dic[@"brand_id"]) {
            self.brandId = [dic[@"brand_id"] integerValue];
        }
        if (dic[@"category_id"]) {
            self.categoryId = [dic[@"category_id"] integerValue];
        }
        if (dic[@"sub_category_id"]) {
            self.subCategoryId = [dic[@"sub_category_id"] integerValue];
        }
        if (dic[@"sub_category_id"]) {
            self.subCategoryId = [dic[@"sub_category_id"] integerValue];
        }
        if (dic[@"commodity_name"]) {
            self.commodityName = dic[@"commodity_name"];
        }
        if (dic[@"photo_image"]) {
            self.photoImage = dic[@"photo_image"];
        }
        if (dic[@"original_price"]) {
            self.originalPrice = [dic[@"original_price"] intValue] / 100;
        }
        if (dic[@"selling_price"]) {
            self.sellingPrice = [dic[@"selling_price"] intValue] / 100;
        }
        if (dic[@"stock_quantity"]) {
            self.stockQuantity = [dic[@"stock_quantity"] intValue];
        }
        if (dic[@"sold_quantity"]) {
            self.soldQuantity = [dic[@"sold_quantity"] intValue];
        }
        self.remainQuantity = self.stockQuantity-self.soldQuantity;
        if (dic[@"freight"]) {
            self.freight = [dic[@"freight"] intValue] / 100;
        }
        if (dic[@"give_yunbi"]) {
            self.giveYunbi = [dic[@"give_yunbi"] intValue] / 100;
        }
        if (dic[@"agent_id"]) {
            self.agentId = [dic[@"agent_id"] integerValue];
        }
        if (dic[@"relative_id"]) {
            self.relativeId = [dic[@"relative_id"] integerValue];
        }
        if (dic[@"auction_time"]) {
            self.auctionTime = dic[@"auction_time"];
        }
        if (dic[@"spec_id"]) {
            self.specId = [dic[@"spec_id"] intValue];
        }
        if (dic[@"spec_name"]) {
            self.specName = dic[@"spec_name"];
        }
        if (dic[@"quantity"]) {
            self.quantity = [dic[@"quantity"] intValue];
        }
        if (dic[@"selling_status"]) {
            self.sellingStatus = [dic[@"selling_status"] intValue];
        }
        if (dic[@"buy_limit"]) {
            self.buyLimit = [dic[@"buy_limit"] intValue];
        }
        if (dic[@"commodity_type"]) {
            self.commodityType = [dic[@"commodity_type"] intValue];
        }
        if (dic[@"sku_id"]) {
            self.skuid = [dic[@"sku_id"] intValue];
        }
        
        if (dic[@"join_time"]) {
            self.join_time = [dic[@"join_time"] longLongValue]/1000.f;
        }
        
        self.flash_sale = [[YGFlashSaleModel alloc] initWithDic:dic[@"flash_sale"]];
    }
    return self;
}

//- (BOOL)isEqual:(CommodityModel *)object
//{
//    if (![object isKindOfClass:[CommodityModel class]]) return NO;
//    return self.commodityId == object.commodityId && self.specId == object.specId;
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@------spec:%@------id:%d------brand:%d------cate:%d------subcate:%d------freight:%d-----join_time:%f",self.commodityName,self.specName,(int)self.commodityId,(int)self.brandId,(int)self.categoryId,(int)self.subCategoryId,self.freight,self.join_time];
}

@end
