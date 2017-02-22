//
//  CommodityModel.h
//  Golf
//
//  Created by 黄希望 on 15/12/4.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGFlashSaleModel.h"

@interface CommodityModel : NSObject

@property (nonatomic,assign) NSInteger commodityId;
@property (nonatomic,assign) NSInteger brandId;
@property (nonatomic,assign) NSInteger categoryId;
@property (nonatomic,assign) NSInteger subCategoryId;
@property (nonatomic,strong) NSString *commodityName;
@property (nonatomic,strong) NSString *photoImage;
@property (nonatomic,assign) int originalPrice; // 原价，单位：元
@property (nonatomic,assign) int sellingPrice;  // 现价，单位：元
@property (nonatomic,assign) int stockQuantity;
@property (nonatomic,assign) int soldQuantity;
@property (nonatomic,assign) int remainQuantity; // 剩余数量
@property (nonatomic,assign) int freight;
@property (nonatomic,assign) NSInteger agentId;
@property (nonatomic,assign) NSInteger relativeId;
@property (nonatomic,assign) int giveYunbi;     //返云币,单位: 元
@property (nonatomic,strong) NSString *auctionTime; //抢拍时间，为空时没有抢拍活动 ”2014-06-13 18:00:00”
@property (nonatomic,assign) int commodityType; //1实物 2虚拟 3现金券

@property (nonatomic,assign) int specId; //品牌ID
@property (nonatomic,strong) NSString *specName; //”规格名称”,
@property (nonatomic,assign) int quantity; //数量
@property (nonatomic,assign) int sellingStatus; // 销售状态 1 销售中 2 已下架 3 已售罄
@property (nonatomic,assign) int buyLimit; // 购买上限
@property (nonatomic,assign) BOOL setting;// 是否设置到货提醒
@property (nonatomic,assign) int totalQuantity; // 选择的总数量
@property (nonatomic,assign) int skuid; //新版的购物车中使用skuid作为规格标识。

// 限时限购对象
@property (strong, nonatomic) YGFlashSaleModel *flash_sale;

// 商品在购物车中的最近更新时间戳。7.3.1启用
@property (assign, nonatomic) NSTimeInterval join_time;
// 商品所属商家名称。对应agentId。7.3.1启用
@property (copy, nonatomic) NSString *agentName;

/*
 下面三个属性为正在抢购状态. 7.3版弃用
 */
// 抢购id
@property (nonatomic,assign) int auctionId;
// 抢购状态
@property (nonatomic,assign) int auctionStatus;
// 最后一次降价的价格
@property (nonatomic,assign) int lastPrice;

- (id)initWithDic:(id)data;

@end
