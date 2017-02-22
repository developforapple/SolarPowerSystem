

#import "YGBindingPhoneVerifyViewCtrl.h"
#import "YGLoginNoneCaptchaView.h"

@interface YGBindingPhoneVerifyViewCtrl ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *labelSender;
@property (weak, nonatomic) IBOutlet UITextField *tfYZM;
@property (weak, nonatomic) IBOutlet UILabel *labelCountdown;
@property (weak, nonatomic) IBOutlet UIButton *buttonSenderAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonNoReceive;
@property (weak, nonatomic) IBOutlet UIButton *buttonBinding;
@property (nonatomic,assign) int count;//倒计时
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation YGBindingPhoneVerifyViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.tableHeaderView.height = Device_Height - 20;
    self.labelCountdown.hidden = NO;
    self.buttonSenderAgain.hidden = YES;
    self.buttonNoReceive.hidden = YES;
    self.buttonBinding.backgroundColor = [UIColor whiteColor];
    [self.buttonBinding setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"249DF3"]] forState:0];
    [self.buttonBinding setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1d7cbf"]] forState:UIControlStateHighlighted];
    self.labelSender.text = [NSString stringWithFormat:@"验证码已发送至 %@ %@",_areaCodeStr,_phoneString];
    [self getYZM];
}

- (void)getYZM{
    self.count = 60;
    self.labelCountdown.text = @"重新获取 60秒";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    [ServerService publicValidateCode:_areaCodePhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {
        
    } failure:^(id error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)timerFired:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        self.buttonNoReceive.hidden = YES;
        self.buttonSenderAgain.hidden = YES;
        self.labelSender.hidden = NO;
        self.labelCountdown.text = [NSString stringWithFormat:@"重新获取 %d秒",_count];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.labelCountdown.hidden = YES;
        self.buttonSenderAgain.hidden = NO;
        self.buttonNoReceive.hidden = YES;
    }
}

#pragma mark 按钮点击
//重新发送点击
- (IBAction)sendAgainClick:(id)sender {
    self.buttonSenderAgain.hidden = YES;
    self.labelCountdown.hidden = NO;
    self.buttonNoReceive.hidden = YES;
    self.count = 60;
    self.labelCountdown.text = @"60秒";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFiredAgain:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    
    [ServerService publicValidateCode:_areaCodePhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {//获取验证码
        
    } failure:^(id error) {
        
    }];
}

- (void)timerFiredAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        self.labelCountdown.text = [NSString stringWithFormat:@"%d秒",_count];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.labelCountdown.hidden = YES;
        self.buttonSenderAgain.hidden = YES;
        self.buttonNoReceive.hidden = NO;
    }
}
#pragma mark --收不到验证码点击
- (IBAction)noReceiverClick:(UIButton *)sender {
    
    if (self.isExchangePhoneBinding) {
        [self.tfYZM resignFirstResponder];
        YGLoginNoneCaptchaView *tg = [YGLoginNoneCaptchaView show];
        ygweakify(self);
        ygweakify(tg);
        tg.blockPhoneString = ^(id data){
            [SVProgressHUD show];
            ygstrongify(tg);
            if (tg.blockClose) {
                tg.blockClose(nil);
            }
            [ServerService publicValidateCode:_areaCodePhoneStr groupFlag:nil noMsg:0 codeType:1 success:^(id obj) {
                [SVProgressHUD dismiss];
                BaseService *ser = (BaseService *)obj;
                if (ser.success) {
                    ygstrongify(self);
                    BaseService *ser = (BaseService *)obj;
                    NSDictionary *dict = (NSDictionary *)ser.data;
                    if (dict[@"service_phone"]) {
                        self.labelSender.text = [NSString stringWithFormat:@"你将收到来自 %@ 的电话",dict[@"service_phone"]];
                    }
                    
                    self.buttonSenderAgain.hidden = YES;
                    self.buttonNoReceive.hidden = YES;
                    self.labelCountdown.hidden = NO;
                    self.labelCountdown.text = @"60秒";
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getVoiceYZMAgain:) userInfo:nil repeats:YES];
                    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
                    _count = 60;
                }
                
            } failure:^(id error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showInfoWithStatus:@"获取语音验证码失败！"];
            }];
            
        };
    }else{
        [self.tfYZM resignFirstResponder];
        YGLoginNoneCaptchaView *tg = [YGLoginNoneCaptchaView show];
        ygweakify(self);
        ygweakify(tg);
        tg.blockPhoneString = ^(id data){
            [SVProgressHUD show];
            [ServerService publicValidateCode:_areaCodePhoneStr groupFlag:nil noMsg:0 codeType:1 success:^(id obj) {
                [SVProgressHUD dismiss];
                ygstrongify(self);
                BaseService *ser = (BaseService *)obj;
                NSDictionary *dict = (NSDictionary *)ser.data;
                if (dict[@"service_phone"]) {
                    self.labelSender.text = [NSString stringWithFormat:@"你将收到来自 %@ 的电话",dict[@"service_phone"]];
                }
                
            } failure:^(id error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showInfoWithStatus:@"获取语音验证码失败！"];
            }];
            ygstrongify(tg);
            if (tg.blockClose) {
                tg.blockClose(nil);
            }
            self.buttonSenderAgain.hidden = YES;
            self.buttonNoReceive.hidden = YES;
            self.labelCountdown.hidden = NO;
            self.labelCountdown.text = @"60秒";
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getVoiceYZMAgain:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
            _count = 60;
        };
    }
}

- (void)getVoiceYZMAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        self.labelCountdown.text = [NSString stringWithFormat:@"%d秒",_count];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.labelCountdown.hidden = YES;
        self.buttonSenderAgain.hidden = YES;
        self.buttonNoReceive.hidden = NO;
    }
}

#pragma mark --绑定点击
- (IBAction)bindingClick:(id)sender {
    if (self.isExchangePhoneBinding) {
        [self binding];   //换绑
    }else{
        [self bindingV2]; //新绑定
    }
}

- (void)binding{
    [SVProgressHUD show];
    ygweakify(self);
    [LoginService checkPhoneNumber:self.phoneString success:^(NSDictionary *dic) {
        ygstrongify(self);
        if (dic) {
            if (![[dic objectForKey:@"flag"] boolValue]) {// 新用户
                BindBean *bb = [[BindBean alloc] initWithMobile:_phoneString validateCode:_tfYZM.text countryCode:[self.areaCodeStr stringByReplacingOccurrencesOfString:@"+" withString:@""]];
                [[API shareInstance] bindeviceWithBindBean:bb Success:^(AckBean *data) {
                    ygstrongify(self);
                    if (data.err.errorMsg == nil) {
                        [SVProgressHUD showInfoWithStatus:@"换绑成功"];
                        [LoginManager sharedManager].session.mobilePhone = self.phoneString;//换绑成功的手机号替换原来的手机号
                        [[NSUserDefaults standardUserDefaults] setObject:self.phoneString forKey:KGolfSessionPhone];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBindingSuccess" object:nil];
                        
                        Class c = NSClassFromString(@"YGBindingListViewCtrl");
                        for (UIViewController *vc in self.navigationController.viewControllers) {
                            if ([vc isKindOfClass:c]) {
                                NSInteger idx = [self.navigationController.viewControllers indexOfObject:vc];
                                UIViewController *targetVC = self.navigationController.viewControllers[MAX(0, idx)];
                                [self.navigationController popToViewController:targetVC animated:YES];
                            }
                        }
                    }else{
                        [SVProgressHUD showInfoWithStatus:data.err.errorMsg];
                    }
                } failure:^(Error *err) {
                    [SVProgressHUD showInfoWithStatus:@"换绑失败"];
                }];
            }else{
                [SVProgressHUD showInfoWithStatus:@"您的手机号已注册云高APP！"];
            }
        }
    } failure:^(id error) {
        [SVProgressHUD showInfoWithStatus:@"当前网络不可用！"];
    }];
}

- (void)bindingV2{
    ygweakify(self);
    [SVProgressHUD show];
    
    BindBean *bb = [[BindBean alloc] initWithMobile:_phoneString validateCode:_tfYZM.text countryCode:[self.areaCodeStr stringByReplacingOccurrencesOfString:@"+" withString:@""]];
    [[API shareInstance] bindeviceWithBindBean:bb Success:^(AckBean *data) {
        ygstrongify(self);
        if (data.err.errorMsg == nil) {
            
            Class c = NSClassFromString(@"YGBindingListViewCtrl");
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:c]) {
                    NSInteger idx = [self.navigationController.viewControllers indexOfObject:vc];
                    UIViewController *targetVC = self.navigationController.viewControllers[MAX(0, idx)];
                    [self.navigationController popToViewController:targetVC animated:YES];
                }
            }
            
            [LoginManager sharedManager].session.mobilePhone = self.phoneString;
            [[NSUserDefaults standardUserDefaults] setObject:self.phoneString forKey:KGolfSessionPhone];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [SVProgressHUD showInfoWithStatus:@"绑定成功"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeBindingSuccess" object:nil];
        }else{
            [SVProgressHUD showInfoWithStatus:data.err.errorMsg];
        }
    } failure:^(Error *err) {
        
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
        self.buttonBinding.enabled = YES;
    }else{
        self.buttonBinding.enabled = NO;
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
    self.buttonBinding.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.isExchangePhoneBinding) {
        [self binding];
    }else{
        [self bindingV2];
    }
    return YES;
}

@end
