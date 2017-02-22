

#import "YGLoginNoneCaptchaView.h"
#import "YGCapabilityHelper.h"
#import "OpenUDID.h"
#import "YGLoginViewCtrl.h"
#import "JCAlertView.h"
#import "WXApi.h"
#import <PINCache/PINCache.h>

@interface YGLoginNoneCaptchaView()<ServiceManagerDelegate>{
    NSInteger _wXTryToLogin;
}
@property(strong) UserSessionModel *session;
@end

@implementation YGLoginNoneCaptchaView

+ (YGLoginNoneCaptchaView *)show{
    YGLoginNoneCaptchaView *v = [[NSBundle mainBundle] loadNibNamed:@"YGLoginNoneCaptchaView" owner:nil options:nil].firstObject;
    ygweakify(v);
    v.blockClose = ^(id data){
        ygstrongify(v);
        JCAlertView *alert = (JCAlertView *)v.superview;
        if ([alert isKindOfClass:[JCAlertView class]]) {
            [alert dismissWithCompletion:nil];
            [SVProgressHUD dismiss];
        }
    };
    JCAlertView *alert = [[JCAlertView alloc] initWithCustomView:v dismissWhenTouchedBackground:YES];
    [alert show];
    return v;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    if (!([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])) {
        [self.viewWechat removeFromSuperview];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 102);
    }
    
}

- (void)setPhoneString:(NSString *)phoneString{
    _phoneString = phoneString;
    self.labelPhone.text = [NSString stringWithFormat:@"你将收到来自%@的电话，请留意接听。",phoneString];
}

- (IBAction)telphoneGetYZMClick:(id)sender {
    if (self.blockPhoneString) {
        self.blockPhoneString(nil);
    }
}
- (IBAction)wechaLoginClick:(id)sender {
    if (self.blockWechatLogin) {
        self.blockWechatLogin(nil);
    }
}

- (void)login:(LoginParamsModel*)model{
    ygweakify(self);
    [LoginService publicLogin:model needLoading:YES success:^(UserSessionModel *session) {
        ygstrongify(self);
        if(session && ![session.sessionId isEqualToString:@""]){
            [LoginManager sharedManager].session = session;
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
            if (dic) {
                NSString *openId = dic[@"openid"];
                NSString *unionId = dic[@"unionid"];
                NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,
                                       unionId,[apendStr md5String]];
                
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
            }
            [self performSelectorOnMainThread:@selector(finishThread:) withObject:session waitUntilDone:YES];
        }
        
    } failure:^(id error) {
        [SVProgressHUD show];
        if (_wXTryToLogin == 1) { // 尝试登录不成功时
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wechat_user_info"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGroupData];
            //构造SendAuthReq结构体
            SendAuthReq* req = [[SendAuthReq alloc ] init];
            req.scope = @"snsapi_userinfo" ;
            req.state = @"123" ;
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req];
        }else if (_wXTryToLogin == 2){
            ygstrongify(self);
            [SVProgressHUD dismiss];
            if (_wXTryToLogin == 1) { // 尝试登录不成功时
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wechat_user_info"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGroupData];
                //构造SendAuthReq结构体
                SendAuthReq* req = [[SendAuthReq alloc ] init];
                req.scope = @"snsapi_userinfo" ;
                req.state = @"123" ;
                //第三方向微信终端发送一个SendAuthReq消息结构
                [WXApi sendReq:req];
            }else if (_wXTryToLogin == 2){
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
                if (dic) {
                    NSString *openId = dic[@"openid"];
                    NSString *unionId = dic[@"unionid"];
                    NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                    NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,
                                           unionId,[apendStr md5String]];
                    [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSString *osName = [[UIDevice currentDevice] systemName];
                    NSString *deviceName = [[UIDevice currentDevice] name];
                    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
                    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    int gender;
                    if ([dic[@"sex"] intValue]== 1) {
                        gender = 1;
                    }else if ([dic[@"sex"] intValue] == 2){
                        gender = 0;
                    }else{
                        gender = 2;
                    }
                    ygweakify(self);
                    [LoginService userRegist:@"" withPassword:@"" withLongitude:[LoginManager sharedManager].currLongitude withLatitude:[LoginManager sharedManager].currLatitude withValidateCode:@"" withDeviceToken:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] withOsName:osName withDeviceName:deviceName withOsVersion:[osVersion stringByAppendingFormat:@",%@",appVersion] withActivationCode:@"" withGroupData:groupData withCountryCode:@"" success:^(UserSessionModel *userSession) {
                        
                        [[ServiceManager serviceManagerInstance] userBound:@"wechatApp" groupData:groupData sessionId:userSession.sessionId phoneNum:nil validateCode:nil isMobile:1 nickName:dic[@"nickname"] gender:gender headImageUrl:dic[@"headimgurl"] callBack:^(id obj) {
                            ygstrongify(self);
                            if (obj) {
                                NSString *backNickName = obj[@"nick_name"];
                                NSString *backHeadImg = obj[@"head_image"];
                                int gender = [obj[@"gender"] intValue];
                                [LoginManager sharedManager].session.nickName = backNickName;
                                [LoginManager sharedManager].session.headImage = backHeadImg;
                                [LoginManager sharedManager].session.gender = gender;
                                if ([self.viewController.navigationController.topViewController isKindOfClass:[YGLoginViewCtrl class]]) {
                                    YGLoginViewCtrl *loginVC = (YGLoginViewCtrl *)self.viewController.navigationController.topViewController;
                                    [self.viewController.navigationController dismissViewControllerAnimated:YES completion:^{
                                        [SVProgressHUD dismiss];
                                        if (loginVC.blockLonginReturn) {
                                            loginVC.blockLonginReturn(nil);
                                        }
                                    }];
                                }
                            }
                        }];
                    } failure:^(id error) {
                        [SVProgressHUD dismiss];
                    }];
                }
            }
        }
    }];
}

- (void)finishThread:(id)sender{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage]
                                                    options:SDWebImageLowPriority
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (image != nil) {
                                                          [LoginManager sharedManager].session.imageHead = image;
                                                      }
                                                  }];
    
    [LoginManager sharedManager].loginState = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.mobilePhone forKey:KGolfSessionPhone];
    
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].session.memberId)  forKey:@"GolfUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFootprintList" object:@"refresh"];
    
    if (_wXTryToLogin == 2) {
        if ([LoginManager sharedManager].session.nickName.length==0
            || [LoginManager sharedManager].session.headImage.length==0) {
            [self userBind];
        }
    }
    
    if (![LoginManager sharedManager].isloadedUserRemarks) {
        _wXTryToLogin = 0;
        [[ServiceManager serviceManagerWithDelegate:self] userFollowRemark:[[LoginManager sharedManager] getSessionId]];
    }
    
    if ([self.viewController.navigationController.topViewController isKindOfClass:[YGLoginViewCtrl class]]) {
        [self.viewController.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)userBind{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
    if (dic) {
        NSString *openId = dic[@"openid"];
        NSString *unionId = dic[@"unionid"];
        NSString *nickName = dic[@"nickname"];
        int gender = [dic[@"sex"] intValue];
        if (gender == 2) {
            gender = 0;
        }else if (gender == 1){
            gender = 1;
        }else{
            gender = 2;
        }
        NSString *headImageUrl = dic[@"headimgurl"];
        NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
        NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
        if (nickName.length>0 || headImageUrl.length>0) {
            [[ServiceManager serviceManagerInstance] userBound:@"wechatApp" groupData:groupData sessionId:[LoginManager sharedManager].session.sessionId phoneNum:[LoginManager sharedManager].session.mobilePhone validateCode:nil isMobile:1 nickName:nickName gender:gender headImageUrl:headImageUrl callBack:^(id obj) {
                if (obj) {
                    NSString *backNickName = obj[@"nick_name"];
                    NSString *backHeadImg = obj[@"head_image"];
                    int gender = [obj[@"gender"] intValue];
                    [LoginManager sharedManager].session.nickName = backNickName;
                    [LoginManager sharedManager].session.headImage = backHeadImg;
                    [LoginManager sharedManager].session.gender = gender;
                }
            }];
        }
    }
}

- (IBAction)closeClick:(id)sender {
    if (self.blockClose) {
        self.blockClose(nil);
    }
}

@end
