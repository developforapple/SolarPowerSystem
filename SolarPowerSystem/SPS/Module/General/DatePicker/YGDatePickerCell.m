//
//  YGDatePickerCell.m
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGDatePickerCell.h"

NSString *const kYGDatePickerCell = @"YGDatePickerCell";

@implementation YGDatePickerCell

- (UIView *)selectedBackgroundView
{
    UIView *view = [super selectedBackgroundView];
    if (!view) {
        view = [[UIView alloc] initWithFrame:self.contentView.bounds];
        view.backgroundColor = RGBColor(36, 157, 243, 1);
        view.layer.cornerRadius = 4.f;
        view.layer.masksToBounds = YES;
        self.selectedBackgroundView = view;
    }
    return view;
}

@end
