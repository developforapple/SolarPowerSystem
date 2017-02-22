//
//  IndexViewController+AppEvaluate.m
//  Golf
//
//  Created by liangqing on 16/9/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "IndexViewController+AppEvaluate.h"
#import "APPGradeView.h"
@interface IndexViewController ()
@property (nonatomic,assign) BOOL isSecondIntoHomeViewCtr;
@end
@implementation IndexViewController (AppEvaluate)

static char *isSecondIntoHomeView = "isSecondIntoHomeViewCtr";
- (BOOL)isSecondIntoHomeViewCtr{
    NSNumber *hidden = objc_getAssociatedObject(self, isSecondIntoHomeView);
    return hidden.boolValue;
}

- (void)setIsSecondIntoHomeViewCtr:(BOOL)isSecondIntoHomeViewCtr{
    objc_setAssociatedObject(self, isSecondIntoHomeView, @(isSecondIntoHomeViewCtr), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillMethod{

    if ([GolfAppDelegate shareAppDelegate].systemParamInfo.isGuideAlert == 1) {
        if (self.isSecondIntoHomeViewCtr) {
            //弹评价窗口
            UIView *bgV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height)];
            bgV.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.35];
            [[GolfAppDelegate shareAppDelegate].window addSubview:bgV];
            
            APPGradeView *gradeV = [APPGradeView loadAPPGradeViewFromNib];
            CGFloat width = 0.0;
            if (IS_4_7_INCH_SCREEN || IS_5_5_INCH_SCREEN) {
                width = 375 * 0.72;
            }else{
                width = Device_Width * 0.72;
            }
            CGFloat heiht = width * 175 / 138;
            gradeV.frame = CGRectMake(0, 0, width, heiht);
            gradeV.center = bgV.center;
            gradeV.buttonRefuseWidthConst.constant = width * 0.85;
            gradeV.buttonEaluateWidthConst.constant = width * 0.85;
            [bgV addSubview:gradeV];
            ygweakify(bgV);
            gradeV.blockCancel = ^(id data){
                ygstrongify(bgV);
                [bgV removeFromSuperview];
            };
            
            ygweakify(self);
            gradeV.blockEvaluate = ^(id data){
                ygstrongify(self);
                ygstrongify(bgV);
                [bgV removeFromSuperview];
                [self evaluate];
            };
            [[API shareInstance] guideAlertSuccess:nil failure:nil];

            [GolfAppDelegate shareAppDelegate].systemParamInfo.isGuideAlert = 0;
        }
    }
    self.isSecondIntoHomeViewCtr = NO;
}

- (void)viewDisappearMethod{
    self.isSecondIntoHomeViewCtr = YES;
}

- (void)evaluate{
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

@end
