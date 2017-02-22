//
//  YGSearchYueduCell.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchYueduCell.h"

@implementation YGSearchYueduCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.yueduTitleLabel.ignoreCommonProperties = YES;
    self.yueduTitleLabel.layer.opaque = YES;
}

- (void)configureWithEntity:(__kindof YGSearchViewModel *)entity
{
    [super configureWithEntity:entity];
    
    YGSearchNewsViewModel *vm = entity;
    if (![vm isKindOfClass:[YGSearchNewsViewModel class]]) {
        return;
    }
    
    ygweakify(self);
    self.yueduImageView.contentMode = UIViewContentModeCenter;
    [self.yueduImageView sd_setImageWithURL:vm.imageURL placeholderImage:[YGSearchBaseCell defaultPlaceholder] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            ygstrongify(self);
            self.yueduImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
    self.yueduVideoIndicator.hidden = !vm.videoIndicatorVisible;
    self.yueduTitleLabel.textLayout = vm.titleLayout;
    self.leftInfoLabel.text = vm.leftDesc;
    self.rightInfoLabel.text = vm.rightDesc;
}

@end
