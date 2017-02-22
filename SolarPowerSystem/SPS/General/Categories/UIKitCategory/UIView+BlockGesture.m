//
//  UIView+BlockGesture.m
//  Golf
//
//  Created by bo wang on 2016/12/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIView+BlockGesture.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static void *setupUserInteractionOutsideKey = &setupUserInteractionOutsideKey;

@implementation UIView (BlockGesture)

- (void)setSetupUserInteractionOutside:(BOOL)setupUserInteractionOutside
{
    objc_setAssociatedObject(self, setupUserInteractionOutsideKey, @(setupUserInteractionOutside), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)setupUserInteractionOutside
{
    return [objc_getAssociatedObject(self, setupUserInteractionOutsideKey) boolValue];
}

- (void)enabledUserInteractionIfNeed
{
    if (!self.setupUserInteractionOutside) {
        self.userInteractionEnabled = YES;
    }
}

- (void)fixConflictForSingleTap:(UITapGestureRecognizer *)singleTap
{
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        if ([gr isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gr;
            if (tap.numberOfTapsRequired >= 2 && tap.numberOfTouchesRequired >= 1) {
                [singleTap requireGestureRecognizerToFail:tap];
            }
        }
    }
}

- (void)fixConflictForDoubleTap:(UITapGestureRecognizer *)doubleTap
{
    for (UIGestureRecognizer *gr in self.gestureRecognizers) {
        if ([gr isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gr;
            if (tap.numberOfTapsRequired == 1 && tap.numberOfTouchesRequired == 1) {
                [tap requireGestureRecognizerToFail:doubleTap];
            }
        }
    }
}

- (UITapGestureRecognizer *)whenTapped:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:tap];
    [self fixConflictForSingleTap:tap];
    return tap;
}

- (UITapGestureRecognizer *)whenDoubleTapped:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;
    [tap.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:tap];
    [self fixConflictForDoubleTap:tap];
    return tap;
}

- (UITapGestureRecognizer *)whenDoubleTouchTapped:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTouchesRequired = 2;
    [tap.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:tap];
    return tap;
}

- (UILongPressGestureRecognizer *)whenLongPressed:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] init];
    [lp.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:lp];
    return lp;
}

- (UIPanGestureRecognizer *)whenPan:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:pan];
    return pan;
}

- (UIPinchGestureRecognizer *)whenPinch:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] init];
    [pinch.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:pinch];
    return pinch;
}

- (UIRotationGestureRecognizer *)whenRotation:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] init];
    [rotation.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:rotation];
    return rotation;
}

- (UISwipeGestureRecognizer *)whenSwip:(YGGestureBlock)block
{
    return [self whenSwipDirection:UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown block:block];
}

- (UISwipeGestureRecognizer *)whenSwipDirection:(UISwipeGestureRecognizerDirection)direction block:(YGGestureBlock)block
{
    [self enabledUserInteractionIfNeed];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] init];
    swipe.direction = direction;
    [swipe.rac_gestureSignal subscribeNext:block];
    [self addGestureRecognizer:swipe];
    return swipe;
}

@end
