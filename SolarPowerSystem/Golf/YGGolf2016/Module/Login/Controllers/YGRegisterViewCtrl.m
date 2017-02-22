

#import "YGRegisterViewCtrl.h"
#import "OpenUDID.h"
#import "YGRegisterNextStepViewCtrl.h"

#import "YGWeChatLoginLogic.h"
#import "CCAlertView.h"
#import "YGLoginSMSViewCtrl.h"
#import "WXApi.h"
#import "RegexKitLite.h"
#import "YGInternationalCodePicker.h"

@interface YGRegisterViewCtrl ()<UITextFieldDelegate>{
    NSInteger _wXTryToLogin;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *wxLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *btnSms;
@property (nonatomic,assign) NSUInteger maxPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonLocation;
@property (weak, nonatomic) IBOutlet UIView *phoneLineView;
@property (nonatomic,copy) NSString *phoneString;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherLoginLblConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wechatLoginConst;

@property (nonatomic,strong) YGWeChatLoginLogic *wecahtSer;
@end

@implementation YGRegisterViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.buttonNext.backgroundColor = [UIColor whiteColor];
    [self.buttonNext setBackgroundImage:[UIImage imageWithColor:MainHighlightColor] forState:0];
    [self.buttonNext setBackgroundImage:[UIImage imageWithColor:MainDarkHighlightColor] forState:UIControlStateHighlighted];
    if (self.tfPhone.text.length <= 0) {
        self.buttonNext.enabled = NO;
    }
    self.tableview.tableHeaderView.height = Device_Height - 20;
    if (IS_4_0_INCH_SCREEN || IS_3_5_INCH_SCREEN) {
        self.otherLoginLblConst.constant = 80;
        self.wechatLoginConst.constant = 30;
    }else{
        self.otherLoginLblConst.constant = 160;
        self.wechatLoginConst.constant = 40;
    }
    
    if (!([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])) {
        for (UIView *view in self.btnSms.superview.subviews) {
            if (view != self.btnSms) {
                [view removeFromSuperview];
            }
        }
        [self.btnSms centerInView:self.btnSms.superview];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark 按钮点击事件

#pragma mark --地区选择
- (IBAction)locationBtnClick:(id)sender {
    [self.tfPhone resignFirstResponder];
    
    [YGInternationalCodePicker selectChinaCodes:^(YGInternationalCode *code) {
        [sender setTitle:code.code forState:0];
    }];
}

#pragma mark --下一步
- (IBAction)nextStepClick:(id)sender {
    [self next];
}

- (void)next{
    [self.view endEditing:YES];
    NSString *regexStr= @"^(1)\\d{10}$";
    NSString *regexStrHK = @"^(852)\\d{8}$";
    NSString *regexStrMC = @"^(853)\\d{8}$";
    NSString *regexStrTW = @"^(886)\\d{9}$";
    NSString *msg = nil;
    
    if ([self.buttonLocation.currentTitle rangeOfString:@"+86"].location == NSNotFound) {
        self.phoneString = [[self.buttonLocation.currentTitle stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByAppendingString:self.tfPhone.text];
    }else{
        self.phoneString = _tfPhone.text;
    }
    
    if (![self.phoneString isMatchedByRegex:regexStr] && ![self.phoneString isMatchedByRegex:regexStrHK] && ![self.phoneString isMatchedByRegex:regexStrMC] && ![self.phoneString isMatchedByRegex:regexStrTW]){
        msg = @"您输入的手机号码格式不正确\n(香港手机号请填写“852+8位数字”，澳门手机号请填写“853+8位数字”,台湾手机号请填写“886+9位数字”)";
        [_tfPhone becomeFirstResponder];
        if (msg) {
            [[GolfAppDelegate shareAppDelegate] alert:nil message:msg];
        }
        return;
    }
    
    ygweakify(self);
    [LoginService checkPhoneNumber:self.phoneString success:^(NSDictionary *dic) {
        ygstrongify(self);
        if (dic) {
            if (![[dic objectForKey:@"flag"] boolValue]) {// 新用户
                YGRegisterNextStepViewCtrl *vc = [YGRegisterNextStepViewCtrl instanceFromStoryboard];
                vc.phoneString = self.tfPhone.text;
                vc.getYZMPhoneStr = self.phoneString;
                vc.areaCodeStr = self.buttonLocation.currentTitle;
                [self.navigationController pushViewController:vc animated:YES];
            }else{ // 老用户
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:@"手机号码已注册过，使用该号码登录。"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
                ygweakify(self);
                UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    ygstrongify(self);
                    [[NSUserDefaults standardUserDefaults] setObject:_tfPhone.text forKey:KGolfSessionPhone];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                [alert addAction:defaultAction];
                [alert addAction:loginAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } failure:^(id error) {
        HttpErroCodeModel *m = (HttpErroCodeModel *)error;
        [SVProgressHUD showInfoWithStatus:m.errorMsg];
    }];
}

#pragma mark --注册协议
- (IBAction)protocolClick:(id)sender {
    [[GolfAppDelegate shareAppDelegate] showInstruction:@"https://m.bookingtee.com/agreement.html" title:@"注册协议" WithController:self];
}
#pragma mark --返回点击
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --微信登录
- (IBAction)weChatLoginClick:(id)sender {
    YGWeChatLoginLogic *wecahtSer = [[YGWeChatLoginLogic alloc] init];
    [wecahtSer weChatLoginWithController:self];
    self.wecahtSer = wecahtSer;
}

#pragma mark --手机短信登录
- (IBAction)phoneLoginClick:(id)sender {
    YGLoginSMSViewCtrl *SMSLoginVC = [YGLoginSMSViewCtrl instanceFromStoryboard];
    [self.navigationController pushViewController:SMSLoginVC animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([self.buttonLocation.currentTitle rangeOfString:@"+86"].location != NSNotFound) {
        self.maxPhone = 11;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+852"].location != NSNotFound){
        self.maxPhone = 8;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+853"].location != NSNotFound){
        self.maxPhone = 8;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+886"].location != NSNotFound){
        self.maxPhone = 9;
    }
    NSUInteger newLength = [textField.text length] + string.length - range.length;
    if (newLength == _maxPhone || newLength == _maxPhone + 1) {
        self.buttonNext.enabled = YES;
    }else{
        self.buttonNext.enabled = NO;
    }
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    return newLength <= _maxPhone;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.buttonNext.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self next];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = [UIColor colorWithHexString:@"249DF3"];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.wecahtSer deallocNotification];
}

@end
