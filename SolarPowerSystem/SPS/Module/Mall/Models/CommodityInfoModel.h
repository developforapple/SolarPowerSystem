//
//  CommodityInfoModel.h
//  Golf
//
//  Created by 黄希望 on 14-5-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFlashSaleModel.h"

@class CommoditySpecSKUModel;
@class CommoditySpecAttrModel;
@class CommoditySpecAttr;
@class SoldModel;

/**
 此Model已经使用YYModel扩展
 */
@interface CommodityInfoModel : NSObject <NSCoding,NSCopying>

// 下面的价格精确到元，服务器数据精确到分
@property (nonatomic) int categoryId;
@property (nonatomic,copy) NSString *introduction;
@property (nonatomic) int originalPrice;
@property (nonatomic) int sellingPrice;
@property (nonatomic,copy) NSString *commodityDetail;
@property (nonatomic) int stockQuantity;
@property (nonatomic) int soldQuantity;
@property (nonatomic) int commentQuantity;
@property (nonatomic,assign) int buyLimit;
@property (nonatomic,copy) NSString *buyGuide;
@property (nonatomic,assign) int highPraiseRate;

@property (nonatomic,strong) NSArray<NSString *> *pictureList;

@property (nonatomic) int auctionStatus;
@property (nonatomic,copy) NSString *auctionTime;
@property (nonatomic) int beginPrice;
@property (nonatomic) int lastPrice;
@property (nonatomic) int nextInterval;
@property (nonatomic) int commodityIntervalTime;
@property (nonatomic,copy) NSString *serverTime;
@property (nonatomic) int markdown;
@property (nonatomic) int auctionFreight;
@property (nonatomic) int sellingStatus; //2 已下架 3 已售罄 
@property (nonatomic) int specId;
@property (nonatomic, copy) NSString *spec_name;

@property (nonatomic,copy) NSString *submitTime;
@property (nonatomic,copy) NSString *payDuration;
@property (nonatomic,strong) NSString *endTime;
@property (nonatomic) int yunbi;

@property (nonatomic) int relativeId;
@property (nonatomic) int relativeType;
@property (nonatomic) int agentId;
@property (nonatomic, copy) NSString *agent_name;

@property (nonatomic) int commodityId;
@property (nonatomic) int commodityType;
@property (nonatomic,copy) NSString *commodityName;
@property (nonatomic,copy) NSString *photoImage;
@property (nonatomic) int freight;
@property (nonatomic) int auctionId;

@property (nonatomic) int brand_id;

// 旧的规格选项，此属性在7.2版被新的属性代替
@property (nonatomic,strong) NSArray<SoldModel *> *quantityList;

- (id)initWithDic:(id)data;

+ (CommodityInfoModel *)instanceByNodes:(NSMutableDictionary *)nodes;

// 7.2新增内容
// 新的规格选项
@property (strong, nonatomic) NSArray<CommoditySpecSKUModel *> *skuArray;
@property (strong, nonatomic) NSArray<CommoditySpecAttrModel *> *attrArray;

/**
 根据已选的规格，更新规格列表的可选性。当attrArray只有1个纬度时为特殊情况。

 @param selectedAttrList 已选择的规格
 */
- (void)updateAttrArrayBySelectedAttr:(NSArray<CommoditySpecAttr *> *)selectedAttrList;

/**
 根据已选的规格，返回匹配的sku。已选规格种类没有达到全部规格种类时，返回nil

 @param selectedAttrList 已选择的规格

 @return sku
 */
- (CommoditySpecSKUModel *)skuWithSelectedAttr:(NSArray<CommoditySpecAttr *> *)selectedAttrList;

/**
 为sku生成一个描述字符串

 @param sku sku
 @return
 */
- (NSString *)skuDescTitle:(CommoditySpecSKUModel *)sku;

/**
 根据skuid查找sku model
 */
- (CommoditySpecSKUModel *)skuWithId:(NSInteger)skuid;

// 7.3 新增内容
/**
 商品抢购数据
 */
@property (strong, nonatomic) YGFlashSaleModel *flash_sale;
/**
 当前用户是否添加了到货提醒
 */
@property (assign, nonatomic) BOOL arrival_notice;
@end

// 新的model，7.2版合并订单功能新增
@interface CommoditySpecSKUModel : NSObject <NSCoding,NSCopying>
@property (assign, nonatomic) NSInteger stock_quantity;//库存量
@property (assign, nonatomic) NSInteger original_price;//原始价格，分
@property (assign, nonatomic) NSInteger selling_price; //销售价格，分
@property (assign, nonatomic) NSInteger skuId;        //skuid
@property (strong, nonatomic) NSString *attrKey;      //attrKey
@property (assign, nonatomic) NSInteger sold_quantity; //已售出
@property (assign, nonatomic) NSInteger buy_limit;

// 非服务器字段。保存对应的attrId列表
@property (strong, nonatomic) NSIndexSet *attrIds;
// 非服务器字段。保存sku名称，需要外部生成。
@property (strong, nonatomic) NSString *skuName;

@end

@interface CommoditySpecAttrModel : NSObject <NSCoding,NSCopying>
@property (assign, nonatomic) NSInteger propId;
@property (copy,   nonatomic) NSString *propName;
@property (strong, nonatomic) NSArray<CommoditySpecAttr *> *attr;
@end

@interface CommoditySpecAttr : NSObject <NSCoding,NSCopying>
@property (assign, nonatomic) NSInteger attrId;
@property (copy,   nonatomic) NSString *attrValue;

@property (assign, nonatomic) BOOL selectable;  //非服务器字段。纪录该规格是否可选中。默认为YES
@property (assign, nonatomic) BOOL selected;    //非服务器字段。记录该规格是否已选中
@property (assign, nonatomic) NSInteger propId; //非服务器字段。记录该规格属于什么规格类型
@property (strong, nonatomic) NSArray<CommoditySpecSKUModel *> *validSKUList; //非服务器字段。可选的sku列表
@property (strong, nonatomic) NSArray<NSIndexSet *> *validSKUAttrIdList; //非服务器字段。可选的sku列表的attrId列表。

@property (assign, nonatomic) CGSize attrValueSizeCache;//非服务器字段。保存对应的cell尺寸。需要外部计算。

/**
 根据已选的规格，更新当前可选性

 @param selectedAttrList 已选择的规格
 */
- (BOOL)selectableBySelectedAttr:(NSArray<CommoditySpecAttr *> *)selectedAttrList;
@end
