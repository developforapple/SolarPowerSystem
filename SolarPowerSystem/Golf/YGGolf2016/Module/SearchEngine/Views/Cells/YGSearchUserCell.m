//
//  YGSearchUserCell.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchUserCell.h"

@implementation YGSearchUserCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userNameLabel.ignoreCommonProperties = YES;
    self.userInfoLabel.ignoreCommonProperties = YES;
    self.userNameLabel.layer.opaque = YES;
    self.userInfoLabel.layer.opaque = YES;
}

- (void)configureWithEntity:(__kindof YGSearchViewModel *)entity
{
    [super configureWithEntity:entity];

    YGSearchUserViewModel *vm = entity;
    if (![vm isKindOfClass:[YGSearchUserViewModel class]]) {
        return;
    }
    
    [self.userImageView sd_setImageWithURL:vm.imageURL placeholderImage:[UIImage imageNamed:@"head_image"]];
    self.userNameLabel.textLayout = vm.titleLayout;
    self.userInfoLabel.textLayout = vm.subtitleLayout;
}

@end
