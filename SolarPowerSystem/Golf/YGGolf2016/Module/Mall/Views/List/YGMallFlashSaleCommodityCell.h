//
//  YGMallFlashSaleCommodityCell.h
//  Golf
//
//  Created by bo wang on 2016/11/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallFlashSaleCommodityCell;

@interface YGMallFlashSaleCommodityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet UILabel *saleStockBlurLabel;


@property (weak, nonatomic) IBOutlet UILabel *commodityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *saleStockLabel;//仅剩%d件
@property (weak, nonatomic) IBOutlet UILabel *commodityPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityOriginPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *saleStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *saleActionBtn;

@property (strong, nonatomic) CommodityModel *commodity;
- (void)configureWithCommodity:(CommodityModel *)commodity;

@end

UIKIT_EXTERN NSString *const kYGMallFlashSaleDateCell;

@interface YGMallFlashSaleDateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (void)configureWithCommodity:(CommodityModel *)commodity;
@end
