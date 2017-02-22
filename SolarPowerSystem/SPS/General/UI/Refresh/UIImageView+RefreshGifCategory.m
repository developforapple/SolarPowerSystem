//
//  UIImageView+RefreshGifCategory.m
//  Golf
//
//  Created by bo wang on 16/9/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIImageView+RefreshGifCategory.h"

//static void *animationDidFinishedKey = &animationDidFinishedKey;
//@interface NSObject (AnimationSwizzing) <YGAnimaitonProtocol>
//@end
//@implementation NSObject (AnimationSwizzing)
//- (void)yg_animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    [self yg_animationDidStop:anim finished:flag];
//    
//    if (self.yg_animationDidFinished) {
//        if ([self isKindOfClass:NSClassFromString(@"_UIImageViewExtendedStorage")] &&
//            [anim isKindOfClass:[CAKeyframeAnimation class]] &&
//            [[(CAKeyframeAnimation *)anim keyPath] isEqualToString:@"contents"]) {
//            self.yg_animationDidFinished((CAKeyframeAnimation *)anim,flag);
//        }
//    }
//}
//
//- (void)setYg_animationDidFinished:(YGAnimationFinishedBlock)animationDidFinished
//{
//    objc_setAssociatedObject(self, animationDidFinishedKey, animationDidFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (YGAnimationFinishedBlock)yg_animationDidFinished
//{
//    return objc_getAssociatedObject(self, animationDidFinishedKey);
//}
//@end

static void *yg_animationKeepLastStatusKey = &yg_animationKeepLastStatusKey;

@implementation CALayer (YGAnimation)

DDSwizzleMethod

- (BOOL)yg_animationKeepLastStatus
{
    return [objc_getAssociatedObject(self, yg_animationKeepLastStatusKey) boolValue];
}

- (void)setYg_animationKeepLastStatus:(BOOL)yg_animationKeepLastStatus
{
    if (yg_animationKeepLastStatus) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SEL oldSel = @selector(addAnimation:forKey:);
            SEL newSel = @selector(yg_addAnimation:forKey:);
            [[self class] swizzleInstanceSelector:oldSel withNewSelector:newSel];
        });
    }
    
    objc_setAssociatedObject(self, yg_animationKeepLastStatusKey, @(yg_animationKeepLastStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)yg_addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
    if (self.yg_animationKeepLastStatus) {
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = NO;
    }
    [self yg_addAnimation:anim forKey:key];
}

@end

#import "ReactiveCocoa.h"

@implementation UIImageView (RefreshGifCategory)

DDSwizzleMethod

- (BOOL)yg_animationKeepLastStatus
{
    return self.layer.yg_animationKeepLastStatus;
}

- (void)setYg_animationKeepLastStatus:(BOOL)yg_animationKeepLastStatus
{
    if (yg_animationKeepLastStatus) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            SEL oldSel = @selector(stopAnimating);
//            SEL newSel = @selector(yg_stopAnimating);
//            [[self class] swizzleInstanceSelector:oldSel withNewSelector:newSel];
//        });
    }
    self.layer.yg_animationKeepLastStatus = yg_animationKeepLastStatus;
}

- (void)yg_stopAnimating
{
    if (self.yg_animationKeepLastStatus && [self isAnimating]) {
        [UIView animateWithDuration:.2f animations:^{
            self.layer.contents = nil;
        }];
    }
    [self yg_stopAnimating];
}

//- (id<YGAnimaitonProtocol>)animationsDelegate
//{
//    @try {
//        return [self valueForKey:@"storage"];
//    } @catch (NSException *exception) {
//        return nil;
//    }
//}
//
//- (void)setYg_animationDidFinished:(YGAnimationFinishedBlock)animationDidFinished
//{
//    [[self animationsDelegate] setYg_animationDidFinished:animationDidFinished];
//}
//
//- (YGAnimationFinishedBlock)yg_animationDidFinished
//{
//    return [[self animationsDelegate] yg_animationDidFinished];
//}

@end
