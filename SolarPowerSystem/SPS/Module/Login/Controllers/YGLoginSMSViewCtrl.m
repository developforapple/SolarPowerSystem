

#import "YGLoginSMSViewCtrl.h"
#import "YGInternationalCodePicker.h"
#import "YGLoginSMSNextViewCtrl.h"

#import "RegexKitLite.h"

@interface YGLoginSMSViewCtrl ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonLocation;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (nonatomic,copy) NSString *phoneString;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *phoneLineView;
@end

@implementation YGLoginSMSViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableview.tableHeaderView.height = Device_Height - 20;
    self.buttonNext.backgroundColor = [UIColor whiteColor];
    [self.buttonNext setBackgroundImage:[UIImage imageWithColor:MainHighlightColor] forState:0];
    [self.buttonNext setBackgroundImage:[UIImage imageWithColor:MainDarkHighlightColor] forState:UIControlStateHighlighted];
    self.buttonNext.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark 按钮点击
#pragma mark --区号选择点击
- (IBAction)locationSelectClick:(id)sender {
    [self.tfPhone resignFirstResponder];
    [YGInternationalCodePicker selectChinaCodes:^(YGInternationalCode *code) {
        [sender setTitle:code.code forState:0];
    }];
}

#pragma mark --返回点击
- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --下一步点击
- (IBAction)nextClick:(id)sender {
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
        [[GolfAppDelegate shareAppDelegate] alert:nil message:msg];
    }else{
        YGLoginSMSNextViewCtrl *vc = [YGLoginSMSNextViewCtrl instanceFromStoryboard];
        vc.phoneString = self.tfPhone.text;
        vc.getYZMPhoneStr = self.phoneString;
        vc.areaCodeStr = self.buttonLocation.currentTitle;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSUInteger maxPhone = 0;
    if ([self.buttonLocation.currentTitle rangeOfString:@"+86"].location != NSNotFound) {
        maxPhone = 11;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+852"].location != NSNotFound){
        maxPhone = 8;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+853"].location != NSNotFound){
        maxPhone = 8;
    }else if ([self.buttonLocation.currentTitle rangeOfString:@"+886"].location != NSNotFound){
        maxPhone = 9;
    }
    NSUInteger newLength = [textField.text length] + string.length - range.length;
    if (newLength == maxPhone || newLength == maxPhone + 1) {
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
    return newLength <= maxPhone;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.buttonNext.enabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self next];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = MainHighlightColor;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _tfPhone) {
        self.phoneLineView.backgroundColor = MainGrayLineColor;
    }
}

@end