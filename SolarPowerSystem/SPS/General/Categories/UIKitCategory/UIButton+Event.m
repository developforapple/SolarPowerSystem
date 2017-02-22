//
//  UIButton+LW.m
//  Laiwang
//
//  Created by Lings on 13-11-29.
//  Copyright (c) 2013年 Alibaba(China)Technology Co.,Ltd. All rights reserved.
//

#import "UIButton+Event.h"
#import <objc/runtime.h>

static void * kHitEdgeInsetsKey = &kHitEdgeInsetsKey;

@implementation UIButton (Event)

@dynamic hitEdgeInsets;

- (void)setHitEdgeInsets:(UIEdgeInsets)hitEdgeInsets
{
    NSValue *value = [NSValue valueWithUIEdgeInsets:hitEdgeInsets];
    objc_setAssociatedObject(self, kHitEdgeInsetsKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitEdgeInsets
{
    NSValue * value = objc_getAssociatedObject(self, kHitEdgeInsetsKey);
    if(value) {
        return [value UIEdgeInsetsValue];
    }
    
    return UIEdgeInsetsZero;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.hitEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
