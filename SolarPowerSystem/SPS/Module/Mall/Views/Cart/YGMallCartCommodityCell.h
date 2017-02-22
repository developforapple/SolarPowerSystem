//
//  YGMallCartCommodityCell.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallQuantityControl.h"
#import "YYLabel.h"

@class CommodityModel;
@class YGMallCart;

UIKIT_EXTERN NSString *const kYGMallCartCommodityCell;

/**
 商城购物车商品列表中的商品
 */
@interface YGMallCartCommodityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet UILabel *commodityStateLabel;
@property (weak, nonatomic) IBOutlet YYLabel *commodityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commoditySpecLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityPriceLabel;
@property (weak, nonatomic) IBOutlet YGMallQuantityControl *quantitySelectionView;

@property (weak, nonatomic) IBOutlet UIView *extraInfoPanel;

/**
 当数量手动将至0时提示用户是否是删除该商品。
 */
@property (copy, nonatomic) void (^willDeleteCallback)(CommodityModel *commodity);

/**
 数量发生变化后的回调
 */
@property (copy, nonatomic) void (^didChangedQuantityCallback)(CommodityModel *commodity);

@property (strong, readonly, nonatomic) CommodityModel *commodity;
- (void)configureWithCommodity:(CommodityModel *)commodity inCart:(YGMallCart *)cart;

@end
