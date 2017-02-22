//
//  OneButtonView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "OneButtonView.h"

@implementation OneButtonView

- (IBAction)btnAction:(id)sender {
    if (_blockReturn) {
        _blockReturn(_data);
    }
}

@end
