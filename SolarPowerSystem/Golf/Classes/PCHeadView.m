//
//  PCHeadView.m
//  Golf
//
//  Created by 黄希望 on 15/6/24.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PCHeadView.h"

@implementation PCHeadView

- (IBAction)buttonPressedAction:(id)sender{
    if (_resp) {
        _resp (nil);
    }
}

@end
