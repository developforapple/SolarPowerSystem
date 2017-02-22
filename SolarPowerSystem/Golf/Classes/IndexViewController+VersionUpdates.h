//
//  IndexViewController+VersionUpdates.h
//  Golf
//
//  Created by liangqing on 16/9/6.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "IndexViewController.h"
#import <StoreKit/StoreKit.h>
@interface IndexViewController (VersionUpdates)<SKStoreProductViewControllerDelegate>
//@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
- (void)getLastVersion;

/**
 打开定位
 */
- (void)openPosition;
@end
