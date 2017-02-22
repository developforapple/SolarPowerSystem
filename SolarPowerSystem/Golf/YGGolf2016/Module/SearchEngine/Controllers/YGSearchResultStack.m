//
//  YGSearchResultStack.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchResultStack.h"
#import "YGSearchResultViewCtrl.h"
#import "_JZ-objc-internal.h"

@interface YGSearchResultStack ()

@end

@implementation YGSearchResultStack

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topResultViewCtrlVisible = NO;
    
    ygweakify(self);
    [self jz_setInteractivePopGestureRecognizerCompletion:^(UINavigationController *navi, BOOL finished) {
        ygstrongify(self);
        if (self.interactiveCompleted) {
            self.interactiveCompleted(finished);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.jz_fullScreenInteractivePopGestureRecognizer addTarget:self action:@selector(interactiveAction:)];
}

- (YGSearchType)topSearchType
{
    return [self topSearchViewCtrl].type;
}

- (YGSearchResultViewCtrl *)topSearchViewCtrl
{
    __kindof UIViewController *vc = self.topViewController;
    if ([vc isKindOfClass:[YGSearchResultViewCtrl class]]) {
        return vc;
    }
    return nil;
}

- (NSUInteger)stackCount
{
    return self.viewControllers.count;
}

- (YGSearchResultViewCtrl *)rootResultViewCtrl
{
    return [self.viewControllers firstObject];
}

- (BOOL)topResultViewCtrlVisible
{
    return ![self topViewController].view.hidden;
}

- (void)setTopResultViewCtrlVisible:(BOOL)topResultViewCtrlVisible
{
    [self topSearchViewCtrl].view.hidden = !topResultViewCtrlVisible;
}

- (void)interactiveAction:(UIPanGestureRecognizer *)pan
{
    // 使用手势返回时 取消编辑状态
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.view.window endEditing:YES];
    }
}

#pragma mark - Stack
- (void)pop
{
    [self popViewControllerAnimated:YES];
}

- (void)push:(YGSearchResultViewCtrl *)result
{
    if (!result) return;
    
    if (self.viewControllers == 0) {
        [self pushViewController:result animated:NO];
    }else{
        [self pushViewController:result animated:YES];
    }
}
@end
