//
//  YGOrdersSummaryCell.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrdersSummaryCell.h"

@implementation YGOrdersSummaryCell

- (void)setItem:(YGOrdersSummaryItem *)item
{
    _item = item;
    
    self.titleLabel.text = item.title;
    self.imageView.image = [UIImage imageNamed:item.iconName];
    
    self.amountBtn.hidden = item.waitpayAmount==0;
    [self.amountBtn setTitle:item.waitpayAmount>9?@"9+":[@(item.waitpayAmount) stringValue] forState:UIControlStateNormal];
}

@end

NSString *const kYGOrdersSummaryCell = @"YGOrdersSummaryCell";
