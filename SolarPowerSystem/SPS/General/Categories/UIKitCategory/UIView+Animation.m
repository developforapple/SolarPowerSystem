//
//  UIView+Animation.m
//  Golf
//
//  Created by bo wang on 16/6/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIView+Animation.h"

static const void *kLockObjectKey = &kLockObjectKey;
static const void *kWillBeHiddenKey = &kWillBeHiddenKey;

@implementation UIView (Animation)

- (BOOL)needWait
{
    return [objc_getAssociatedObject(self, kLockObjectKey) boolValue];
}

- (void)setNeedWait:(BOOL)need
{
    objc_setAssociatedObject(self, kLockObjectKey, @(need), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)willBeHidden
{
    id hidden = objc_getAssociatedObject(self, kWillBeHiddenKey);
    if (!hidden) {
        return self.hidden;
    }
    return [hidden boolValue];
}

- (void)setWillBeHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, kWillBeHiddenKey, @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!animated){
        self.hidden = hidden;
        return;
    }
    
    if ([self willBeHidden] == hidden) {
        return;
    }
    
    if ([self needWait]) {
        RunAfter(.15f, ^{
            [self executeSetter:hidden];
        });
    }else{
        [self executeSetter:hidden];
    }
}

- (void)executeSetter:(BOOL)hidden
{
    CGFloat alpha = self.alpha;
    
    [self setWillBeHidden:hidden];
    
    [self setNeedWait:YES];
    if (hidden) {
        [UIView animateWithDuration:.15f animations:^{
            self.alpha = 0.f;
        } completion:^(BOOL finished) {
            self.hidden = hidden;
            self.alpha = alpha;
            [self setNeedWait:NO];
        }];
    }else{
        self.alpha = 0.f;
        self.hidden = NO;
        [UIView animateWithDuration:.15f animations:^{
            self.alpha = alpha;
        } completion:^(BOOL finished) {
            [self setNeedWait:NO];
        }];
    }
}

@end
