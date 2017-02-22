

#import "YGLoginSMSNextViewCtrl.h"

#import "YGLoginNoneCaptchaView.h"
#import "OpenUDID.h"
#import "YGWeChatLoginLogic.h"
#import <PINCache/PINCache.h>

@interface YGLoginSMSNextViewCtrl ()<UITextFieldDelegate>{
    int _count;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *labelSender;
@property (weak, nonatomic) IBOutlet UITextField *tfYZM;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonSendAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonNOReceive;
@property (weak, nonatomic) IBOutlet UIView *invteLineView;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) YGWeChatLoginLogic *wechatLoginSer;
@end

@implementation YGLoginSMSNextViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.tableHeaderView.height = Device_Height - 20;
    self.labelSender.text = [NSString stringWithFormat:@"验证码已发送至 %@ %@",_areaCodeStr,_phoneString];
    self.buttonLogin.backgroundColor = [UIColor whiteColor];
    [self.buttonLogin setBackgroundImage:[UIImage imageWithColor:MainHighlightColor] forState:0];
    [self.buttonLogin setBackgroundImage:[UIImage imageWithColor:MainDarkHighlightColor] forState:UIControlStateHighlighted];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    _count = 60;
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    
    [ServerService publicValidateCode:_getYZMPhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {
        
    } failure:^(id error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark 定时器
- (void)timerFired:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        self.buttonSendAgain.enabled = NO;
        [self.buttonSendAgain setTitle:[NSString stringWithFormat:@"重新获取 %d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonSendAgain.enabled = YES;
        [self.buttonSendAgain setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
        [self.buttonSendAgain setTitle:@"  重新获取  " forState:UIControlStateNormal];
        [self.buttonSendAgain.layer setCornerRadius:14];
        self.buttonSendAgain.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        self.buttonSendAgain.layer.borderWidth = 0.5;
    }
}
#pragma mark 按钮点击
#pragma mark --重新发送点击
- (IBAction)sendeAgainClick:(UIButton *)sender {
    sender.enabled = NO;
    sender.layer.cornerRadius = 0;
    sender.layer.borderWidth = 0;
    [sender setTitle:@"60秒" forState:UIControlStateDisabled];
    [sender setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFiredAgain:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    _count = 60;
    [ServerService publicValidateCode:_getYZMPhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {
        
    } failure:^(id error) {
        
    }];
}

- (void)timerFiredAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonSendAgain setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonSendAgain.hidden = YES;
        self.buttonNOReceive.hidden = NO;
    }
}
#pragma mark --收不到验证码点击
- (IBAction)noReceiveClick:(UIButton *)sender {
    
    [self.tfYZM resignFirstResponder];
    
    YGLoginNoneCaptchaView *tg = [YGLoginNoneCaptchaView show];
    ygweakify(tg);
    ygweakify(self);
    tg.blockPhoneString = ^(id data){
        [SVProgressHUD show];
        ygstrongify(tg)
        if (tg.blockClose) {
            tg.blockClose(nil);
        }
        [ServerService publicValidateCode:_getYZMPhoneStr groupFlag:nil noMsg:0 codeType:1 success:^(id obj) {
            [SVProgressHUD dismiss];
            ygstrongify(self);
            BaseService *ser = (BaseService *)obj;
            NSDictionary *dict = (NSDictionary *)ser.data;
            if (dict[@"service_phone"]) {
                self.labelSender.text = [NSString stringWithFormat:@"你将收到来自 %@ 的电话",dict[@"service_phone"]];
            }
            RunOnMainQueue(^{
                sender.enabled = NO;
                sender.layer.cornerRadius = 0;
                sender.layer.borderWidth = 0;
                [sender setTitle:@"60秒" forState:UIControlStateDisabled];
                [sender setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerVoicedAgain:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
                _count = 60;
            });
        } failure:^(id error) {
            [SVProgressHUD showInfoWithStatus:@"获取语音验证码失败！"];
        }];
    };
    
    tg.blockWechatLogin = ^(id data){
        ygstrongify(self);
        YGWeChatLoginLogic *wechatLoginSer = [[YGWeChatLoginLogic alloc] init];
        [wechatLoginSer weChatLoginWithController:self];
        self.wechatLoginSer = wechatLoginSer;
    };
}

- (void)timerVoicedAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonNOReceive setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonSendAgain.hidden = YES;
        self.buttonNOReceive.hidden = NO;
        self.buttonNOReceive.enabled = YES;
        self.buttonNOReceive.layer.cornerRadius = 14;
        self.buttonNOReceive.layer.borderWidth = 0.5;
        self.buttonNOReceive.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        [self.buttonNOReceive setTitle:@"  收不到验证码? " forState:0];
        [self.buttonNOReceive setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
    }
}
#pragma mark --登陆点击
- (IBAction)loginClick:(id)sender {
    [self binding];
}

- (void)binding{
    [self.tfYZM resignFirstResponder];
    ygweakify(self);
    [LoginService checkPhoneNumber:_getYZMPhoneStr success:^(NSDictionary *dic) {
        if (dic) {
            if (![[dic objectForKey:@"flag"] boolValue]) {// 新用户
                NSString *osName = [[UIDevice currentDevice] systemName];
                NSString *deviceName = [[UIDevice currentDevice] name];
                NSString *osVersion = [[UIDevice currentDevice] systemVersion];
                NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                [LoginService userRegist:_getYZMPhoneStr withPassword:@"" withLongitude:[LoginManager sharedManager].currLongitude withLatitude:[LoginManager sharedManager].currLatitude withValidateCode:_tfYZM.text withDeviceToken:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] withOsName:osName withDeviceName:deviceName withOsVersion:[osVersion stringByAppendingFormat:@",%@",appVersion] withActivationCode:@"" withGroupData:@"" withCountryCode:@"" success:^(UserSessionModel *userSession) {
                    ygstrongify(self);
                    if (userSession) {
                        [LoginManager sharedManager].session = userSession;
                        
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage]
                                                                        options:SDWebImageLowPriority
                                                                       progress:nil
                                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                          if (image != nil) {
                                                                              [LoginManager sharedManager].session.imageHead = image;
                                                                          }
                                                                      }];
                        [LoginManager sharedManager].loginState = YES;
                        [LoginManager sharedManager].session.mobilePhone = self.phoneString;
                        [[NSUserDefaults standardUserDefaults] setObject:self.phoneString forKey:KGolfSessionPhone];
                        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
                        if (dic) {
                            NSString *openId = dic[@"openid"];
                            NSString *unionId = dic[@"unionid"];
                            NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                            NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                        }
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[API shareInstance] timSignAuthWithSuccess:^(AckBean *ab) {
                            NSString *password = ab.success.extraMap[@"auth"];
                            [[NSUserDefaults standardUserDefaults] setObject:password forKey:KGolfUserPassword];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        } failure:^(Error *error) {
                        }];
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            [[GolfAppDelegate shareAppDelegate].tabBarController setSelectedViewController:[GolfAppDelegate shareAppDelegate].tabBarController.viewControllers.lastObject];//lyf 注册之后要回到我的
                        }];
                    }
                } failure:^(id error) {
                    
                }];
            }else{
                NSString *osName = [[UIDevice currentDevice] systemName];
                NSString *osVersion = [[UIDevice currentDevice] systemVersion];
                NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                
                LoginParamsModel *model = [[LoginParamsModel alloc] init];
                model.phoneNum = _phoneString;
                model.password = @"";
                model.deviceName = [[UIDevice currentDevice] name];
                model.osName = osName;
                model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
                model.imeiNum = [OpenUDID value];
                model.latitude = [LoginManager sharedManager].currLatitude;
                model.longitude = [LoginManager sharedManager].currLongitude;
                model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
                model.activationCode = self.tfYZM.text;
                if ([self.areaCodeStr rangeOfString:@"86"].location != NSNotFound) {
                    model.contryCode = @"86";
                }
                if ([self.areaCodeStr rangeOfString:@"86"].location != NSNotFound) {
                    model.contryCode = @"86";
                }
                if ([self.areaCodeStr rangeOfString:@"852"].location != NSNotFound) {
                    model.contryCode = @"852";
                }
                if ([self.areaCodeStr rangeOfString:@"853"].location != NSNotFound) {
                    model.contryCode = @"853";
                }
                if ([self.areaCodeStr rangeOfString:@"886"].location != NSNotFound) {
                    model.contryCode = @"886";
                }
                if ([[self.areaCodeStr stringByReplacingOccurrencesOfString:@"+" withString:@""] rangeOfString:@"86"].location != NSNotFound) {
                    model.contryCode = [self.areaCodeStr stringByReplacingOccurrencesOfString:@"+" withString:@""];
                }
                ygweakify(self);
                [LoginService publicLogin:model needLoading:YES success:^(UserSessionModel *userSession) {
                    ygstrongify(self);
                    if(userSession && ![userSession.sessionId isEqualToString:@""]){
                        [LoginManager sharedManager].session = userSession;
                        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
                        if (dic) {
                            NSString *openId = dic[@"openid"];
                            NSString *unionId = dic[@"unionid"];
                            NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                            NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
                            [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [self performSelectorOnMainThread:@selector(finishThread:) withObject:userSession waitUntilDone:YES];
                    }
                } failure:^(id error) {
                    
                }];
            }
        }
    } failure:^(id error) {
        
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
    
    if (![LoginManager sharedManager].isloadedUserRemarks) {
        [[ServiceManager serviceManagerWithDelegate:self] userFollowRemark:[[LoginManager sharedManager] getSessionId]];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[GolfAppDelegate shareAppDelegate].tabBarController setSelectedViewController:[GolfAppDelegate shareAppDelegate].tabBarController.viewControllers.lastObject];//lyf 注册之后要回到我的
    }];
}

#pragma mark --返回点击
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger maxPhone = 4;
    NSUInteger newLength = [textField.text length] + string.length - range.length;
    if (newLength == maxPhone || newLength == maxPhone + 1) {
        self.buttonLogin.enabled = YES;
    }else{
        self.buttonLogin.enabled = NO;
    }
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    return newLength <= maxPhone;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.buttonLogin.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self binding];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tfYZM) {
        [self.invteLineView setBackgroundColor:MainHighlightColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tfYZM) {
        [self.invteLineView setBackgroundColor:MainGrayLineColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wechatLoginSer deallocNotification];
}

- (void)dealloc{
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end



