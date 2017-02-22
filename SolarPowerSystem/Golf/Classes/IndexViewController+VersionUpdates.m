//
//  IndexViewController+VersionUpdates.m
//  Golf
//
//  Created by liangqing on 16/9/6.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "IndexViewController+VersionUpdates.h"
#import "CCAlertView.h"
#import "GetLastVersionModel.h"
#import <CoreLocation/CoreLocation.h>

@implementation IndexViewController (VersionUpdates)

- (void)versionUpdataWithVersion:(CGFloat)version title:(NSString *)title message:(NSString *)message{
    float currVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    if (currVersion < version) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:IDENTIFIER(@"isFirstGetLastVersion")];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        ygweakify(self);
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"立即去更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ygstrongify(self);
            [self evaluate_update];
        }];
        [alert addAction:cancelAction];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)evaluate_update{
    [SVProgressHUD show];
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : kGolfAppStoreIdStr} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         [SVProgressHUD dismiss];
         if(error){
             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
         }else{
             //模态弹出appstore
             [self presentViewController:storeProductViewContorller animated:YES completion:^{
             }];
         }
     }];
}

- (void)getLastVersion{
    ygweakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ServerService getLastVersionSuccess:^(GetLastVersionModel *obj) {
            ygstrongify(self);
            [self versionUpdataWithVersion:obj.versionNumber title:obj.versionName message:obj.versionDesc];
        } failure:^(id error) {
            
        }];
    });
}

- (void)openPosition{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"定位服务"
                                                                       message:@"定位服务不可用，请在设置中开启定位服务."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
 }
@end
