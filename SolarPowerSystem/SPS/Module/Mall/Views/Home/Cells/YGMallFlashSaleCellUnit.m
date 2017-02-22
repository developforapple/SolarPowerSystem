//
//  YGMallFlashSaleCellUnit.m
//  Golf
//
//  Created by bo wang on 2016/11/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallFlashSaleCellUnit.h"

@implementation YGMallFlashSaleCellUnit

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}

- (void)configureWithCommodity:(CommodityModel *)commodity
{
    self.commodity = commodity;
    [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photoImage] placeholderImage:[UIImage imageNamed:@"default_"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"");
    }];
    
    YGFlashSaleModel *flashSale = commodity.flash_sale;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)flashSale.flash_price];
//    self.originPriceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)flashSale.selling_price];
    
    self.surplusLabel.text = [NSString stringWithFormat:@"仅剩%ld件",(long)flashSale.quantity];
}

@end

NSString *const kYGMallFlashSaleCellUnit = @"YGMallFlashSaleCellUnit";
