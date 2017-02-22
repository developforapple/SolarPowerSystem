//
//  YGWalletTopUpPlatformViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-5-6.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGWalletTopUpPlatformViewCtrl.h"
//#import "UPPayPlugin.h"
#import "UPPaymentControl.h"
//#import "UPPayPluginDelegate.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "tranEndModel.h"
#import "UIButton+Custom.h"
#import <AlipaySDK/AlipaySDK.h>
#import "CCAlertView.h"
#import "ReactiveCocoa.h"
#import "OrderService.h"

NSString *cellTextLabelNameItems[2][3] = {{@"充值金额"},{@"微信支付",@"支付宝支付",@"银联手机支付"}};
NSString *detailTextLabelItems[3] = {@"推荐开通了微信支付的用户使用",@"推荐开通了支付宝支付的用户使用",@"支持储蓄卡和信用卡，无需开通网银"};
NSString *cellImageNameItems[3] = {@"wechatpay_icon",@"alipay_icon",@"unionpay_icon"};

@interface YGWalletTopUpPlatformViewCtrl ()<UITableViewDelegate,UITableViewDataSource>//,UPPayPluginDelegate>
{
    NSString *_payChannel;
    int _tranId;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YGWalletTopUpPlatformViewCtrl
@synthesize chargeAmount = _chargeAmount;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"]) {
        _payChannel = [[NSUserDefaults standardUserDefaults] objectForKey:@"pay_channel"];
    }else{
        _payChannel = @"wechatapp";
    }
    
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:@"WXCallBack" object:nil]
      subscribeNext:^(id x) {
          ygstrongify(self);
          [self wxCallBack:x];
      }];
    
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:@"ALiPayCallBack" object:nil]
      subscribeNext:^(id x) {
          ygstrongify(self);
          [self alipayCallBack:x];
      }];
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:@"UPPayCallback" object:nil]
      subscribeNext:^(NSNotification *x) {
          ygstrongify(self);
          NSString *code = x.object;
          [self UPPayPluginResult:code];
     }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"¥ %d",self.chargeAmount];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [Utilities R:138 G:138 B:138];
        cell.detailTextLabel.text = detailTextLabelItems[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.text = cellTextLabelNameItems[indexPath.section][indexPath.row];
        cell.imageView.image = [UIImage imageNamed:cellImageNameItems[indexPath.row]];

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 23)];
        
        switch (indexPath.row) {
            case 0:
                imageview.image = [UIImage imageNamed:Equal(_payChannel, @"wechatapp") ? @"ic_payment_right_blue":@"ic_payment_gray"];
                break;
            case 1:
                imageview.image = [UIImage imageNamed:Equal(_payChannel, @"aliapp") ? @"ic_payment_right_blue":@"ic_payment_gray"];
                break;
            default:
                imageview.image = [UIImage imageNamed:Equal(_payChannel, @"upmppay") ? @"ic_payment_right_blue":@"ic_payment_gray"];
                break;
        }
        cell.accessoryView = imageview;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _payChannel = @"wechatapp";
        }else if (indexPath.row == 1){
            _payChannel = @"aliapp";
        }else{
            _payChannel = @"upmppay";
        }
        [[NSUserDefaults standardUserDefaults] setObject:_payChannel forKey:@"pay_channel"];
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 20 : 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 44 : 54;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"请选择充值方式";
    }
    return nil;
}

- (IBAction)chargePressedAction{
    if (!_payChannel) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:@"upomp_bypay_DIM.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
    }
    
    [[ServiceManager serviceManagerInstance] depositRechargeUnionpay:[[LoginManager sharedManager] getSessionId] withMoney:self.chargeAmount isMobile:1 payChannel:_payChannel callBack:^(NSDictionary *dic) {
        if(dic) {
            _tranId = [[dic objectForKey:@"tran_id"] intValue];
            
            if (Equal(_payChannel, @"wechatapp")) {
                NSDictionary *xmlDic = [dic objectForKey:@"pay_xml"];
                if (xmlDic && xmlDic.count > 0) {
                    PayReq *request = [[PayReq alloc] init];
                    request.partnerId = [xmlDic objectForKey:@"partnerid"];
                    request.prepayId= [xmlDic objectForKey:@"prepayid"];
                    request.package = [xmlDic objectForKey:@"package"];
                    request.nonceStr= [xmlDic objectForKey:@"noncestr"];
                    request.timeStamp= [[xmlDic objectForKey:@"timestamp"] intValue];
                    request.sign= [xmlDic objectForKey:@"sign"];
                    [WXApi sendReq:request];
                }
            }else if (Equal(_payChannel, @"upmppay")){
                NSString *xmlStr = [dic objectForKey:@"pay_xml"];
                if (xmlStr != nil && xmlStr.length > 0) {
                    
                    [[UPPaymentControl defaultControl] startPay:xmlStr fromScheme:@"golfunionpay" mode:KUpmpPayMode viewController:self];
                    
//                    [UPPayPlugin startPay:xmlStr mode:KUpmpPayMode viewController:self delegate:self];
                }
            }else if (Equal(_payChannel, @"aliapp")){
                NSString *xmlStr = [dic objectForKey:@"pay_xml"];
                xmlStr = [xmlStr stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                [[AlipaySDK defaultService] payOrder:xmlStr fromScheme:@"golfaliapp" callback:^(NSDictionary *resultDic) {
                    [self handelAliPayResult:resultDic];
                }];
            }
        }
    }];
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
                    [self performSelector:@selector(autoBack)];
                }
            }
        } failure:^(id error) {
        }];
    }
}

- (void)alipayCallBack:(NSNotification*)notification{
    NSDictionary *resultDic = (NSDictionary*)[notification object];
    [self handelAliPayResult:resultDic];
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
            }
            
            tranEnd.sessionId = [[LoginManager sharedManager] getSessionId];
            tranEnd.tranId = _tranId;
            
            if (_tranId > 0) {
                [OrderService endTransantionUnionpay:tranEnd success:^(NSDictionary *data) {
                    if (data) {
                        if (tranEnd.tranStatus == 0) {
                            [self performSelector:@selector(autoBack)];
                        }
                    }
                } failure:^(id error) {
                }];
            }
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
    }else if (result && [result isEqualToString:@"fail"]){
        tranEnd.tranStatus = 1;
    }else if (result && [result isEqualToString:@"cancel"]){
        tranEnd.tranStatus = 2;
    }
    tranEnd.sessionId = [[LoginManager sharedManager] getSessionId] ;
    tranEnd.tranId = _tranId;
    
    [OrderService endTransantionUnionpay:tranEnd success:^(NSDictionary *data) {
        if (data) {
            if (tranEnd.tranStatus == 0) {
                [self performSelector:@selector(autoBack)];
            }
        }
    } failure:^(id error) {
        
    }];
}

- (void)autoBack{
    if (_blockReturn) {
        _blockReturn(nil);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfirmedTransfer" object:nil];
}

@end
