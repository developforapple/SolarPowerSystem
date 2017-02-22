//
//  IndexViewController+AppEvaluate.h
//  Golf
//
//  Created by liangqing on 16/9/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "IndexViewController.h"
#import <StoreKit/StoreKit.h>
@interface IndexViewController (AppEvaluate)<SKStoreProductViewControllerDelegate>
- (void)viewWillMethod;
- (void)viewDisappearMethod;
@end
