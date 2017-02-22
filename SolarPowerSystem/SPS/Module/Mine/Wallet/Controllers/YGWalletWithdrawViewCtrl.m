//
//  YGWalletWithdrawViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-7-10.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGWalletWithdrawViewCtrl.h"
#import "UIButton+Custom.h"
#import "YGCapabilityHelper.h"

@interface YGWalletWithdrawViewCtrl ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>{
    UITableView *_tableView;
    UITextField *_tf;
    UILabel *bottomLabel;
}

@end

@implementation YGWalletWithdrawViewCtrl
@synthesize depositInfoModel = _depositInfoModel;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, Device_Width, 88) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    
    NSString *clientService = [NSString stringWithFormat:@"提现的金额将在3-7个工作日内返还至原支付的银行卡，如有疑问请联系客服   %@",[Utilities getGolfServicePhone]];
    
    bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(_tableView.frame)+10.f, self.view.frame.size.width-50, 35)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textColor = [Utilities R:166 G:166 B:166];
    bottomLabel.font = [UIFont systemFontOfSize:13];
    bottomLabel.numberOfLines = 0;
    bottomLabel.lineBreakMode = NSLineBreakByWordWrapping;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.attributedText = [Utilities attributedStringWithString:clientService value1:[Utilities R:6 G:156 B:216] range1:NSMakeRange(clientService.length-12, 12) value2:nil range2:NSMakeRange(0, 0) font:13 otherValue:nil otherRange:NSMakeRange(0, 0)];
    [self.view addSubview:bottomLabel];
    
    UIButton *btn = [UIButton myButton:self Frame:bottomLabel.frame NormalImage:nil SelectImage:nil Title:nil TitleColor:nil Font:0 Action:@selector(phoneClick)];
    [self.view addSubview:btn];
    
    CGFloat y = CGRectGetMaxY(bottomLabel.frame) + 10.f;
    
    UIButton *backbtn = [UIButton myButton:self Frame:CGRectMake(15, y, Device_Width-30, 44) NormalImage:@"yellowbtn.png" SelectImage:nil Title:@"确认提现" TitleColor:[UIColor whiteColor] Font:17 Action:@selector(sureReturn)];
    [self.view addSubview:backbtn];
    
    if (self.depositInfoModel.banlance < 50) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"帐户可用余额大于或等于50元方可进行提现操作" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = 100;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        if (alertView.tag == 100) {
            [self.navigationController popViewControllerAnimated:YES];
        }else if(alertView.tag == 101){
            [[ServiceManager serviceManagerWithDelegate:self] userWithdraw:[[LoginManager sharedManager] getSessionId] amount:[_tf.text intValue]];
        }else if (alertView.tag == 102){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfirmedTransfer" object:nil];
            [self.navigationController popViewControllerAnimated:YES];//lyf 改
//            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)phoneClick
{
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

- (void)sureReturn{
    if (_tf.text.length==0) {
        [SVProgressHUD showInfoWithStatus:@"请输入提现金额"];
        return;
    }else if ([_tf.text intValue] < 50){
        [SVProgressHUD showInfoWithStatus:@"提现金额不能小于50"];
        return;
    }
    else if ([_tf.text intValue]>self.depositInfoModel.banlance){
        [SVProgressHUD showInfoWithStatus:@"提现金额不能大于账户余额"];
        return;
    }
    
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
        return;
    }
    
    [self.view endEditing:YES];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"确定要提现" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alertview.tag = 101;
    [alertview show] ;
    
}

- (void)loginButtonPressed:(id)sender{
    [self sureReturn];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count>0) {
        if (Equal(flag, @"user_withdraw")) {
            NSDictionary *dic = [array objectAtIndex:0];
            if ([dic objectForKey:@"withdraw_amount"]) {
                int amount = [[dic objectForKey:@"withdraw_amount"] intValue];
                if (amount>0) {
                    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"操作成功，我们将尽快为您处理" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alertview.tag = 102;
                    [alertview show] ;
                }
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = @"提现金额";
    
    _tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, Device_Width-115, 30)];
    _tf.delegate = self;
    _tf.placeholder = @"请输入金额";
    _tf.font = [UIFont systemFontOfSize:16];
    _tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _tf.keyboardType = UIKeyboardTypeNumberPad;
    cell.accessoryView = _tf;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 44)];
    view.backgroundColor = [Utilities R:241 G:240 B:246];
    
    UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 60, 14)];
    left.backgroundColor = [UIColor clearColor];
    left.textColor = [Utilities R:138 G:138 B:138];
    left.font = [UIFont systemFontOfSize:14];
    left.text = @"账户余额";
    [view addSubview:left];
    
    UILabel *right = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 200, 14)];
    right.backgroundColor = [UIColor clearColor];
    right.textAlignment = NSTextAlignmentLeft;
    right.textColor = [Utilities R:255 G:109 B:0];
    right.font = [UIFont systemFontOfSize:14];
    right.text = [NSString stringWithFormat:@"¥%ld",(long)self.depositInfoModel.banlance];
    [view addSubview:right];
    
    return view;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * StringOne = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([StringOne length] > 7) {
        textField.text = [StringOne substringToIndex:7];
        return NO;
    }
    return YES;
}

@end
