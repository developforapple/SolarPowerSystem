//
//  YGSearchCommodityCell.m
//  Golf
//
//  Created by bo wang on 16/8/1.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchCommodityCell.h"

@implementation YGSearchCommodityCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.nameLabel.ignoreCommonProperties = YES;
    self.nameLabel.layer.opaque = YES;
}

- (void)configureWithEntity:(__kindof YGSearchViewModel *)entity
{
    [super configureWithEntity:entity];
    
    YGSearchCommodityViewModel *vm = entity;
    if (![vm isKindOfClass:[YGSearchCommodityViewModel class]]) {
        return;
    }
    
    ygweakify(self);
    self.commodityImageView.contentMode = UIViewContentModeCenter;
    [self.commodityImageView sd_setImageWithURL:vm.commodityImageURL placeholderImage:[YGSearchBaseCell defaultPlaceholder] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            ygstrongify(self);
            self.commodityImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
    self.nameLabel.textLayout = vm.commodityTitleLayout;
}

@end
