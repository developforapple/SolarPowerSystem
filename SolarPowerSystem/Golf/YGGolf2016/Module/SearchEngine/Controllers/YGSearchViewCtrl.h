//
//  YGSearchViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"
#import "YGSearch.h"

@interface YGSearchViewCtrl : YGBaseViewController

- (void)displayFromViewController:(UINavigationController *)viewController;
- (void)displayFromViewController:(UINavigationController *)viewController keywords:(NSString *)keywords;
- (void)displayFromViewController:(UINavigationController *)viewController type:(YGSearchType )type;
- (void)displayFromViewController:(UINavigationController *)viewController keywords:(NSString *)keywords type:(YGSearchType)type;

- (void)dismiss;
@end
