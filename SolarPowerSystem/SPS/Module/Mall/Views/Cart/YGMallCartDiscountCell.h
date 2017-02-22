//
//  YGMallCartDiscountCell.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallCartDiscountCell;

/**
 商城购物车商品列表中优惠提示的cell
 */
@interface YGMallCartDiscountCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *discountIndicator;
@property (weak, nonatomic) IBOutlet UILabel *discountDescLabel;

@end
