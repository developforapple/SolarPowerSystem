//
//  YGSearchHeaderFooterCell.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchHeaderFooterCell.h"

@implementation YGSearchHeaderFooterCell

- (void)setUsedForHeader:(BOOL)usedForHeader
{
    _usedForHeader = usedForHeader;
    
    self.headerTitleLabel.hidden = !usedForHeader;
    self.footerBtn.hidden = usedForHeader;
}

- (void)configureWithEntity:(id)entity
{
    [super configureWithEntity:entity];
    
    if (![entity isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (_usedForHeader) {
        self.headerTitleLabel.text = entity;
    }else{
        [self.footerBtn setTitle:entity forState:UIControlStateNormal];
    }
}

@end
