//
//  YGTextField.m
//  Golf
//
//  Created by bo wang on 2016/11/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGTextField.h"

@implementation YGTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([UIMenuController sharedMenuController]) {
        [UIMenuController sharedMenuController].menuVisible = self.longPressEnabled;
    }
    return NO;
}

@end
