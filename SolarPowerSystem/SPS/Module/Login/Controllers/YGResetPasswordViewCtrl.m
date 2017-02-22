
#import "YGResetPasswordViewCtrl.h"
#import "YGLoginNoneCaptchaView.h"
#import "YYTextKeyboardManager.h"
#import "YGWeChatLoginLogic.h"

@interface YGResetPasswordViewCtrl ()<UITextFieldDelegate,YYTextKeyboardObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *labelSender;
@property (weak, nonatomic) IBOutlet UITextField *tfYZM;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfPasswordAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetAgain;
@property (weak, nonatomic) IBOutlet UIButton *buttonNoReceive;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinish;
@property (nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign) int count;//倒计时
@property (nonatomic,strong) UITextField *registTextField;//正在输入的textField
@property (weak, nonatomic) IBOutlet UIView *YZMLineView;
@property (weak, nonatomic) IBOutlet UIView *passwordLineView;
@property (weak, nonatomic) IBOutlet UIView *passwordAgainLineView;
@property (nonatomic,strong) YGWeChatLoginLogic *wechatLoginSer;
@end

@implementation YGResetPasswordViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.tableHeaderView.height = Device_Height - 20;
    self.labelSender.text = [NSString stringWithFormat:@"验证码已发送至 %@",_phoneString];
    self.buttonFinish.backgroundColor = [UIColor whiteColor];
    [self.buttonFinish setBackgroundImage:[UIImage imageWithColor:MainHighlightColor] forState:0];
    [self.buttonFinish setBackgroundImage:[UIImage imageWithColor:MainDarkHighlightColor] forState:UIControlStateHighlighted];
    self.buttonFinish.enabled = NO;
    [self countClick];
    [self getYZMRequest];

    [[YYTextKeyboardManager defaultManager] addObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition{
    
    YYTextKeyboardManager *manager = [YYTextKeyboardManager defaultManager];
    BOOL visible = manager.keyboardVisible;
    CGRect toFrame = [manager convertRect:transition.toFrame toView:self.view];
    CGRect textFieldFrame = [self.registTextField.superview convertRect:self.registTextField.frame toView:[GolfAppDelegate shareAppDelegate].window];
    CGFloat DValue = (textFieldFrame.origin.y + textFieldFrame.size.height - toFrame.origin.y);
    if (visible && DValue > 0) {
        [self.tableview setContentOffset:CGPointMake(0, DValue) animated:YES];
    }
    
    if (DValue <= 0) {
        [self.tableview setContentOffset:CGPointMake(0, -20) animated:YES];
    }
}

-(void)countClick{
    self.buttonGetAgain.layer.borderWidth = 0;
    self.buttonGetAgain.layer.cornerRadius = 0;
    [self.buttonGetAgain setTitle:@"重新获取 60秒" forState:UIControlStateDisabled];
    [self.buttonGetAgain setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
    self.count = 60;
    self.buttonGetAgain.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
}

- (void)timerFired:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonGetAgain setTitle:[NSString stringWithFormat:@"重新获取 %d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonGetAgain.enabled = YES;
        [self.buttonGetAgain setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
        [self.buttonGetAgain setTitle:@"  重新获取  " forState:UIControlStateNormal];
        [self.buttonGetAgain.layer setCornerRadius:14];
        self.buttonGetAgain.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        self.buttonGetAgain.layer.borderWidth = 0.5;
    }
}

#pragma mark 获取验证码请求
- (void)getYZMRequest{
    ygweakify(self);
    [ServerService publicValidateCode:_getYZMPhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {
        BaseService *ser = (BaseService *)obj;
        if (ser.success) {
            
        }
    } failure:^(id error) {
        ygstrongify(self);
        [SVProgressHUD showInfoWithStatus:@"获取验证码失败，请重试!"];
        [self.timer invalidate];
        self.timer = nil;
        self.buttonGetAgain.layer.borderWidth = 0.5;
        self.buttonGetAgain.enabled = YES;
        self.buttonGetAgain.layer.cornerRadius = 14;
        self.buttonGetAgain.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        [self.buttonGetAgain setTitle:@"  重新获取  " forState:0];
    }];
}

#pragma mark 按钮点击
#pragma mark --完成点击
- (IBAction)finishClick:(id)sender {
    [self finish];
}

- (void)finish{
    [self.view endEditing:YES];
    if (![self.tfPasswordAgain.text isEqualToString:self.tfPassword.text]) {
        [[GolfAppDelegate shareAppDelegate] alert:@"提示" message:@"你两次输入的密码不一致！"];
        return;
    }
    ygweakify(self);
    [LoginService getPasswordBack:_getYZMPhoneStr withValidateCode:_tfYZM.text withNewPassword:_tfPassword.text success:^(BOOL boolen) {
        ygstrongify(self);
        if (boolen) {
            [SVProgressHUD showSuccessWithStatus:@"修改密码成功!"];
            [_tfPassword resignFirstResponder];
            [_tfYZM resignFirstResponder];
            
            [[NSUserDefaults standardUserDefaults] setObject:_phoneString forKey:KGolfSessionPhone];
            [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:KGolfUserPassword];
            [GolfAppDelegate shareAppDelegate].autoLogIn = YES;
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:2] forKey:@"GolfSessionAutoLogin"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[LoginManager sharedManager] autoLoginInBackground:nil success:^(BOOL flag) {
                if (flag) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            } failure:^(HttpErroCodeModel *error) {
                
            }];
        }
        
    } failure:^(id error) {
        
    }];
}

#pragma mark --返回点击
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --收不到验证码点击
- (IBAction)noReceiveYZMClick:(UIButton *)sender {
    [self.tfYZM resignFirstResponder];
    [self.tfPassword resignFirstResponder];
    [self.tfPasswordAgain resignFirstResponder];
    
    YGLoginNoneCaptchaView *tg = [YGLoginNoneCaptchaView show];
    
    ygweakify(self)
    ygweakify(tg)
    tg.blockPhoneString = ^(id data){
        [SVProgressHUD show];
        ygstrongify(tg)
        if (tg.blockClose) {
            tg.blockClose(nil);
        }
        [ServerService publicValidateCode:_phoneString groupFlag:nil noMsg:0 codeType:1 success:^(id obj) {
            [SVProgressHUD dismiss];
            ygstrongify(self)
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
        self.wechatLoginSer = wechatLoginSer;
        [wechatLoginSer weChatLoginWithController:self];
    };
}

- (void)timerVoicedAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonNoReceive setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonGetAgain.hidden = YES;
        self.buttonNoReceive.hidden = NO;
        self.buttonNoReceive.enabled = YES;
        self.buttonNoReceive.layer.cornerRadius = 14;
        self.buttonNoReceive.layer.borderWidth = 0.5;
        self.buttonNoReceive.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        [self.buttonNoReceive setTitle:@"  收不到验证码? " forState:0];
        [self.buttonNoReceive setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
    }
}

#pragma mark --重新获取验证码点击
- (IBAction)getYZMAgain:(id)sender {
    self.buttonGetAgain.layer.borderWidth = 0;
    self.buttonGetAgain.layer.cornerRadius = 0;
    [self.buttonGetAgain setTitle:@"60秒" forState:UIControlStateDisabled];
    [self.buttonGetAgain setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
    self.count = 60;
    self.buttonGetAgain.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAgain:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
    [self getYZMRequest];
}

- (void)timerAgain:(NSTimer *)timer{
    if (_count != 1) {
        _count -= 1;
        [self.buttonGetAgain setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }else{
        [timer invalidate];
        self.buttonGetAgain.hidden = YES;
        self.buttonNoReceive.hidden = NO;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    if (textField == self.tfYZM) {
        NSUInteger yZMLength = [textField.text length] + string.length - range.length;
        return yZMLength <= 4;
    }
    if (textField == self.tfPassword) {
        NSUInteger passwordLength = [textField.text length] + string.length - range.length;
        return passwordLength <= 16;
    }
    if (textField == self.tfPasswordAgain) {
        NSUInteger passwordAgainLength = textField.text.length + string.length - range.length;
        return passwordAgainLength <= 16;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _tfYZM) {
        [self.tfPassword becomeFirstResponder];
    }
    if (textField == _tfPassword) {
        [self.tfPasswordAgain becomeFirstResponder];
    }
    if (textField == _tfPasswordAgain) {
        [self finish];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.tfPassword) {
        self.registTextField = _tfPassword;
        self.passwordLineView.backgroundColor = MainHighlightColor;
    }
    if (textField == self.tfPasswordAgain) {
        self.registTextField = _tfPasswordAgain;
        [self.passwordAgainLineView setBackgroundColor:MainHighlightColor];
    }
    if (textField == self.tfYZM) {
        self.registTextField = _tfYZM;
        [self.YZMLineView setBackgroundColor:MainHighlightColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.tfPassword) {
        self.passwordLineView.backgroundColor = MainGrayLineColor;
    }
    if (textField == self.tfPasswordAgain) {
        [self.passwordAgainLineView setBackgroundColor:MainGrayLineColor];
    }
    if (textField == self.tfYZM) {
        [self.YZMLineView setBackgroundColor:MainGrayLineColor];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.buttonFinish.enabled = NO;
    return YES;
}

- (void)textChange{
    if ([self validateYZM:self.tfYZM.text] && [self validatePassword:self.tfPassword.text] && [self validatePassword:self.tfPasswordAgain.text]) {
        self.buttonFinish.enabled = YES;
    }else{
        self.buttonFinish.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wechatLoginSer deallocNotification];
}
- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)validateYZM:(NSString *)text
{
    NSString *length = @"^\\d{4}$";
    return [self validate:text withRegExp:length];
}

- (BOOL)validatePassword:(NSString *)text
{
    NSString * length = @"^\\w{6,18}$";
    return [self validate:text withRegExp:length];
}

- (BOOL)validate:(NSString *)text withRegExp:(NSString *)regExp
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
    return [predicate evaluateWithObject:text];
}

@end
