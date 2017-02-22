//
//  YGMallOrderReviewCell.m
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderReviewCell.h"
#import "YGMallOrderModel.h"

@interface YGMallOrderReviewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewBtn;
@end

@implementation YGMallOrderReviewCell

- (void)setCommodity:(YGMallOrderCommodity *)commodity
{
    _commodity = commodity;
    
    [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photo_image]];
    self.commodityNameLabel.text = commodity.commodity_name;
    self.reviewBtn.enabled = !commodity.comment_status;
}

@end

NSString *const kYGMallOrderReviewCell = @"YGMallOrderReviewCell";
