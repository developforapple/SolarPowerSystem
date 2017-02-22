//
//  CommodityBaseInfoModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-27.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoldModel : NSObject <NSCopying,NSCoding>

@property (nonatomic,assign) int specId;
@property (nonatomic,copy) NSString *specName;
@property (nonatomic,assign) int stockQuantity;
@property (nonatomic,assign) int soldQuantity;
@property (nonatomic) int quantityAfterSelected;
@property (nonatomic) int maxSelectQuantity;

- (id)initWithDic:(id)data;

@end

@interface CommodityBaseModel : NSObject<NSCoding,NSCopying>

@property (nonatomic) int commodityId;
@property (nonatomic) int commodityType;
@property (nonatomic,copy) NSString *commodityName;
@property (nonatomic,copy) NSString *photoImage;
@property (nonatomic) int freight;
@property (nonatomic) int auctionId;

@property (nonatomic,strong) NSArray *quantityList;

- (id)initWithDic:(id)data;

@end
