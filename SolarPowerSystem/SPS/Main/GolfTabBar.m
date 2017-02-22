//
//  GolfTabBar.m
//  Golf
//
//  Created by lyf on 16/5/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "GolfTabBar.h"
#import "TheTabBarButton.h"

@interface GolfTabBar ()
@end

@implementation GolfTabBar
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.theTabBarButton = [[TheTabBarButton alloc] initWithFrame:CGRectMake(0, 0, self.width / 5, self.bounds.size.height)];
        [self addSubview:self.theTabBarButton];
    }
    return self;
}

- (void)setMiddleBtnTappedAction:(void (^)(void))middleBtnTappedAction
{
    self.theTabBarButton.blockClickedButton = middleBtnTappedAction;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.theTabBarButton.centerX = self.width*0.5;
    self.theTabBarButton.centerY = self.height*0.5;

    CGFloat tabBarButtonW = self.width / 5;
    CGFloat tabBarButtonIndex = 0;
    for (UIView *child in self.subviews) {
        Class class = NSClassFromString(@"UITabBarButton");
        if ([child isKindOfClass:class]) {
            // 设置x
            child.yg_x = tabBarButtonIndex * tabBarButtonW;
            // 设置宽度
            child.yg_w = tabBarButtonW;
            // 增加索引
            tabBarButtonIndex++;
            if (tabBarButtonIndex == 2) {
                tabBarButtonIndex++;
            }
        }
    }
}

@end
