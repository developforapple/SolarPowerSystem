

#import <Foundation/Foundation.h>

@class CommodityModel;

/**
 商城购物车中商品分组模型
 */
@interface YGMallCartGroup : NSObject

// 旧版本使用
@property (nonatomic,assign) int freight;
@property (nonatomic,assign) int totalPrice;
@property (nonatomic,assign) int totalQuantity;
@property (nonatomic,assign) int commodityType;
@property (nonatomic,assign) BOOL canBuy;
@property (nonatomic,strong) NSMutableArray<CommodityModel *> *commodityList;

// 新的购物车使用
@property (assign, nonatomic) NSUInteger agentId;
@property (strong, nonatomic) NSString *agentName;
@property (strong, nonatomic) NSArray<CommodityModel *> *commodity;
- (instancetype)initWithDic:(NSDictionary *)dic;

// 商品分组内的所有商品
+ (NSArray<CommodityModel *> *)commoditiesAtGroup:(NSArray<YGMallCartGroup *> *)groups;
// 商品分组内的可购买商品
+ (NSArray<CommodityModel *> *)buyableCommoditiesAtGroup:(NSArray<YGMallCartGroup *> *)groups;

@end
