//
//  CommodityBaseInfoModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-27.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "CommodityBaseModel.h"
#import "YYModel.h"

@interface SoldModel () <YYModel>
@end

@implementation SoldModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    return @{@"specId":@"spec_id",
             @"specName":@"spec_name",
             @"stockQuantity":@"stock_quantity",
             @"soldQuantity":@"sold_quantity"};
}

- (id)initWithDic:(id)data{
    
    self = [super init];
    if (![self yy_modelSetWithDictionary:data]) {
        return nil;
    }
    return self;
    
//    if(!data || ![data isKindOfClass:[NSDictionary class]]){
//        return nil;
//    }
//    self = [super init];
//    if(!self) {
//        return nil;
//    }
//    
//    NSDictionary *dic = (NSDictionary *)data;
//    if ([dic objectForKey:@"spec_id"]) {
//        self.specId = [[dic objectForKey:@"spec_id"] intValue];
//    }
//    if ([dic objectForKey:@"spec_name"]) {
//        self.specName = [dic objectForKey:@"spec_name"];
//    }
//    if ([dic objectForKey:@"sold_quantity"]) {
//        self.soldQuantity = [[dic objectForKey:@"sold_quantity"] intValue];
//    }
//    if ([dic objectForKey:@"stock_quantity"]) {
//        self.stockQuantity = [[dic objectForKey:@"stock_quantity"] intValue];
//    }
//    return self;
}
YYModelDefaultCode
@end


@implementation CommodityBaseModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"commodity_id"]) {
        self.commodityId = [[dic objectForKey:@"commodity_id"] intValue];
    }
    if ([dic objectForKey:@"commodity_name"]) {
        self.commodityName = [dic objectForKey:@"commodity_name"];
    }
    if ([dic objectForKey:@"photo_image"]) {
        self.photoImage = [dic objectForKey:@"photo_image"];
    }
    if ([dic objectForKey:@"freight"]) {
        self.freight = [[dic objectForKey:@"freight"] intValue] / 100;
    }
    if ([dic objectForKey:@"commodity_type"]) {
        self.commodityType = [[dic objectForKey:@"commodity_type"] intValue];
    }
    if ([dic objectForKey:@"auction_id"]) {
        self.auctionId = [[dic objectForKey:@"auction_id"] intValue];
    }
    if ([dic objectForKey:@"quantity_list"]) {
        NSArray *array = [dic objectForKey:@"quantity_list"];
        if (array && array.count > 0) {
            NSMutableArray *mutarray = [NSMutableArray array];
            for (id obj in array) {
                SoldModel *m = [[SoldModel alloc] initWithDic:obj];
                [mutarray addObject:m];
            }
            self.quantityList = mutarray;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super init]) {
        self.commodityId = [aDecoder decodeIntForKey:@"commodity_id"];
        self.commodityType = [aDecoder decodeIntForKey:@"commodity_type"];
        self.commodityName = [aDecoder decodeObjectForKey:@"commodity_name"];
        self.photoImage = [aDecoder decodeObjectForKey:@"photo_image"];
        self.freight = [aDecoder decodeIntForKey:@"freight"];
        self.auctionId = [aDecoder decodeIntForKey:@"auction_id"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:_commodityId forKey:@"commodity_id"];
    [aCoder encodeInt:_commodityType forKey:@"commodity_type"];
    [aCoder encodeObject:_commodityName forKey:@"commodity_name"];
    [aCoder encodeObject:_photoImage forKey:@"photo_image"];
    [aCoder encodeInt:_auctionId forKey:@"auction_id"];
    [aCoder encodeInt:_freight forKey:@"freight"];
}

- (id)copyWithZone:(NSZone *)zone {
    CommodityBaseModel *copy = [[[self class] allocWithZone:zone] init];
    copy.commodityId = self.commodityId;
    copy.commodityType = self.commodityType;
    copy.commodityName = [self.commodityName copyWithZone:zone];
    copy.photoImage = [self.photoImage copyWithZone:zone];
    copy.freight = self.freight;
    copy.auctionId = self.auctionId;
    copy.quantityList = self.quantityList;
    
    return copy;
}

@end
