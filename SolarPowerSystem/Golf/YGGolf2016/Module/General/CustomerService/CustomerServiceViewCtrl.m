//
//  CustomerServiceViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/8/3.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "CustomerServiceViewCtrl.h"
#import "WKDChatViewController.h"
#import "YGCapabilityHelper.h"

@interface CustomerServiceViewCtrl ()

@property (weak, nonatomic) IBOutlet UILabel *servicePhoneLabel;

@property (strong, nonatomic) UIWindow *curWindow;
@property (weak, nonatomic) UIWindow *previousWindow;

@end

@implementation CustomerServiceViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.servicePhoneLabel.text = [NSString stringWithFormat:@"拨打%@",[Utilities getGolfServicePhone]];
}

+ (void)show
{
    [[CustomerServiceViewCtrl instanceFromStoryboard] show];
}

- (void)show
{
    self.previousWindow = [UIApplication sharedApplication].keyWindow;
    
    self.curWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.curWindow.windowLevel = UIWindowLevelStatusBar+1;
    self.curWindow.rootViewController = self;
    
    self.curWindow.alpha = 0.f;
    [self.curWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:.2f animations:^{
        self.curWindow.alpha = 1.f;
    }];
}

- (void)hidden
{
    [UIView animateWithDuration:.2f animations:^{
        self.curWindow.alpha = 0.f;
    } completion:^(BOOL finished) {
        
        [self.curWindow resignKeyWindow];
        [self.previousWindow makeKeyAndVisible];
        
        self.curWindow = nil;
    }];
}

#pragma mark - Actions
- (void)toChatByServiceInfo:(NSDictionary *)nd{
    if (nd) {
        int memberId = [nd[@"memberid"] intValue];
        NSString *name = nd[@"display_name"];
        NSString *headImage =  nd[@"head_image"];
        NSString *sayhi = nd[@"sayhi"];
        UIImage *targetImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headImage]]];
        
        WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.targetImage = targetImage;
        chatVC.title = name;
        chatVC.memId = memberId;
        chatVC.serviceMessage = sayhi;
        [[GolfAppDelegate shareAppDelegate].naviController pushViewController:chatVC animated:YES];
    }
}

- (void)toChatWithLoginWtihServiceInfoKeypath:(NSString *)keypath{
    [self hidden];
    NSDictionary *nd = [[GolfAppDelegate shareAppDelegate].systemParamInfo valueForKeyPath:keypath];
    
    if (![LoginManager sharedManager].loginState) {
        [LoginManager sharedManager].loginState = NO;
        
        id<YGLoginViewCtrlDelegate> delegate = (id<YGLoginViewCtrlDelegate>)[GolfAppDelegate shareAppDelegate].currentController;
        [[LoginManager sharedManager] loginWithDelegate:delegate controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
            if (nd) {
                [self toChatByServiceInfo:nd];
            }else{
                [SVProgressHUD show];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    [ServerService systemParamInfoByGolfSessionPhone:[[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone] success:^(SystemParamInfo *data) {
                        [GolfAppDelegate shareAppDelegate].systemParamInfo = data;
                        [self toChatByServiceInfo:[data valueForKeyPath:keypath]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                        });
                    } failure:^(id error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                        });
                    }];
                });
                
            }
        }];
        return;
    }else{
        if (nd) {
            [self toChatByServiceInfo:nd];
        }
    }
}

- (IBAction)booking:(id)sender {
    [self toChatWithLoginWtihServiceInfoKeypath:@"kefuTeetime"];
}

- (IBAction)commondity:(id)sender{
    [self toChatWithLoginWtihServiceInfoKeypath:@"kefuCommodity"];
}

- (IBAction)teaching:(id)sender{
    [self toChatWithLoginWtihServiceInfoKeypath:@"kefuTeaching"];
}

- (IBAction)other:(id)sender{
    [self toChatWithLoginWtihServiceInfoKeypath:@"kefuOther"];
}

- (IBAction)feedback:(id)sender{
    [self toChatWithLoginWtihServiceInfoKeypath:@"kefuFeedback"];
}

- (IBAction)phoneCall:(id)sender
{
    [self hidden];
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:NO];
}

- (IBAction)close:(id)sender
{
    [self hidden];
}


@end
