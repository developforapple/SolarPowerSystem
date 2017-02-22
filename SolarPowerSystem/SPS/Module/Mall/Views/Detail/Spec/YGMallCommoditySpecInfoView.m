//
//  YGMallCommoditySpecInfoView.m
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCommoditySpecInfoView.h"

@implementation YGMallCommoditySpecInfoView

- (void)configureWithAttrModel:(CommoditySpecAttrModel *)attrModel
{
    self.titleLabel.text = attrModel.propName;
}

@end

NSString *const kYGMallCommoditySpecHeader = @"YGMallCommoditySpecHeader";
