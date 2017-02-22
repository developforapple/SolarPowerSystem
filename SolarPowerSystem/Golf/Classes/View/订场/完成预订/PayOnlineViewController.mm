//
//  PayOnlineViewController.m
//  Golf
//
//  Created by 黄希望 on 12-7-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PayOnlineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OpenUDID.h"
#import "UILabel+Hxw.h"
#import "CouponModel.h"
#import "UIButton+Custom.h"
#import "OrderDetailModel.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "FillOrderViewController.h"
#import "PackageConfirmViewController.h"
//#import "CommoditySuccessController.h"
//#import "YGMallOrderConfirmViewCtrl.h"
//#import "YGMallOrderDetailViewCtrl.h"
#import "ClubOrderViewController.h"
#import "TeachingPaySuccessController.h"
#import "TeachingJoinSuccessController.h"
#import "TeachingReservationSuccessController.h"
#import "JXChooseTimeController.h"
#import "JXConfirmOrderController.h"
#import "PublicCourseDetailController.h"
#import "TeachingOrderDetailViewController.h"
#import "TeachingCourseType.h"
#import "SubmitSuccessController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CCAlertView.h"
#import "YGCapabilityHelper.h"
#import "CustomerServiceViewCtrl.h"
#import "YGCouponListViewCtrl.h"

#import "YGPackageOrderDetailViewCtr.h"

NSString *cellTextNameItems[2][5] = {{@"现金券",@"云币抵付",@"余额支付",@"云高垫付",@"还需支付"},{@"微信支付",@"支付宝支付",@"银联手机支付"}};
NSString *detailTitleItems[3] = {@"推荐开通了微信支付的用户使用",@"推荐开通了支付宝支付的用户使用",@"支持储蓄卡和信用卡，无需开通网银"};
NSString *imageNameItems[3] = {@"wechatpay_icon",@"alipay_icon",@"unionpay_icon"};

@interface PayOnlineViewController()<WXApiDelegate>{
    BOOL _isUseAccountBanlance; // 使用账户余额
    BOOL _isUseYunbiBanlance; // 使用云币余额
    BOOL _isCgitPreparePay; // 使用云高垫付的先决条件
    
    NSString *_shareTitle;
    NSString *_shareContent;
    NSString *_shareImage;
    NSString *_shareUrl;
    
    UILabel *infoLabel;
}

@property (nonatomic,copy) NSString *payChannel;
@property (nonatomic,strong) OrderPayModel *opm;
@property (nonatomic,strong) DepositInfoModel *myDepositInfo;
@property (nonatomic,strong) CouponModel *couponModel;
@property (nonatomic,strong) NSArray* couponArray;

@end

@implementation PayOnlineViewController

- (void)loadView{
    [super loadView];
    
    // 不要手势返回
    self.interactivePopEnabled_ = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setContentInset:UIEdgeInsetsMake(40.f, 0, 0, 0)];   //预留了infoLabel的40的位置
    _tableView.separatorColor = [UIColor colorWithHexString:@"e6e6e6"];
    _tableView.hidden = YES;
    [self.view addSubview:_tableView];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, Device_Width, 0)];
    infoLabel.backgroundColor = [UIColor colorWithHexString:@"fff5e5"];
    infoLabel.textColor = [UIColor colorWithHexString:@"ff6d00"];
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:infoLabel];
    
    _payOnlineButton = [MyButton buttonWithType:UIButtonTypeCustom];
    _payOnlineButton.frame = CGRectMake(13, 15, Device_Width-26, 40);
    _payOnlineButton.backgroundColor = [UIColor colorWithHexString:@"ff6d00"];
    _payOnlineButton.highlightedColor = [UIColor colorWithHexString:@"D44D00"];
    [_payOnlineButton setTitle:@"确认支付" forState:UIControlStateNormal];
    [_payOnlineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_payOnlineButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    _payOnlineButton.layer.cornerRadius = 3;
    [_payOnlineButton addTarget:self action:@selector(submitOrderByUnionpay) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setRightBarButtonItems:[self navBtnTitleAndImageItems:@[@{@"btnImageName":@"btn_ic_phone",@"btnTitle":@"客服"}]]];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    _currentTime = [dateStr intValue];
    
    _couponAmount = 0;
    _isDafualt = YES;
    _isUseAccountBanlance = NO;
    _isUseYunbiBanlance = NO;
    self.payChannel = @"";
    
    [self getDepositAction];
    
    NSString *payType = nil;
    
    switch (self.waitPayFlag) {
        case WaitPayTypeTeetime: {
            payType = @"teetime";
            break;
        }
        case WaitPayTypeCommodity: {
            payType = @"commodity";
            break;
        }
        case WaitPayTypeTeaching: {
            payType = @"teaching";
            break;
        }
        case WaitPayTypePublicCourse: {
            payType = @"teaching";
            break;
        }
        case WaitPayTypeTeachBooking: {
            payType = @"virtualcourse";
            break;
        }
        case WaitPayTypeMall:break;
    }

    [ServerService orderPayTime:[[LoginManager sharedManager] getSessionId] orderId:_orderId orderType:payType success:^(NSString *payTimeNote,NSString *payTimeAlert) {
        infoLabel.text = payTimeNote;
        [UIView animateWithDuration:0.5 animations:^{
            infoLabel.height = 40;
        }];
    } failure:^(id error) {
        
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxCallBack:) name:@"WXCallBack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayCallBack:) name:@"ALiPayCallBack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unionpayCallback:) name:@"UPPayCallback" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _payOnlineButton.enabled = YES;
}

-(void)doLeftNavAction{
//    [super doLeftNavAction];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WXCallBack" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ALiPayCallBack" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPPayCallback" object:nil];
}


- (void)handleServerData{
    if(_couponAmount>=self.payTotal) {
        _isUseYunbiBanlance = NO;
        _isUseAccountBanlance = NO;
        _isCgitPreparePay = NO;
    } else {
        if(_isUseAccountBanlance && _myDepositInfo.banlance >= 0 && _couponAmount + _myDepositInfo.banlance >= self.payTotal) {
            _isUseYunbiBanlance = NO;
            _isCgitPreparePay = NO;
        }else if (_isUseYunbiBanlance && _couponAmount + _myDepositInfo.yunbiBalance >= self.payTotal){
            _isUseAccountBanlance = NO;
            _isCgitPreparePay = NO;
        }else {
            if (_myDepositInfo.yunbiBalance > 0) {
                _isUseYunbiBanlance = YES;
            } else {
                _isUseYunbiBanlance = NO;
            }
            if(_couponAmount + _myDepositInfo.yunbiBalance < self.payTotal && _myDepositInfo.banlance>0) {
                _isUseAccountBanlance = YES;
            } else {
                _isUseAccountBanlance = NO;
            }
            // 判断是否满足云高垫付的条件
            if (self.waitPayFlag == 1 &&
                _myDepositInfo.banlance+_myDepositInfo.yunbiBalance < self.payTotal-_couponAmount &&
                [LoginManager sharedManager].myDepositInfo.no_deposit) {
                // 1、必须是预定球场 2、必须是账户余额和云币余额之和小于支付金额 3、必须是免保证金用户
                _isCgitPreparePay = YES;
            }else{
                _isCgitPreparePay = NO;
            }
        }
    }
    
    _needToPay = [self resultOfNeedToPay];
    
    if (_needToPay > 0) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"]) {
            self.payChannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"];
        }else{
            self.payChannel = @"upmppay";
        }
    }else{
        self.payChannel = @"";
    }
    
    [self refreshData];
}

- (void)getDepositAction{
    if ([LoginManager sharedManager].loginState) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:0];
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_needToPay > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"666666"];
    }
    cell.clipsToBounds = YES;
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"";
    cell.textLabel.text = cellTextNameItems[indexPath.section][indexPath.row];
    cell.textLabel.text = cellTextNameItems[indexPath.section][indexPath.row];
    if (indexPath.section == 0){
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(100, 12, Device_Width-130, 18)];
        tf.backgroundColor = [UIColor clearColor];
        tf.userInteractionEnabled = NO;
        tf.font = [UIFont systemFontOfSize:14];
        tf.textAlignment = NSTextAlignmentRight;
        tf.tag = indexPath.row + 1;
        [cell.contentView addSubview:tf];
        
        if (indexPath.row == 0) { //现金券
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            tf.placeholder = @"使用现金券";
            if (_couponAmount > 0) {
                tf.text = [NSString stringWithFormat:@"¥%d",_couponAmount];
            }else{
                tf.text = @"";
            }
        }else if (indexPath.row == 1){  //云币抵付
            if (_myDepositInfo.yunbiBalance>0) {
                tf.placeholder = [NSString stringWithFormat:@"余额 %ld",(long)_myDepositInfo.yunbiBalance];
                tf.frame = CGRectMake(100, 12, Device_Width-145, 18);
                
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-35, 11, 22, 23)];
                
                if (_isUseYunbiBanlance) {
                    imageview.image = [UIImage imageNamed:@"ic_payment_right_blue_square"];
                    if (_myDepositInfo.yunbiBalance <= self.payTotal-_couponAmount) {
                        tf.text = [NSString stringWithFormat:@"¥%ld",(long)_myDepositInfo.yunbiBalance];
                    }else{
                        tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount];
                    }
                }else{
                    tf.text = @"";
                    imageview.image = [UIImage imageNamed:@"ic_payment_gray_square"];
                }
                cell.accessoryView = imageview;
            }else{
                cell.textLabel.text = @"";
            }
        }else if (indexPath.row == 2){  //余额支付
            tf.placeholder = [NSString stringWithFormat:@"余额 ¥%ld",(long)_myDepositInfo.banlance];
            tf.frame = CGRectMake(100, 12, Device_Width-145, 18);
            
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-35, 11, 22, 23)];
            if (_isUseAccountBanlance) {
                imageview.image = [UIImage imageNamed:@"ic_payment_right_blue_square"];
                if (_isUseYunbiBanlance) {
                    if (_myDepositInfo.banlance < self.payTotal-_couponAmount-_myDepositInfo.yunbiBalance) {
                        tf.text = [NSString stringWithFormat:@"¥%ld",(long)_myDepositInfo.banlance];
                    }else{
                        tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount-_myDepositInfo.yunbiBalance];
                    }
                }else{
                    if (_myDepositInfo.banlance > self.payTotal-_couponAmount) {
                        tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount];
                    }else{
                        tf.text = [NSString stringWithFormat:@"¥%ld",(long)_myDepositInfo.banlance];
                    }
                }
            }else{
                tf.text = @"";
                imageview.image = [UIImage imageNamed:@"ic_payment_gray_square"];
            }
            cell.accessoryView = imageview;
        }else if (indexPath.row == 3){  //云高垫付
            if (self.waitPayFlag == 1 && _myDepositInfo.no_deposit) {
                if (self.payTotal > _couponAmount && self.waitPayFlag == 1) {
                    tf.frame = CGRectMake(100, 12, Device_Width-145, 18);
                    tf.text = @"";
                    
                    if (_isUseAccountBanlance&&_isUseYunbiBanlance) {
                        if (_myDepositInfo.banlance+_myDepositInfo.yunbiBalance < self.payTotal-_couponAmount) {
                            tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount-_myDepositInfo.banlance-_myDepositInfo.yunbiBalance];
                        }
                    }else if (_isUseAccountBanlance){
                        if (_myDepositInfo.banlance < self.payTotal-_couponAmount) {
                            tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount-_myDepositInfo.banlance];
                        }
                    }else if (_isUseYunbiBanlance){
                        if (_myDepositInfo.yunbiBalance < self.payTotal-_couponAmount) {
                            tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount-_myDepositInfo.yunbiBalance];
                        }
                    }else{
                        tf.text = [NSString stringWithFormat:@"¥%0.f",self.payTotal-_couponAmount];
                    }
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(100, 10, 20, 21);
                    [button setBackgroundImage:[UIImage imageNamed:@"vip_aa.png"] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(vipAlertInfo:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.contentView addSubview:button];
                    
                    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-35, 11, 22, 23)];
                    if (_isCgitPreparePay) {
                        imageview.image = [UIImage imageNamed:@"ic_payment_right_blue_square"];
                    }else{
                        imageview.image = [UIImage imageNamed:@"ic_payment_gray_square"];
                        tf.text = @"";
                    }
                    cell.accessoryView = imageview;
                }else{
                    cell.textLabel.text = @"";
                }
            }else{
                cell.textLabel.text = @"";
                cell.accessoryView = nil;
            }
            
        }else if (indexPath.row == 4){  //还需支付
            tf.frame = CGRectMake(100, 12, Device_Width-115, 18);
            tf.textColor = [UIColor colorWithHexString:@"ff6d00"];
            if (_needToPay > 0) {
                tf.text = [NSString stringWithFormat:@"¥%d",_needToPay];
            }else{
                tf.text = @"";
                cell.textLabel.text = @"";
            }
        }
    }else if (indexPath.section == 1){  //微信、支付宝、银联支付
        cell.detailTextLabel.text = detailTitleItems[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:imageNameItems[indexPath.row]];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-95, 11, 22, 23)];
        if (indexPath.row == 0) {
            imageview.image = Equal(self.payChannel, @"wechatapp") ? [UIImage imageNamed:@"ic_payment_right_blue"] : [UIImage imageNamed:@"ic_payment_gray"];
        }else if (indexPath.row == 1){
            imageview.image = Equal(self.payChannel, @"aliapp") ? [UIImage imageNamed:@"ic_payment_right_blue"] : [UIImage imageNamed:@"ic_payment_gray"];
        }else{
            imageview.image = Equal(self.payChannel, @"upmppay") ? [UIImage imageNamed:@"ic_payment_right_blue"] : [UIImage imageNamed:@"ic_payment_gray"];
        }
        cell.accessoryView = imageview;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self couponBtnAction:nil];
        }else if (indexPath.row == 1){ // 云币
            if (_couponAmount >= self.payTotal && !_isUseYunbiBanlance) {
                [SVProgressHUD showInfoWithStatus:@"当前使用的现金劵已满足支付金额，无法使用云币支付"];
            }else{
                _isUseYunbiBanlance = !_isUseYunbiBanlance;
                if (!_isUseYunbiBanlance) {
                    _isCgitPreparePay = NO;
                }else if(_myDepositInfo.yunbiBalance >= self.payTotal-_couponAmount) {
                    _isUseAccountBanlance = NO;
                }
            }
        }else if (indexPath.row == 2){ // 余额
            if (_myDepositInfo.banlance > 0) {
                if (_couponAmount >= self.payTotal && !_isUseAccountBanlance) {
                    [SVProgressHUD showInfoWithStatus:@"当前使用的现金劵已满足支付金额，无法使用余额支付"];
                }else{
                    _isUseAccountBanlance = !_isUseAccountBanlance;
                    if(!_isUseAccountBanlance) {
                        _isCgitPreparePay = NO;
                    } else if(_myDepositInfo.banlance >= self.payTotal-_couponAmount || _myDepositInfo.yunbiBalance >= self.payTotal-_couponAmount) {
                        _isUseYunbiBanlance = NO;
                    }
                }
            }
        }else if (indexPath.row == 3){
            _isCgitPreparePay  = !_isCgitPreparePay;
            if (_isCgitPreparePay) {
                if(_myDepositInfo.banlance + _myDepositInfo.yunbiBalance >= self.payTotal - _couponAmount) {
                    _isCgitPreparePay = NO;
                } else {
                    if(_myDepositInfo.banlance>0) {
                        _isUseAccountBanlance = YES;
                    }
                    if(_myDepositInfo.yunbiBalance>0) {
                        _isUseYunbiBanlance = YES;
                    }
                }
            }
        }
        _needToPay = [self resultOfNeedToPay];
        if (_needToPay > 0) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"]) {
                self.payChannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"];
            }else{
                self.payChannel = @"wechatapp";
            }
        }else{
            self.payChannel = @"";
        }
    }else{
        if (_needToPay > 0) {
            if (indexPath.row == 0) {
                if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
                    self.payChannel = @"wechatapp";
                }else if ([WXApi isWXAppInstalled]){
                    [SVProgressHUD showInfoWithStatus:@"您的的微信客户端版本太旧，请更新后重试"];
                    return;
                }else{
                    [SVProgressHUD showInfoWithStatus:@"该手机未安装微信客户端，请安装后重试"];
                    return;
                }
            }else if (indexPath.row == 1){
                self.payChannel = @"aliapp";
            }else{
                self.payChannel = @"upmppay";
            }
            [[NSUserDefaults standardUserDefaults] setObject:self.payChannel forKey:@"pay_channel"];
        }else{
            self.payChannel = @"";
        }
    }
    [self refreshData];
}

- (void)refreshData {
    [_tableView reloadData];
}

- (int)resultOfNeedToPay{
    int needPay = 0;
    if (_couponAmount < self.payTotal) {
        needPay = self.payTotal - _couponAmount;
        if (_isUseAccountBanlance&&_isUseYunbiBanlance) {
            if (needPay > _myDepositInfo.yunbiBalance + _myDepositInfo.banlance) {
                needPay = needPay-_myDepositInfo.yunbiBalance - _myDepositInfo.banlance;
            }else{
                needPay = 0;
            }
        }else if (_isUseAccountBanlance){
            if (needPay > _myDepositInfo.banlance) {
                needPay = needPay-_myDepositInfo.banlance;
            }else{
                needPay = 0;
            }
        }else if (_isUseYunbiBanlance){
            if (needPay > _myDepositInfo.yunbiBalance) {
                needPay = needPay - _myDepositInfo.yunbiBalance;
            }else{
                needPay = 0;
            }
        }
        
        if (_isCgitPreparePay) {
            needPay = 0;
        }
    }
    
    if (needPay == 0) {
        self.payChannel = @"";
    }
    
    return needPay;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if(indexPath.row == 1) {
            return _myDepositInfo.yunbiBalance <= 0 ? 0 : 44;
        } else if(indexPath.row == 3) {
            if (_waitPayFlag > 1) {
                return 0;
            }else{
                if (!_myDepositInfo.no_deposit) {
                    return 0;
                }else{
                    return (_myDepositInfo.banlance>0 && _myDepositInfo.banlance+_myDepositInfo.yunbiBalance >= self.payTotal-_couponAmount) || _myDepositInfo.yunbiBalance >= self.payTotal-_couponAmount || _myDepositInfo.banlance >= self.payTotal-_couponAmount ? 0 : 44;
                }
            }
        } else if(indexPath.row == 4) {
            return _needToPay > 0 ? 44 : 0;
        }
        
        return 44;
    }else{
        return 54;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return _needToPay>0 ? 0.1 : 60;
    }
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 44)];
    bgview.backgroundColor = [Utilities R:241 G:240 B:246];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 88, 14)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.textColor = [UIColor colorWithHexString:@"333333"];
    leftLabel.font = [UIFont systemFontOfSize:14];
    if (section == 0) {
        leftLabel.text = @"支付总金额：";
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake( CGRectGetMaxX(leftLabel.frame)+4.f, 12, 100, 20)];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.textColor = [UIColor colorWithHexString:@"ff6d00"];
        rightLabel.font = [UIFont systemFontOfSize:16];
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%0.f",self.payTotal]];
        [as addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, 1)];
        rightLabel.attributedText = as;
        [bgview addSubview:rightLabel];
    }else if(section == 1){
        leftLabel.text = @"选择支付方式";
    }
    [bgview addSubview:leftLabel];
    return bgview;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ((section==0&&_needToPay<=0) || (section == 1&&_needToPay>0)) {
        UIView *bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 60)];
        bgview.backgroundColor = [Utilities R:241 G:240 B:246];
        [bgview addSubview:_payOnlineButton];
        return bgview;
    }
    return nil;
}

- (void)rightItemsButtonAction:(UIButton*)button{
    [CustomerServiceViewCtrl show];
}

- (void)getCouponList{
    [[ServiceManager serviceManagerWithDelegate:self] getCouponListWithSessionId:[[LoginManager sharedManager] getSessionId] status:1];
}

- (void)handleData{
    if (_isDafualt) {
        _isDafualt = NO;
        _couponAmount = [self getCouponBestValue:_couponArray];
    }else{
        _couponAmount = self.couponModel.couponAmount;
    }
    
    [self handleServerData];
}

- (int)getCouponBestValue:(NSArray*)couponList{
    self.couponModel = nil;
    if (couponList && couponList.count>0) {
        for (CouponModel *model in couponList){
            if (model.couponAmount<=_payTotal && model.limitAmount<=self.orderTotal) {
                if (self.waitPayFlag == 1) { // 球场预定
                    if (model.subType == CouponSubTypeNormal) {
                        self.couponModel = model;
                        break;
                    }else if (model.subType == CouponSubTypeTeetime) {
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.clubId]]) {
                            self.couponModel = model;
                            break;
                        }
                    }
                }else if (self.waitPayFlag == 2){ // 商品预定
                    if (model.subType == CouponSubTypeNormal) {
                        if (self.payTotal >= model.limitAmount) {
                            self.couponModel = model;
                            break;
                        }
                    }else if (model.subType == CouponSubTypeCategory){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.categoryId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }else if (model.subType == CouponSubTypeBrandId){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.brandId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }else if (model.subType == CouponSubTypeCommodity){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.commodityId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }
                }else if (self.waitPayFlag == 3 || self.waitPayFlag == 4){ // 教学
                    if (model.subType == CouponSubTypeNormal) {
                        if (self.payTotal >= model.limitAmount) {
                            self.couponModel = model;
                            break;
                        }
                    }else if (model.subType == CouponSubTypeProduct){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.productId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }else if (model.subType == CouponSubTypeAcademy){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.academyId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }else if (model.subType == CouponSubTypeClassType){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.classType]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }
                }else if (self.waitPayFlag == WaitPayTypeTeachBooking){
                    if (model.subType == CouponSubTypeNormal) {
                        if (self.payTotal >= model.limitAmount) {
                            self.couponModel = model;
                            break;
                        }
                    }else if (model.subType == CouponSubTypeAcademy){
                        if ([self compare:model.limitIds subString:[NSString stringWithFormat:@",%d,",self.academyId]]) {
                            if (self.payTotal >= model.limitAmount) {
                                self.couponModel = model;
                                break;
                            }
                        }
                    }
                }
            }
        }
        if (self.couponModel) {
            return self.couponModel.couponAmount;
        }
    }
    return 0;
}

- (BOOL)compare:(NSString*)str subString:(NSString*)sub{
    if (!str || !sub || str.length == 0 || sub.length == 0) {
        return NO;
    }
    NSString *newStr = [NSString stringWithFormat:@",%@,",str];
    NSRange range = [newStr rangeOfString:sub];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (IBAction)couponBtnAction:(id)sender
{
    YGCouponFilter *filter = [[YGCouponFilter alloc] init];
    filter.commodityIds = [NSSet setWithObject:@(self.commodityId)];
    filter.categoryIds = [NSSet setWithObject:@(self.categoryId)];
    filter.brandIds = [NSSet setWithObject:@(self.brandId)];
    filter.clubIds = [NSSet setWithObject:@(self.clubId)];
    filter.productIds = [NSSet setWithObject:@(self.productId)];
    filter.classTypes = [NSSet setWithObject:@(self.classType)];
    filter.academyIds = [NSSet setWithObject:@(self.academyId)];
    filter.amount = self.orderTotal;
    
    YGCouponListViewCtrl *vc = [YGCouponListViewCtrl instanceFromStoryboard];
    vc.selectionMode = YES;
    vc.filter = filter;
    vc.curCoupon = self.couponModel;
    ygweakify(self);
    [vc setDidSelectedCoupon:^(CouponModel *data) {
        ygstrongify(self);
        //data 不适用就是nil，否则就是CouponModel
        [self.navigationController popViewControllerAnimated:YES];
        [self popViewWithCoupon:data];
    }];
    [self pushViewController:vc title:@"选择现金券" hide:YES];
}

- (void)vipAlertInfo:(id)sender{
    [[GolfAppDelegate shareAppDelegate] alert:nil message:@"云高VIP用户可享受先打球后付款的特权。当您的账户可用余额不够，不够部分的金额将由云高担保垫付，您打球后再充值至帐户即可。"];
}

// 添加现金券成功后的回调
- (void)popViewWithCoupon:(CouponModel*)model{
    if (model.couponAmount > self.payTotal) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"您当前选择使用的现金券大于支付金额，现金券多余金额不可返还，仅限一次性使用"];
    }
    self.couponModel = model;
    [self performSelectorInBackground:@selector(getCouponList) withObject:nil];
}


- (void)submitOrderByUnionpay{
    if ([LoginManager sharedManager].loginState) {
        _payOnlineButton.enabled = NO;
        OrderSubmitParamsModel *model = [[OrderSubmitParamsModel alloc] init];
        // 登录用户session
        model.sessionId = [[LoginManager sharedManager] getSessionId] ;
        model.orderId = self.orderId;
        if (_isUseAccountBanlance && !_isUseYunbiBanlance) {
            model.useAccount = 1;
        }else if (!_isUseAccountBanlance && _isUseYunbiBanlance){
            model.useAccount = 2;
        }else if (_isUseAccountBanlance && _isUseYunbiBanlance){
            model.useAccount = 3;
        }else{
            model.useAccount = 0;
        }
        model.isMobile = 1;
        model.couponId = self.couponModel? self.couponModel.couponId : 0;
        model.delayPay = _isCgitPreparePay ? 1 : 0;
        model.payChannel = self.payChannel;
        
        [self payOnline:model];
    }else{
        [self doLeftNavAction];
    }
    
}

- (void)payOnline:(OrderSubmitParamsModel *)sender{
    
    NSString *flag;
    switch (self.waitPayFlag) {
        case WaitPayTypeTeetime:        flag = @"order_pay_unionpay";break;
        case WaitPayTypeCommodity:      flag = @"commodity_order_pay";break;
        case WaitPayTypeTeaching:
        case WaitPayTypePublicCourse:   flag = @"teaching_order_pay";break;
        case WaitPayTypeTeachBooking:   flag = @"virtual_course_order_pay";break;
        default: break;
    }
    if (flag) {
        [[ServiceManager serviceManagerWithDelegate:self] orderPay:sender flag:flag];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"coupon_list")) {
        _tableView.hidden = NO;
        self.couponArray = array;
        [self handleData];
    }else if (Equal(flag, @"deposit_info")){
        if (array && array.count > 0) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = [LoginManager sharedManager].myDepositInfo.memberLevel;
            self.myDepositInfo = [LoginManager sharedManager].myDepositInfo;
            
            [self getCouponList];
        }
    }else{
         _payOnlineButton.enabled = YES;
        if (array && array.count > 0) {
            _opm = [array objectAtIndex:0];
            _tranId = _opm.tranId;
            if (self.waitPayFlag == 4) {
                _shareTitle = _opm.shareTitle;
                _shareContent = _opm.shareContent;
                _shareImage = _opm.shareImage;
                _shareUrl = _opm.shareUrl;
            }
            if (Equal(self.payChannel, @"wechatapp")) {
                NSDictionary *xmlDic = _opm.payXML;
                if (xmlDic && xmlDic.count > 0) {
                    PayReq *request = [[PayReq alloc] init];
                    request.partnerId = [xmlDic objectForKey:@"partnerid"];
                    request.prepayId= [xmlDic objectForKey:@"prepayid"];
                    request.package = [xmlDic objectForKey:@"package"];
                    request.nonceStr= [xmlDic objectForKey:@"noncestr"];
                    request.timeStamp= [[xmlDic objectForKey:@"timestamp"] intValue];
                    request.sign= [xmlDic objectForKey:@"sign"];
                    [WXApi sendReq:request];
                    return;
                }
            }else if (Equal(self.payChannel, @"upmppay")){
                NSString *xmlStr = _opm.payXML;
                if (xmlStr != nil && xmlStr.length > 0) {
                    if ([UIDevice currentDevice].systemVersion.floatValue <5.0) {
                        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"非常抱歉，您当前的系统版本过低，手机银联支付仅支持IOS 5.0及以上版本。"];
                        return;
                    }
                    UPPaymentControl *control = [UPPaymentControl defaultControl];
                    [control startPay:xmlStr fromScheme:@"golfunionpay" mode:KUpmpPayMode viewController:self];
                    
//                    [UPPayPlugin startPay:xmlStr mode:KUpmpPayMode viewController:self delegate:self];
                    return;
                }
            }else if (Equal(self.payChannel, @"aliapp")){
                NSString *xmlStr = _opm.payXML;
                xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                [[AlipaySDK defaultService] payOrder:xmlStr fromScheme:@"golfaliapp" callback:^(NSDictionary *resultDic) {
                    [self handelAliPayResult:resultDic];
                }];
            }
            
            if (_opm.orderState == 1 || _opm.orderState == 2 || _opm.orderState == 3 || _opm.orderState == 5){
                [self pushSuccessOrder];
            }
        }
    }
}

- (void)wxCallBack:(NSNotification*)notification {
    BaseResp *resp = (BaseResp *)[notification object];
    tranEndModel *tranEnd = [[tranEndModel alloc] init];
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        switch (response.errCode) {
            case WXSuccess:
                tranEnd.tranStatus = 0;
                break;
            case WXErrCodeUserCancel:
                tranEnd.tranStatus = 2;
                break;
            default:
                tranEnd.tranStatus = 1;
                break;
        }
    }
    
    tranEnd.sessionId = [[LoginManager sharedManager] getSessionId];
    tranEnd.tranId = _tranId;
    
    if (_tranId > 0) {
        [OrderService endTransantionUnionpay:tranEnd success:^(NSDictionary *data) {
            if (data) {
                if (tranEnd.tranStatus == 0) {
                    [self pushSuccessOrder];
                }
                _payOnlineButton.enabled = YES;
            }
        } failure:^(id error) {
            _payOnlineButton.enabled = YES;
        }];
    }
}

- (void)alipayCallBack:(NSNotification*)notification{
    NSDictionary *resultDic = (NSDictionary*)[notification object];
    [self handelAliPayResult:resultDic];
}

- (void)unionpayCallback:(NSNotification *)noti
{
    NSString *code = noti.object;
    NSDictionary *info = noti.userInfo; //签名信息 目前不验证数据
    [self UPPayPluginResult:code];
}

- (void)handelAliPayResult:(NSDictionary*)result{
    NSString *resultCode = result[@"resultStatus"];
    NSString *msg = [self alertInfoStringWithCode:resultCode];
    if (msg) {
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:msg];
        [alert addButtonWithTitle:@"确定" block:^{
            tranEndModel *tranEnd = [[tranEndModel alloc] init];
            if (Equal(@"9000", resultCode)) {
                tranEnd.tranStatus = 0;
            }else{
                if (Equal(@"4000", resultCode)){
                    tranEnd.tranStatus = 1;
                }else if (Equal(@"6001", resultCode)){
                    tranEnd.tranStatus = 2;
                }
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"HHmmss"];
                NSString *dateStr = [formatter stringFromDate:[NSDate date]];
                _currentTime = [dateStr intValue];
            }
            
            tranEnd.sessionId = [[LoginManager sharedManager] getSessionId];
            tranEnd.tranId = _tranId;
            
            [OrderService endTransantionUnionpay:tranEnd success:^(NSDictionary *data) {
                if (data) {
                    if (tranEnd.tranStatus == 0) {
                        [self pushSuccessOrder];
                    }
                    _payOnlineButton.enabled = YES;
                }
            } failure:^(id error) {
                _payOnlineButton.enabled = YES;
            }];
        }];
        [alert show];
    }
}

- (NSString*)alertInfoStringWithCode:(NSString*)code{
    if (Equal(@"9000", code)) {
        return @"订单支付成功";
    }else if (Equal(@"8000", code)){
        return @"正在处理中";
    }else if (Equal(@"4000", code)){
        return @"订单支付失败";
    }else if (Equal(@"6001", code)){
        return @"用户中途取消";
    }else if (Equal(@"6002", code)){
        return @"网络连接出错";
    }
    return nil;
}

- (void)UPPayPluginResult:(NSString *)result
{
    tranEndModel *tranEnd = [[tranEndModel alloc] init];
    if (result && [result isEqualToString:@"success"]) {
        tranEnd.tranStatus = 0;
    }else{
        if (result && [result isEqualToString:@"fail"]){
            tranEnd.tranStatus = 1;
        }else if (result && [result isEqualToString:@"cancel"]){
            tranEnd.tranStatus = 2;
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HHmmss"];
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        _currentTime = [dateStr intValue];
    }
    
    tranEnd.sessionId = [[LoginManager sharedManager] getSessionId] ;
    tranEnd.tranId = _tranId;
    
    [OrderService endTransantionUnionpay:tranEnd success:^(NSDictionary *data) {
        if (data) {
            if (tranEnd.tranStatus == 0) {
                [self pushSuccessOrder];
            }
            _payOnlineButton.enabled = YES;
        }
    } failure:^(id error) {
        _payOnlineButton.enabled = YES;
    }];
}

- (void)pushSuccessOrder{
    if (self.waitPayFlag == 1) {
        if (_opm.autoConfirm==0) {
            if (self.isTraverPackage) {
                YGPackageOrderDetailViewCtr *vc = [YGPackageOrderDetailViewCtr instanceFromStoryboard];
                vc.orderId = self.orderId;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [self pushWithStoryboard:@"Coach" title:@"预订成功" identifier:@"OrderSuccessViewController" completion:^(BaseNavController *controller) {
                    controller.interactivePopEnabled_ = NO;
                    OrderSuccessViewController *orderSuccess = (OrderSuccessViewController*)controller;
                    orderSuccess.orderId = self.orderId;
                }];
            }
        }else{
            [self pushWithStoryboard:@"BookTeetime" title:@"支付成功" identifier:@"SubmitSuccessController" completion:^(BaseNavController *controller) {
                controller.interactivePopEnabled_ = NO;
                SubmitSuccessController *vc = (SubmitSuccessController*)controller;
                vc.orderId = self.orderId;
                vc.isFromPay = YES;
                vc.blockReturn = _blockReturn;
            }];
        }
    }else if (self.waitPayFlag == 2){
//        [self pushWithStoryboard:@"Coach" title:@"付款成功" identifier:@"CommoditySuccessController" completion:^(BaseNavController *controller) {
//            controller.interactivePopEnabled_ = NO;
//            CommoditySuccessController *commoditySuccess = (CommoditySuccessController*)controller;
//            commoditySuccess.orderId = self.orderId;
//        }];
    }else if (self.waitPayFlag == 3){
        if (self.classType == TeachingCourseTypeMulti || self.classType == TeachingCourseTypeSpecial) {
            [self pushWithStoryboard:@"Jiaoxue" title:@"支付成功" identifier:@"TeachingPaySuccessController" completion:^(BaseNavController *controller) {
                controller.interactivePopEnabled_ = NO;
                TeachingPaySuccessController *teachingPay = (TeachingPaySuccessController*)controller;
                teachingPay.orderId = self.orderId;
                teachingPay.blockReturn = _blockReturn;
            }];
        }else{
            [self pushWithStoryboard:@"Jiaoxue" title:@"预约成功" identifier:@"TeachingReservationSuccessController" completion:^(BaseNavController *controller) {
                controller.interactivePopEnabled_ = NO;
                TeachingReservationSuccessController *teachingReservateSuccess = (TeachingReservationSuccessController*)controller;
                teachingReservateSuccess.orderId = self.orderId;
                teachingReservateSuccess.blockReturn = _blockReturn;
            }];
        }
    }else if (self.waitPayFlag == 4){
        [self pushWithStoryboard:@"Jiaoxue" title:@"报名成功" identifier:@"TeachingJoinSuccessController" completion:^(BaseNavController *controller) {
            controller.interactivePopEnabled_ = NO;
            TeachingJoinSuccessController *teachingJoinSucess = (TeachingJoinSuccessController*)controller;
            teachingJoinSucess.blockReturn = _blockReturn;
            teachingJoinSucess.shareTitle = _shareTitle;
            teachingJoinSucess.shareContent = _shareContent;
            teachingJoinSucess.shareImage = _shareImage;
            teachingJoinSucess.shareUrl = _shareUrl;
        }];
    }else if (self.waitPayFlag == WaitPayTypeTeachBooking){
        // 练习场支付成功
        if (self.blockReturn) {
            self.blockReturn(nil);
        }
    }
}

- (void)presentSheet{
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

- (void)back{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil]; //lyf 临时加，暂时保证我的订单提示对

    NSInteger count = self.navigationController.viewControllers.count;
    BaseNavController *controller = self;
    if (count>1) {
        controller = [self.navigationController.viewControllers objectAtIndex:count-2];
    }
    
    if ([controller isKindOfClass:[FillOrderViewController class]] || [controller isKindOfClass:[PackageConfirmViewController class]]) {
        ClubOrderViewController *order = [[ClubOrderViewController alloc] init];
        order.orderId = self.orderId;
        order.title = [NSString stringWithFormat:@"订单%d",self.orderId];
        [order.navigationItem setHidesBackButton:YES];
        order.hidesBottomBarWhenPushed = YES;
        [[GolfAppDelegate shareAppDelegate].naviController popToRootViewControllerAnimated:NO];
        [GolfAppDelegate shareAppDelegate].naviController.navigationBarHidden = NO;
        [[GolfAppDelegate shareAppDelegate].naviController pushViewController:order animated:YES];
    }
//    else if ([controller isKindOfClass:[YGMallOrderConfirmViewCtrl class]]){
//        YGMallOrderDetailViewCtrl *orderDetailController = [[YGMallOrderDetailViewCtrl alloc] init];
//        orderDetailController.orderId = self.orderId;
//        orderDetailController.title = @"订单详情";
//        [orderDetailController.navigationItem setHidesBackButton:YES];
//        orderDetailController.hidesBottomBarWhenPushed = YES;
//        [[GolfAppDelegate shareAppDelegate].naviController popToRootViewControllerAnimated:NO];
//        [GolfAppDelegate shareAppDelegate].naviController.navigationBarHidden = NO;
//        [[GolfAppDelegate shareAppDelegate].naviController pushViewController:orderDetailController animated:YES];
//    }
    else if ([controller isKindOfClass:[JXChooseTimeController class]]
              ||[controller isKindOfClass:[JXConfirmOrderController class]]
              ||[controller isKindOfClass:[PublicCourseDetailController class]]){
        [self pushWithStoryboard:@"Teach" title:[NSString stringWithFormat:@"订单%d",self.orderId] identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
            TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
            vc.orderId = self.orderId;
            vc.blockReturn = _blockReturn;
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
