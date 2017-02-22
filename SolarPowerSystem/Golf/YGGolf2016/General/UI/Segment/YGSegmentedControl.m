//
//  YGSegmentedControl.m
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSegmentedControl.h"

@implementation YGSegmentedControl

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    
    if (!self.showsCount) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL sel = @selector(buttons);
    if ([super respondsToSelector:sel]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *btns = [super performSelector:sel];
#pragma clang diagnostic pop
        for (UIButton *button in btns) {

            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitleForState:state]];
            
            string.yy_font = self.font;
            string.yy_color = color;
            
            [button setAttributedTitle:string forState:state];
        }
    }
}

@end
