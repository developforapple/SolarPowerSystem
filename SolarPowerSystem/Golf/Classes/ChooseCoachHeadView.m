//
//  ChooseCoachHeadView.m
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ChooseCoachHeadView.h"

@implementation ChooseCoachHeadView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.daohang) {
        self.daohang();
    }
}

@end
