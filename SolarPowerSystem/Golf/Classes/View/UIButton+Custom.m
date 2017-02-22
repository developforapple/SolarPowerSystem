//
//  UIButton+Custom.m
//  Golf
//
//  Created by user on 13-4-11.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)
+ (UIButton *)myButton:(id)target
                 Frame:(CGRect)frame
           NormalImage:(NSString*)norName
           SelectImage:(NSString*)selName
                 Title:(NSString*)title
            TitleColor:(UIColor*)color
                  Font:(float)size
                Action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:frame];
    [btn setBackgroundImage:[UIImage imageNamed:norName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:selName] forState:UIControlStateHighlighted];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:size];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
