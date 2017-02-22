//
//  ManagementOrderTableViewCell.m
//  Golf
//
//  Created by zhengxi on 15/12/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ManagementOrderTableViewCell.h"

NSString *const kManagementOrderTableViewCell = @"ManagementOrderTableViewCell";

@implementation ManagementOrderTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.trailingLabel.hidden = NO;
}

@end
