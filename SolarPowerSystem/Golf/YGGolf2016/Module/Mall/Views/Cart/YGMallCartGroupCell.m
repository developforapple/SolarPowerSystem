//
//  YGMallCartGroupCell.m
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCartGroupCell.h"
#import "YGMallCart.h"

@implementation YGMallCartGroupCell

- (void)configureWithGroup:(YGMallCartGroup *)group inCart:(YGMallCart *)cart
{
    _group = group;
    self.groupTitleLabel.text = group.agentName;
    self.selectionBtn.selected = [cart isGroupSelectedAll:group];
}

- (IBAction)selectAll:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (self.groupSelectionBlock) {
        self.groupSelectionBlock(self.group);
    }
}

@end

NSString *const kYGMallCartGroupCell = @"YGMallCartGroupCell";
