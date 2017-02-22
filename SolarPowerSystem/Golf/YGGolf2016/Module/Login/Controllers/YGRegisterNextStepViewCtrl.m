

#import "YGRegisterNextStepViewCtrl.h"
#import "YGLoginNoneCaptchaView.h"

#import "YGWeChatLoginLogic.h"

#import <PINCache/PINCache.h>
#import "YYTextKeyboardManager.h"

@interface YGRegisterNextStepViewCtrl ()<UITextFieldDelegate,YYTextKeyboardObserver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNum;
@property (weak, nonatomic) IBOutlet UITextField *tfYZM;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
/**
 邀请码textfield
 */
@property (weak, nonatomic) IBOutlet UITextField *tfRequest;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegist;
/**
 重新获取验证码
 */
@property (weak, nonatomic) IBOutlet UIButton *buttonNoYZM;
@property (weak, nonatomic) IBOutlet UIButton *noGetYZMBtn;
@property (weak, nonatomic) IBOutlet UIView *phoneLineView;
@property (weak, nonatomic) IBOutlet UIView *passwordLineView;
@property (weak, nonatomic) IBOutlet UIView *inviteLineVeiw;

@property (nonatomic,assign) int count;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) YGWeChatLoginLogic *wecahtSer;
@property (nonatomic,strong) UITextField *registTextField;//正在输入的textField
@end

@implementation YGRegisterNextStepViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableHeaderView.height = Device_Height - 20;
    self.labelPhoneNum.text = [NSString stringWithFormat:@"验证码已发送至 %@ %@",self.areaCodeStr,self.phoneString];
    self.buttonRegist.backgroundColor = [UIColor whiteColor];
    [self.buttonRegist setBackgroundImage:[UIImage imageWithColor:MainHighlightColor] forState:0];
    [self.buttonRegist setBackgroundImage:[UIImage imageWithColor:MainDarkHighlightColor] forState:UIControlStateHighlighted];
    self.buttonRegist.enabled = NO;
    [self countClick];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
    
    // 获取验证码
    [ServerService publicValidateCode:self.getYZMPhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {

    } failure:^(id error) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)countClick{
    [self.buttonNoYZM setTitle:@"重新获取 60秒" forState:UIControlStateDisabled];
    [self.buttonNoYZM setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
    self.count = 60;
    self.buttonNoYZM.enabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
}

- (void)timerFired:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonNoYZM setTitle:[NSString stringWithFormat:@"重新获取 %d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        [timer invalidate];
        self.timer = nil;
        self.buttonNoYZM.enabled = YES;
        [self.buttonNoYZM setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
        [self.buttonNoYZM setTitle:@"  重新获取  " forState:UIControlStateNormal];
        [self.buttonNoYZM.layer setCornerRadius:14];
        self.buttonNoYZM.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        self.buttonNoYZM.layer.borderWidth = 0.5;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
#pragma mark 按钮点击事件

#pragma mark --注册点击
- (IBAction)registClick:(id)sender {
    ygweakify(self);
    [[GolfAppDelegate shareAppDelegate] performBlock:^{
        ygstrongify(self);
        [self useRegister];
    } afterDelay:0.1];
}

- (void)useRegister{
    NSString *osName = [[UIDevice currentDevice] systemName];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *countryCode = [_areaCodeStr stringByReplacingOccurrencesOfString:@"+" withString:@""];
    ygweakify(self);
    [LoginService userRegist:_phoneString withPassword:_tfPassword.text withLongitude:[LoginManager sharedManager].currLongitude withLatitude:[LoginManager sharedManager].currLatitude withValidateCode:_tfYZM.text withDeviceToken:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] withOsName:osName withDeviceName:deviceName withOsVersion:[osVersion stringByAppendingFormat:@",%@",appVersion] withActivationCode:_tfRequest.text withGroupData:@"" withCountryCode:countryCode success:^(UserSessionModel *userSession) {
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
            [[NSUserDefaults standardUserDefaults] setObject:_phoneString forKey:KGolfSessionPhone];
            [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:KGolfUserPassword];
            [self gotoAccount:userSession.extraInfo];
            
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
            if (dic) {
                NSString *openId = dic[@"openid"];
                NSString *unionId = dic[@"unionid"];
                NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
                
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFootprintList" object:@"refresh"];
        }
    } failure:^(id error) {
        
    }];
}

- (void)gotoAccount:(NSString*)msg
{
    [LoginManager sharedManager].userPassWord = _tfPassword.text;
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
    
    [[NSUserDefaults standardUserDefaults] setObject:_tfPassword.text forKey:KGolfUserPassword];
    [SVProgressHUD showInfoWithStatus:msg];
    
    [[GolfAppDelegate shareAppDelegate].tabBarController setSelectedViewController:[GolfAppDelegate shareAppDelegate].tabBarController.viewControllers.lastObject];//lyf 注册之后要回到我的
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition{
    YYTextKeyboardManager *manager = [YYTextKeyboardManager defaultManager];
    BOOL visible = manager.keyboardVisible;
    CGRect toFrame = [manager convertRect:transition.toFrame toView:self.view];
    CGRect textFieldFrame = [self.registTextField.superview convertRect:self.registTextField.frame toView:[GolfAppDelegate shareAppDelegate].window];
    CGFloat DValue = (textFieldFrame.origin.y + textFieldFrame.size.height - toFrame.origin.y);
    if (visible && DValue > 0) {
        [self.tableView setContentOffset:CGPointMake(0, DValue) animated:YES];
    }
    
    if (DValue <= 0) {
        [self.tableView setContentOffset:CGPointMake(0, -20) animated:YES];
    }
}

#pragma mark --返回点击
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --再次获取验证码点击
- (IBAction)NoYZMClick:(id)sender {
    ygweakify(self);
    [ServerService publicValidateCode:_getYZMPhoneStr groupFlag:nil noMsg:0 codeType:0 success:^(id obj) {
        ygstrongify(self);
        BaseService *ser = (BaseService *)obj;
        if (ser.success) {
            [self.buttonNoYZM setTitle:@"60秒" forState:UIControlStateDisabled];
            self.buttonNoYZM.layer.cornerRadius = 0;
            self.buttonNoYZM.layer.borderWidth = 0;
            [self.buttonNoYZM setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
            self.count = 60;
            self.buttonNoYZM.enabled = NO;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getYZMAgain:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
        }
    } failure:^(id error) {
        
    }];
}

- (void)getYZMAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.buttonNoYZM setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        self.timer = nil;
        [timer invalidate];
        self.buttonNoYZM.hidden = YES;
        self.noGetYZMBtn.hidden = NO;
    }
}
#pragma mark --收不到验证码点击
- (IBAction)noGetYZMClick:(UIButton *)sender {
    [self.tfYZM resignFirstResponder];
    [self.tfRequest resignFirstResponder];
    [self.tfPassword resignFirstResponder];

    
    YGLoginNoneCaptchaView *tg = [YGLoginNoneCaptchaView show];

    ygweakify(self);
    ygweakify(tg);
    tg.blockPhoneString = ^(id data){
        [SVProgressHUD show];
        ygstrongify(tg);
        if (tg.blockClose) {
            tg.blockClose(nil);
        }
        
        [ServerService publicValidateCode:_phoneString groupFlag:nil noMsg:0 codeType:1 success:^(id obj) {
            [SVProgressHUD dismiss];
            ygstrongify(self);
            BaseService *ser = (BaseService *)obj;
            NSDictionary *dict = (NSDictionary *)ser.data;
            if (dict[@"service_phone"]) {
                self.labelPhoneNum.text = [NSString stringWithFormat:@"你将收到来自 %@ 的电话",dict[@"service_phone"]];
            }
            ygweakify(self);
            RunOnMainQueue(^{
                ygstrongify(self);
                sender.enabled = NO;
                sender.layer.borderWidth = 0;
                sender.layer.cornerRadius = 0;
                [sender setTitle:@"60秒" forState:UIControlStateDisabled];
                [sender setTitleColor:[UIColor colorWithHexString:@"bbbbbb"] forState:UIControlStateDisabled];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getVoiceYZMAgain:) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
                _count = 60;
            });
        } failure:^(id error) {
            [SVProgressHUD showInfoWithStatus:@"获取语音验证码失败！"];
        }];
    };
    tg.blockWechatLogin = ^(id data){
        ygstrongify(self);
        YGWeChatLoginLogic *wecahtSer = [[YGWeChatLoginLogic alloc] init];
        [wecahtSer weChatLoginWithController:self];
        self.wecahtSer = wecahtSer;
    };
}

- (void)getVoiceYZMAgain:(NSTimer *)timer{
    if (_count !=1) {
        _count -=1;
        [self.noGetYZMBtn setTitle:[NSString stringWithFormat:@"%d秒",_count] forState:UIControlStateDisabled];
    }
    else
    {
        self.timer = nil;
        [timer invalidate];
        self.buttonNoYZM.hidden = YES;
        self.noGetYZMBtn.enabled = YES;
        self.noGetYZMBtn.hidden = NO;
        self.noGetYZMBtn.layer.borderWidth = 0.5;
        self.noGetYZMBtn.layer.borderColor = [UIColor colorWithHexString:@"249DF3"].CGColor;
        self.noGetYZMBtn.layer.cornerRadius = 14;
        [self.noGetYZMBtn setTitleColor:[UIColor colorWithHexString:@"249DF3"] forState:0];
        [self.noGetYZMBtn setTitle:@"  收不到验证码? " forState:0];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
        
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    if (textField == self.tfYZM) {
        NSUInteger YZMLength = [textField.text length] + string.length - range.length;
        return YZMLength <= 4;
    }
    if (textField == self.tfPassword) {
        NSUInteger passwordLength = [textField.text length] + string.length - range.length;
        return passwordLength <= 16;
    }
    
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (textField != self.tfRequest) {
        self.buttonRegist.enabled = NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.tfYZM == textField) {
        [self.tfPassword becomeFirstResponder];
    }
    if (self.tfPassword == textField) {
        [self.tfRequest becomeFirstResponder];
    }
    if (self.tfRequest == textField) {
        ygweakify(self);
        [[GolfAppDelegate shareAppDelegate] performBlock:^{
            ygstrongify(self);
            [self useRegister];
        } afterDelay:0.1];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField == _tfYZM) {
        self.registTextField = _tfYZM;
        self.phoneLineView.backgroundColor = [UIColor colorWithHexString:@"249DF3"];
    }
    if (textField == _tfPassword) {
        self.registTextField = _tfPassword;
        self.passwordLineView.backgroundColor = [UIColor colorWithHexString:@"249DF3"];
    }
    if (textField == _tfRequest) {
        self.registTextField = _tfRequest;
        self.inviteLineVeiw.backgroundColor = [UIColor colorWithHexString:@"249DF3"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tfYZM) {
        self.registTextField = _tfYZM;
        self.phoneLineView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    }
    if (textField == _tfPassword) {
        self.registTextField = _tfPassword;
        self.passwordLineView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    }
    if (textField == _tfRequest) {
        self.registTextField = _tfRequest;
        self.inviteLineVeiw.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    }
}

- (void)textChange{
    if ( [self validateYZM:self.tfYZM.text] && [self validatePassword:self.tfPassword.text]) {
        self.buttonRegist.enabled = YES;
    }else{
        self.buttonRegist.enabled = NO;
    }
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.wecahtSer deallocNotification];
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
