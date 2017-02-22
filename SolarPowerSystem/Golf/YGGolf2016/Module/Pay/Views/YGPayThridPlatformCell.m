//
//  YGPayThridPlatformCell.m
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayThridPlatformCell.h"
#import <PassKit/PKPaymentButton.h>

NSString *const kYGPayThridPlatformCell = @"YGPayThridPlatformCell";

@implementation YGPayThridPlatformCell

- (void)configureWithItem:(YGPayPlatformItem *)item
{
    _platformItem = item;
    self.iconImageView.image = [UIImage imageNamed:item.iconName];
    self.platformNameLabel.text = item.title;
    self.platformDescLabel.text = item.desc;
    self.decorateImageView.image = [UIImage imageNamed:item.decorateImageName];
    self.decorateImageView.hidden = item.decorateImageName.length==0;
    self.selectedBtn.selected = item.selected;
}

- (IBAction)selectedPlatform:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.platformItem.selected = !self.platformItem.selected;
    if (self.selectionDidChanged) {
        self.selectionDidChanged(self.platformItem);
    }
}

@end
