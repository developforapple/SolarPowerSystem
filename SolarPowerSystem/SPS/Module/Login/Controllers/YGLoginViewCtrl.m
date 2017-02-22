

#import "YGLoginViewCtrl.h"
#import "YGRegisterViewCtrl.h"
#import "YGForgotPasswordViewCtrl.h"
#import "OpenUDID.h"
#import "RegexKitLite.h"
#import "YGProfileViewCtrl.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YGLoginSMSViewCtrl.h"
#import "WXApi.h"
#import <PINCache/PINCache.h>

@interface YGLoginViewCtrl ()<UITextFieldDelegate>{
    NSInteger _wXTryToLogin;
}
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (nonatomic,assign) NSUInteger maxPhone;
@property (nonatomic,copy) NSString *phoneString;
@property (weak, nonatomic) IBOutlet UIView *phoneLineView;
@property (weak, nonatomic) IBOutlet UIView *passwordLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherLoginTopSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherLoginBottomSpacingConstraint;

@property (weak, nonatomic) IBOutlet UIView *wechatAndSMSPanel;
@property (weak, nonatomic) IBOutlet UIView *onlySMSPanel;

@end

@implementation YGLoginViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenCode:) name:@"AccessTokenCode" object:nil];
    
    [self initNotificationSignal];
    [self initTextFieldSignal];
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)initUI
{
    BOOL isSmallScreen = IS_4_0_INCH_SCREEN || IS_3_5_INCH_SCREEN;
    self.otherLoginTopSpacingConstraint.constant = isSmallScreen?36.f:46.f;
    self.otherLoginBottomSpacingConstraint.constant = isSmallScreen?20.f:30.f;
    
    BOOL wechatAvailable = [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
    self.wechatAndSMSPanel.hidden = !wechatAvailable;
    self.onlySMSPanel.hidden = wechatAvailable;
}

- (void)initTextFieldSignal
{
    
}

- (void)initNotificationSignal
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    ygweakify(self);
    [[center rac_addObserverForName:@"WeChatLoginSuccess" object:nil]
     subscribeNext:^(NSNotification *notification) {
        ygstrongify(self);
        if (self.blockLonginReturn) {
            self.blockLonginReturn(nil);
        }
    }];
    [[center rac_addObserverForName:@"CouldNotMakeHTTPRequest" object:nil]
     subscribeNext:^(NSNotification *notification) {
         [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
     }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.tfPhone.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    self.tfPassword.text = [GolfAppDelegate shareAppDelegate].autoLogIn?[[NSUserDefaults standardUserDefaults] stringForKey:KGolfUserPassword]:nil;
    self.btnLogin.enabled = self.tfPhone.text.length>0 && self.tfPassword.text.length>0;

    if ([LoginManager sharedManager].loginState) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (_blockLonginReturn) {//lyf 加 不然注册之后不跳到相应的页面
                _blockLonginReturn(nil);
            }
        }];
        if([self.delegate respondsToSelector:@selector(loginButtonPressed:)]){
            [self.delegate loginButtonPressed:nil];
        }
    }
}

- (IBAction)forgetPasswordAction:(id)sender{
    [self.view endEditing:YES];
    
    YGForgotPasswordViewCtrl *forget = [YGForgotPasswordViewCtrl instanceFromStoryboard];
    forget.title = @"忘记密码";
    forget.phoneStr = _tfPhone.text;
    forget.sendPhone = _phoneString;
    [self.navigationController pushViewController:forget animated:YES];
}

- (IBAction)loginAction:(id)sender{
    self.phoneString = _tfPhone.text;
    NSString *msg = nil;
    if (_tfPhone.text.length <= 0 && _tfPassword.text.length <= 0) {
        msg = @"请输入手机号码";
    }
    else if (_tfPhone.text.length > 0 && _tfPassword.text.length <= 0){
        msg = @"请输入登录密码";
    }
    else{
        [_tfPassword resignFirstResponder];
        [_tfPhone resignFirstResponder];
        
        NSString *osName = [[UIDevice currentDevice] systemName];
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        LoginParamsModel *model = [[LoginParamsModel alloc] init];
        model.phoneNum = _phoneString;
        model.password = _tfPassword.text;
        model.deviceName = [[UIDevice currentDevice] name];
        model.osName = osName;
        model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
        model.imeiNum = [OpenUDID value];
        model.latitude = [LoginManager sharedManager].currLatitude;
        model.longitude = [LoginManager sharedManager].currLongitude;
        model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
        [self login:model];
    }
    if (msg) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:msg];
    }
}

- (void)login:(LoginParamsModel*)model{
    ygweakify(self);
    [LoginService publicLogin:model needLoading:YES success:^(UserSessionModel *session) {
        ygstrongify(self);
        [SVProgressHUD dismiss];
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
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [self performSelectorOnMainThread:@selector(finishThread:) withObject:session waitUntilDone:YES];
        }else{
            _tfPassword.text = @"";
        }
        
    } failure:^(id error) {
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
                            [self dismissViewControllerAnimated:YES completion:^{
                                [SVProgressHUD dismiss];
                                if (_blockLonginReturn) {
                                    _blockLonginReturn(nil);
                                }
                            }];
                        }
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
                    }];
                } failure:^(id error) {
                    [SVProgressHUD dismiss];
                    //                      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
                }];
            }
        }
    }];
}

/**
 手机短信登录点击
 
 @param sender
 */
- (IBAction)SMSLoginClick:(id)sender {
    YGLoginSMSViewCtrl *SMSLoginVC = [YGLoginSMSViewCtrl instanceFromStoryboard];
    [self.navigationController pushViewController:SMSLoginVC animated:YES];
}

- (IBAction)wxLoginAction{
    if (![WXApi isWXAppInstalled]){
        [SVProgressHUD showInfoWithStatus:@"您未安装微信"];
        return;
    }else if (![WXApi isWXAppSupportApi]){
        [SVProgressHUD showInfoWithStatus:@"您的微信无法登录APP"];
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *groupData = [userDefault objectForKey:KGroupData];
    if (groupData && groupData.length > 0) {
        _wXTryToLogin = 1;
        
        NSString *osName = [[UIDevice currentDevice] systemName];
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        LoginParamsModel *model = [[LoginParamsModel alloc] init];
        model.phoneNum = [userDefault objectForKey:KGolfSessionPhone];
        model.password = @"";
        model.deviceName = [[UIDevice currentDevice] name];
        model.osName = osName;
        model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
        model.imeiNum = [OpenUDID value];
        model.latitude = [LoginManager sharedManager].currLatitude;
        model.longitude = [LoginManager sharedManager].currLongitude;
        model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
        model.groupFlag = @"wechatApp";
        model.groupData = groupData;
        
        [self login:model];
        
    }else{
        //构造SendAuthReq结构体
        SendAuthReq* req = [[SendAuthReq alloc ] init];
        req.scope = @"snsapi_userinfo" ;
        req.state = @"123" ;
        //第三方向微信终端发送一个SendAuthReq消息结构
        [WXApi sendReq:req];
    }
}

- (void)accessTokenCode:(NSNotification*)notification{
    _wXTryToLogin = 2;
    id obj = notification.object;
    [SVProgressHUD show];
    [[ServiceManager serviceManagerInstance] wechatUserInfo:@"wechatApp" code:obj callBack:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        if (dic){
            NSString *openId = dic[@"openid"];
            NSString *unionId = dic[@"unionid"];
            NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
            NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"wechat_user_info"];
            
            NSString *osName = [[UIDevice currentDevice] systemName];
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            LoginParamsModel *model = [[LoginParamsModel alloc] init];
            model.phoneNum = @"";
            model.password = @"";
            model.deviceName = [[UIDevice currentDevice] name];
            model.osName = osName;
            model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
            model.imeiNum = [OpenUDID value];
            model.latitude = [LoginManager sharedManager].currLatitude;
            model.longitude = [LoginManager sharedManager].currLongitude;
            model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
            model.groupFlag = @"wechatApp";
            model.groupData = groupData;
            
            [self login:model];
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
    
    if (_tfPassword.text.length>0) {
        [LoginManager sharedManager].userPassWord = _tfPassword.text;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.mobilePhone forKey:KGolfSessionPhone];
    if (_tfPassword.text.length>0) {
        [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:KGolfUserPassword];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].session.memberId)  forKey:@"GolfUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFootprintList" object:@"refresh"];
    
    if (_wXTryToLogin == 2) {
        if ([LoginManager sharedManager].session.nickName.length==0 || [LoginManager sharedManager].session.headImage.length==0) {
            [self userBind];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(loginButtonPressed:)]){
        [self.delegate loginButtonPressed:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(loginFinishHandle)]) {
        [self.delegate loginFinishHandle];
    }
    
    if (![LoginManager sharedManager].isloadedUserRemarks) {
        _wXTryToLogin = 0;
        [[ServiceManager serviceManagerWithDelegate:self] userFollowRemark:[[LoginManager sharedManager] getSessionId]];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (_blockLonginReturn) {
            _blockLonginReturn(nil);
        }
    }];
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

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([_tfPhone isEqual:textField])
    {
        self.maxPhone = 11;
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + string.length - range.length;
        if ([string isEqualToString:@""]) {
            return YES;
        }
        return newLength <= _maxPhone;
    }else{
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        NSUInteger newLength = [textField.text length] + string.length - range.length;
        return newLength <= 16 ? YES : NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _tfPhone) {
        [self.tfPassword becomeFirstResponder];
    }
    if (textField == _tfPassword) {
        [self loginAction:nil];
    }
    return YES;
}

- (void)textFieldChange{
    
    if (_tfPassword.text.length < 6 || _tfPhone.text.length == 0) {
        self.btnLogin.enabled = NO;
    }else{
        self.btnLogin.enabled = YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = MainHighlightColor;
    }
    if (textField == _tfPassword) {
        self.passwordLineView.backgroundColor = MainHighlightColor;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tfPassword) {
        self.passwordLineView.backgroundColor = MainGrayLineColor;
    }
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = MainGrayLineColor;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.btnLogin.enabled = NO;
    return YES;
}

- (IBAction)toRegisterViewController:(id)sender
{
    [self.view endEditing:YES];
    
    YGRegisterViewCtrl *vc = [YGRegisterViewCtrl instanceFromStoryboard];
    ygweakify(self);
    vc.blockReturnLogin = ^(id data){
        ygstrongify(self);
        if (self.blockLonginReturn) {
            self.blockLonginReturn(nil);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)doLeftNavAction
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_cancelReturn) {
        _cancelReturn(nil);
    }
    
    NSInteger tabbarIndex = [GolfAppDelegate shareAppDelegate].tabBarController.selectedIndex;
    if (tabbarIndex>1) {
        UINavigationController *nc = [GolfAppDelegate shareAppDelegate].tabBarController.selectedViewController;
        [nc popToRootViewControllerAnimated:YES];
        [GolfAppDelegate shareAppDelegate].tabBarController.selectedIndex = 0;
    }else{
        BaseNavController *vc = [[GolfAppDelegate shareAppDelegate].naviController.viewControllers lastObject];
        if ([vc isKindOfClass:[YGProfileViewCtrl class]]) {
            [[GolfAppDelegate shareAppDelegate].naviController popViewControllerAnimated:NO];
        }
    }
    [GolfAppDelegate shareAppDelegate].loginViewShowed = NO;
}

@end
