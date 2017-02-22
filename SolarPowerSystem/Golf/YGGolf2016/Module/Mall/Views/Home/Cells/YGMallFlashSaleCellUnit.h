//
//  YGMallFlashSaleCellUnit.h
//  Golf
//
//  Created by bo wang on 2016/11/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallFlashSaleCellUnit;

@interface YGMallFlashSaleCellUnit : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *surplusLabel;
//@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;

@property (strong, nonatomic) CommodityModel *commodity;
- (void)configureWithCommodity:(CommodityModel *)commodity;

@end
