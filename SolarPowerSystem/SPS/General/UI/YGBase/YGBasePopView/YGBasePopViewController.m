//
//  DDBasePopViewController.m
//  QuizUp
//
//  Created by Normal on 11/12/15.
//  Copyright © 2015 Bo Wang. All rights reserved.
//

#import "YGBasePopViewController.h"

@interface YGBasePopViewController ()

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UIWindow *previousWindow;
@end

@implementation YGBasePopViewController

- (void)show
{
    [self show:nil];
}

- (void)show:(void(^)(void))code
{
    [self initWindowWithLevel:UIWindowLevelStatusBar-1];
    [self show:.2f animations:code completed:nil];
}

- (void)show:(NSTimeInterval)duration animations:(void(^)(void))animations completed:(void(^)(void))completed
{
    if (!self.window) {
        [self initWindowWithLevel:UIWindowLevelStatusBar-1];
    }
    [UIView animateWithDuration:duration animations:^{
        self.window.alpha = 1.f;
        animations?animations():0;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        if (self.didDisplayed) {
            self.didDisplayed(self);
        }
        [self didShowAnimation];
        completed?completed():0;
    }];
}

- (void)showWithoutAnimation
{
    if (!self.window) {
        [self initWindowWithLevel:UIWindowLevelStatusBar-1];
    }
    self.window.alpha = 1.f;
    self.view.userInteractionEnabled = YES;
    if (self.didDisplayed) {
        self.didDisplayed(self);
    }
    [self didShowAnimation];
}

- (void)showInLowWindowLevel
{
    [self initWindowWithLevel:UIWindowLevelNormal];
    [self show:.2f animations:nil completed:nil];
}

- (void)showHightLevel
{
    [self initWindowWithLevel:UIWindowLevelStatusBar + 1];
    [self show:.2f animations:nil completed:nil];
}

- (void)initWindowWithLevel:(CGFloat)level
{
    self.view.userInteractionEnabled = NO;
    self.previousWindow = [UIApplication sharedApplication].keyWindow;
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = level;
    window.rootViewController = self;
    window.backgroundColor = [UIColor clearColor];
    window.alpha = 0.f;
    [window makeKeyAndVisible];
    self.window = window;
}

- (void)didShowAnimation{
    // 子类实现
}

- (void)dismiss
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.window.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.window resignKeyWindow];
        [self.previousWindow makeKeyAndVisible];
        self.window = nil;
        
        if (self.didDismissed) {
            self.didDismissed(self);
        }
    }];
}

- (void)dismiss:(void (^)(void))completion
{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.15f animations:^{
        self.window.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.window resignKeyWindow];
        [self.previousWindow makeKeyAndVisible];
        self.window = nil;
        
        if (self.didDismissed) {
            self.didDismissed(self);
        }
        if (completion) {
            completion();
        }
    }];
}

@end
