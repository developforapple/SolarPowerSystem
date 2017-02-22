//
//  UnOpenTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "UnOpenTableViewCell.h"

@implementation UnOpenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //解决该死的大于320宽度显示偏差的问题
    for (NSLayoutConstraint *c in [[_labelCityName superview] constraints]) {
        if (c.firstItem == _labelCityName && c.firstAttribute == NSLayoutAttributeLeadingMargin) {
            if (Device_Width > 320 || Device_SysVersion >= 8.3) {
                c.constant = 15;
            }
            [_labelCityName layoutIfNeeded];
            break;
        }
    }
}

@end
