//
//  YGWalletTransferConfirmViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/15.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGWalletTransferConfirmViewCtrl.h"
#import "YGForgotPasswordViewCtrl.h"
#import "PersonInAddressList.h"
#import "SearchService.h"

@interface YGWalletTransferConfirmViewCtrl () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (nonatomic) int transferAmount;
@property (nonatomic) int distance;
@property (nonatomic) int maximalValue;
@property (weak, nonatomic) IBOutlet UIView *theView;
@end

@implementation YGWalletTransferConfirmViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeInformation];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(initializeDistance) userInfo:nil repeats:NO];
}

- (void)initializeInformation {
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    }else{
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
        } cancelReturn:^(id data) {
            [self.tabBarController setSelectedIndex:0];
        }];
    }
}

- (void)initializeUI {
    if (_model == nil) {
        self.model = [UserFollowModel alloc];
    }
    if (_person) {
        self.displayNameLabel.text = _person.addressName;
        _model.displayName = _person.displayName;
        _model.mobilePhone = _person.mobilePhone;
        _model.isFollowed = _person.isFollowed;
        _model.memberId = _person.memberId;
        _model.headImage = _person.headImage;
    } else {
        self.displayNameLabel.text = _model.displayName;
    }
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_model.headImage] placeholderImage:[UIImage imageNamed:@"head_image.png"]];
    self.maximalValue = (int)MIN([LoginManager sharedManager].myDepositInfo.banlance, 999999);
    self.amountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"本次最多可转%d元", _maximalValue] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入登录密码"attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]}];
}

- (void)initializeDistance {
    self.distance = _completeButton.frame.origin.y + _completeButton.frame.size.height + 216 + 4 - self.view.frame.size.height;
}

#pragma mark -UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_distance > 0) {
        self.theView.transform = CGAffineTransformMakeTranslation(0, -_distance);
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    _completeButton.enabled = NO;
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * StringOne = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField.tag == 1)
    {
        if ([StringOne length] > 6) {
            textField.text = [StringOne substringToIndex:6];
            return NO;
        }
    }
    [self judgeComplete:StringOne tag:textField.tag];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        self.transferAmount = [textField.text intValue];
        if (_transferAmount > _maximalValue) {
            textField.text = [NSString stringWithFormat:@"%d", _maximalValue];
        } else if (_transferAmount > 0) {
            textField.text = [NSString stringWithFormat:@"%d", _transferAmount];
        }
        if (_transferAmount == 0 && textField.text.length > 0) {
            textField.text = @"";
            [SVProgressHUD showImage:nil status:@"金额错误，请重新输入"];
        }
        self.transferAmount = [textField.text intValue];
    }
    self.theView.transform = CGAffineTransformMakeTranslation(0, 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
    [aTextfield resignFirstResponder];
    [self submit];
    return YES;
}

- (BOOL)judgeComplete:(NSString *)string tag:(NSInteger)tag {
    if (tag == 1) {
        if (string.length > 0 && _passwordTextField.text.length >= 6) {
            _completeButton.enabled = YES;
            return YES;
        }
    }
    if (tag == 2) {
        if (_amountTextField.text.length > 0 && string.length >= 6) {
            _completeButton.enabled = YES;
            return YES;
        }
    }
    _completeButton.enabled = NO;
    return NO;
}

#pragma mark - Action
- (IBAction)forgetPassWord:(id)sender{
    [_amountTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    YGForgotPasswordViewCtrl *vc = [YGForgotPasswordViewCtrl instanceFromStoryboard];
    [self pushViewController:vc title:@"忘记密码" hide:YES];
}

- (IBAction)foundTapGesture:(id)sender {
    if (_amountTextField.isFirstResponder || _passwordTextField.isFirstResponder) {
        [_amountTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
    }
}

- (IBAction)amountTransfer:(id)sender{
    [self foundTapGesture:nil];
    if ([LoginManager sharedManager].loginState) {
        [self submit];
    }else{
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
    }
}

- (void)submit{
    [SearchService userTransferAccountSessionId:[[LoginManager sharedManager] getSessionId] phoneNum:_model.mobilePhone tranAmount:_transferAmount passWord:_passwordTextField.text success:^(BOOL boolen) {
        if (boolen) {
            UIImage *image = _headImageView.image;
            NSArray * ctrlArray = self.navigationController.viewControllers;
            [self.navigationController popToViewController:ctrlArray[1] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfirmedTransfer" object:@{@"data":_model, @"image":image}];
        }
    } failure:^(id error) {
        
    }];
}
#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender{
    [self submit];
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *array = [NSArray arrayWithArray:data];
    if (array && array.count>0) {
        if (Equal(flag, @"deposit_info")) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
        }
    }
    [self initializeUI];
}

@end
