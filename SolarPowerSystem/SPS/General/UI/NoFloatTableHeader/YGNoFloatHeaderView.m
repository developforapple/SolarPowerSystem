//
//  YGNoFloatHeaderView.m
//  Golf
//
//  Created by bo wang on 16/6/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGNoFloatHeaderView.h"

@implementation YGNoFloatHeaderView

- (void)setFrame:(CGRect)frame
{
    CGRect sectionRect = [self.tableView rectForSection:self.section];
    frame.origin.y = CGRectGetMinY(sectionRect);
    [super setFrame:frame];
}

@end