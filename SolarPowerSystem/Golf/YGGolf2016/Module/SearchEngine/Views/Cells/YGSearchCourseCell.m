//
//  YGSearchClubCell.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchCourseCell.h"

@implementation YGSearchCourseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.nameLabel.ignoreCommonProperties = YES;
    self.nameLabel.layer.opaque = YES;
}

- (void)configureWithEntity:(__kindof YGSearchViewModel *)entity
{
    [super configureWithEntity:entity];
    
    YGSearchCourseViewModel *vm = entity;
    if (![vm isKindOfClass:[YGSearchCourseViewModel class]]) {
        return;
    }
    self.nameLabel.textLayout = vm.nameLayout;
}

@end
