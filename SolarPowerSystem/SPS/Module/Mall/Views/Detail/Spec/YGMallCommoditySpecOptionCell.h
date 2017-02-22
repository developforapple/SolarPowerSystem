//
//  YGMallCommoditySpecOptionCell.h
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallQuantityControl.h"

@class CommoditySpecAttr;
@class CommoditySpecSKUModel;

UIKIT_EXTERN NSString *const kYGMallCommoditySpecOptionCell;    //普通选项
UIKIT_EXTERN NSString *const kYGMallCommoditySpecQuantityCell;  //选数量

@interface YGMallCommoditySpecOptionCell : UICollectionViewCell

+ (CGSize)sizeOfOption:(CommoditySpecAttr *)option;

// For Option
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (strong, readonly, nonatomic) CommoditySpecAttr *option;
- (void)configureWithOption:(CommoditySpecAttr *)option;

// For Quantity
@property (weak, nonatomic) IBOutlet YGMallQuantityControl *quantityControl;
@property (weak, nonatomic) IBOutlet UILabel *quantityNotice;
@property (copy, nonatomic) void (^quantityDidChanged)(NSInteger quantity);
@property (strong, readonly, nonatomic) CommoditySpecSKUModel *sku;
- (void)configureWithSKU:(CommoditySpecSKUModel *)sku;
@property (strong, readonly, nonatomic) CommodityInfoModel *commodity;
- (void)configureWithCommodity:(CommodityInfoModel *)commodity;

@end
