//
//  ClickView.m
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ClickView.h"

@implementation ClickView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_respEvent) {
        _respEvent (@(self.tag));
    }
}

@end
