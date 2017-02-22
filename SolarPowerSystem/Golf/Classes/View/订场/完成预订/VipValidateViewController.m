//
//  VipValidateViewController.m
//  Golf
//
//  Created by user on 12-11-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "VipValidateViewController.h"
#import "UIButton+Custom.h"
#import "YGCapabilityHelper.h"

@interface VipValidateViewController ()

@end

@implementation VipValidateViewController
@synthesize clubId = _clubId;
@synthesize phoneNum =_phoneNum;


- (void)viewDidLoad
{
    self.title = @"会员身份验证";
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15+64.f, 120, 15)];
    titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"球会会员验证";
    [self.view addSubview:titleLabel];
    
    UILabel *titleDarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 15+64.f, 90, 15)];
    titleDarkLabel.font = [UIFont systemFontOfSize:13];
    titleDarkLabel.backgroundColor = [UIColor clearColor];
    titleDarkLabel.textColor = [Utilities R:97.0 G:97.0 B:97.0];
    titleDarkLabel.text = @"验证受理时段:";
    [self.view addSubview:titleDarkLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-88, 15+64.f, 90, 15)];
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [Utilities R:8.0 G:86.0 B:176.0];
    timeLabel.text = @"06:00-20:00";
    [self.view addSubview:timeLabel];
    
    _cardNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 45+64.f, Device_Width-20, 40)];
    _cardNoTextField.delegate = self;
    _cardNoTextField.borderStyle = UITextBorderStyleRoundedRect;
    _cardNoTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _cardNoTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    _cardNoTextField.returnKeyType=UIReturnKeyGo;
    _cardNoTextField.font = [UIFont systemFontOfSize:14];
    _cardNoTextField.placeholder = @"请填写您的会员证号";
    [self.view addSubview:_cardNoTextField];

    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100+64.f, Device_Width-20, 40)];
    _nameTextField.delegate = self;
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    _nameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    _nameTextField.returnKeyType=UIReturnKeyGo;
    _nameTextField.font = [UIFont systemFontOfSize:14];
    _nameTextField.placeholder = @"请填写您的名称或称呼";
    [self.view addSubview:_nameTextField];
    
    UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 155+64.f, Device_Width-20, 40)];
    explainLabel.font = [UIFont systemFontOfSize:14];
    explainLabel.backgroundColor = [UIColor clearColor];
    explainLabel.text = @"验证会员身份后，您预定会员球场可享受预订免付担保金的特权";
    explainLabel.numberOfLines = 0;
    [self.view addSubview:explainLabel];
    
    _sendButton = [UIButton myButton:self Frame:CGRectMake(10, 210+64.f, Device_Width-20, 40) NormalImage:@"yellowbtn" SelectImage:@"yellowbtn_s" Title:@"发送身份信息至球会验证" TitleColor:[UIColor whiteColor] Font:18. Action:@selector(sendMessageToClub)];
    [self.view addSubview:_sendButton];
    
    UIButton * _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _phoneButton.frame = CGRectMake((Device_Width-40)/2., 270+64.f, 40.0, 40.0);
    [_phoneButton setBackgroundImage:[Utilities getImageWithWidthStretchableByBundlePathWithImageName:@"phone_button"] forState:UIControlStateNormal];
    [_phoneButton addTarget:self action:@selector(presentSheets) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_phoneButton];
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(10, 320+64.f, Device_Width-20, 20)];
    label.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = @"拨打球会电话进行验证";
    [self.view addSubview:label];
}

- (void)sendMessageToClub{
    NSString *errorMsg = nil;
    NSString *cardNo = _cardNoTextField.text;
    NSString *memberName = _nameTextField.text;
    if(cardNo.length == 0 || cardNo.length > 20) {
        errorMsg = @"请输入有效的会员证号";
    }else if(memberName.length == 0 || memberName.length > 20) {
        errorMsg = @"请输入会员名字";
    }
    if([errorMsg length] > 0) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:errorMsg];
        return;
    }
    [[ServiceManager serviceManagerWithDelegate:self] validateVip:[[LoginManager sharedManager] getSessionId] withClubId:[NSString stringWithFormat:@"%d",self.clubId] withCardNo:cardNo withMemberName:memberName callBack:^(BOOL boolen) {
        if (boolen) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您的请求已提交，等待球会确认" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (_blockReturn) {
            _blockReturn (nil);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_cardNoTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    return YES;
}

- (void) presentSheets
{
    [YGCapabilityHelper call:self.phoneNum needConfirm:YES];
}

@end
