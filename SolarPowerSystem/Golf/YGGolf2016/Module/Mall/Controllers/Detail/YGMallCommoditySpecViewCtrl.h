//
//  YGMallCommoditySpecViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

/**
 商城商品详情页，购买商品时弹出的选择规格界面
 */
@interface YGMallCommoditySpecViewCtrl : BaseNavController

@property (strong, nonatomic) CommodityInfoModel *commodity;

@property (copy, nonatomic) void (^submitBlock)(CommoditySpecSKUModel *sku, NSInteger quantity);

- (void)show;
- (void)show:(CommodityInfoModel *)commodity;
- (void)dismiss;

- (void)reset;

@end
