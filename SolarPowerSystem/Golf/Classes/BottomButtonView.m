//
//  BottomButtonView.m
//  Golf
//
//  Created by zhengxi on 15/12/24.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BottomButtonView.h"

@implementation BottomButtonView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)cancelButtonClicked:(id)sender {
    if (_cancelButtonBlock) {
        _cancelButtonBlock();
    }
}

- (IBAction)customerButtonClicked:(id)sender {
    if (_customerButtonBlock) {
        _customerButtonBlock();
    }
}
@end
