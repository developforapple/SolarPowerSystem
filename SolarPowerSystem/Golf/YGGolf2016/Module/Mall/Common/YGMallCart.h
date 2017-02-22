//
//  YGMallCart.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGMallCartGroup.h"
#import "CommodityModel.h"

/**
 商城购物车
 */
@interface YGMallCart : NSObject

- (instancetype)init;

@property (assign, readonly, nonatomic) NSUInteger kinds; //购物车商品条目数量
@property (assign, readonly, nonatomic) CGFloat price; //选中的商品总价 单位：元

@property (strong, nonatomic) NSSet<NSString *> *defaultSelectionInfo;//初次加载数据时默认选中的商品信息。

// 7.3.1新增。保存服务器原始分组数据。 self.groups 作为数据源数据。
@property (strong, readonly, nonatomic) NSArray<YGMallCartGroup *> *originGroups;

// 7.3.1版本的购物车不再对商品进行分组。商品全部单个显示。但是在订单确认和详情页仍然存在分组。
@property (strong, readonly, nonatomic) NSArray<YGMallCartGroup *> *groups;          //分组列表
@property (strong, readonly, nonatomic) NSArray<YGMallCartGroup *> *editGroups;      //编辑状态下的分组列表
@property (strong, readonly, nonatomic) NSArray<CommodityModel *> *selectedList;     //选中商品列表
@property (strong, readonly, nonatomic) NSArray<CommodityModel *> *selectedEditList; //编辑状态下的选中商品列表

@property (assign, getter=isEditing, nonatomic) BOOL editing;   //当前是否处于编辑状态
@property (assign, getter=isEmpty, readonly, nonatomic) BOOL empty;       //当前列表是否为空

@property (strong, readonly, nonatomic) NSString *lastError;

// 购物车内容数据重置了的回调。发生于重新向服务器请求数据。编辑、删除操作后将会重新请求数据。
@property (copy, nonatomic) void (^cartResetCallbck)(BOOL suc);
// 购物车列表需要刷新的回调。发生于购物车进行了选择、取消选择等操作。
@property (copy, nonatomic) void (^updateCallback)(void);

// 向服务器获取最新购物车数据
- (void)loadCartData;

// 生成订单前的准备工作
// 返回只包含已选中商品，且类型为 commodityType 的分组列表。
- (NSArray<YGMallCartGroup *> *)prepareCrateOrder:(NSInteger)commodityType;

// 更新当前选中的商品总价 单位：元。
- (CGFloat)updatePrice;

// Selection
- (BOOL)canSelectCommodity:(CommodityModel *)commodity; //某个商品可不可以被选中。在编辑模式下，总是可以选中！
- (void)selectCommodity:(CommodityModel *)commodity;    //选中一个商品
- (void)justSelectCommodities:(NSArray<CommodityModel *> *)commodities;// 指定选中这些商品
- (void)deselectCommodity:(CommodityModel *)commodity;  //取消选中一个商品
- (void)convertSelection:(CommodityModel *)commodity;   //切换商品的选中状态
- (BOOL)isCommoditySelected:(CommodityModel *)commodity;//某个商品是否被选中
- (NSArray<CommodityModel *> *)selectedCommoditiesOfType:(NSInteger)commodityType;// 已选中commodityType商品
- (NSInteger)selectedCommodityType; // 当前选中的商品的整体类型。类型如果不一致，返回 -1

- (BOOL)canSelectGroup:(YGMallCartGroup *)group;        //某个分组可不可以被选中。编辑模式下总是可以选中。
- (void)selectGroup:(YGMallCartGroup *)group;           //选中整个分组
- (void)deselectGroup:(YGMallCartGroup *)group;         //取消选中整个分组
- (void)convertGroupSelection:(YGMallCartGroup *)group; //切换整个分组的选中状态
- (BOOL)isGroupSelectedAll:(YGMallCartGroup *)group; //某个分组是否已全部选中

- (BOOL)canSelectAll;                                   //是否可以选中全部商品。编辑模式下总是可以选中
- (void)selectAll;                                      //选中全部商品
- (void)deselectAll;                                    //取消选中全部商品
- (void)convertAllSelection;                            //切换全部商品的选中状态
- (BOOL)isSelectedAll;  //目前是否已全部选中

// Edit
// 从购物车删除部分商品，将先向服务器提交请求。删除成功后发生回调。但是当前数据不会马上更新。数据的更新仍然在 cartResetCallbck 中进行回调。
- (void)deleteCommodities:(NSArray<CommodityModel *> *)commodities
               completion:(void (^)(BOOL suc))completion;


// FeaturedCommodity
@property (strong, readonly, nonatomic) NSArray<CommodityModel *> *featuredCommodities;
@property (assign, readonly, nonatomic) NSUInteger pageNo;
@property (assign, readonly, nonatomic) NSUInteger pageSize;
@property (assign, readonly, nonatomic) BOOL hasMore;

/**
 从服务器获取购物车推荐的商品列表

 @param loadMore   是否是加载更多
 @param completion 回调
 */
- (void)loadFeaturedCommodity:(void (^)(BOOL suc,BOOL hasMore))completion;

@end

