//
//  YGBaseNavigationController.m
//  Golf
//
//  Created by bo wang on 2017/2/21.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "YGBaseNavigationController.h"

@interface YGBaseNavigationController ()

@end

@implementation YGBaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
