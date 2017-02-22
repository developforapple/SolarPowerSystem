//
//  PackageConfirmViewController.m
//  Golf
//
//  Created by user on 12-12-20.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageConfirmViewController.h"
#import "Utilities.h"
#import "LoginManager.h"
#import "OpenUDID.h"
#import "SubmitSuccessController.h"
#import "PayOnlineViewController.h"

@interface PackageConfirmViewController ()

@end

@implementation PackageConfirmViewController
@synthesize myCondition = _myCondition;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"确认订单";
    
    _conditionModel = [[ConditionModel alloc] init];
    _teetimeModel = [[TeeTimeModel alloc] init];
    _teetimeAgent = [[TeeTimeAgentModel alloc] init];
    
    [self setModels];
    [self handleData];
}

- (void)setModels{
    _conditionModel.clubId = _myCondition.clubId;
    _conditionModel.price = _myCondition.price;
    _conditionModel.people = _myCondition.people;
    _conditionModel.payType = _myCondition.payType;
    _conditionModel.date = _myCondition.arriveDate;
    _conditionModel.time = @"07:30";
    _conditionModel.personName = _myCondition.memberName;
    _conditionModel.personPhone = _myCondition.memberPhone;
    _conditionModel.prepayAmount = _myCondition.prepayAmount;
    
    if (_myCondition.agentId <= 0) {
        _teetimeModel.isOnlyCreditCard = YES;
        _teetimeModel.depositEachMan = _conditionModel.prepayAmount;
        _teetimeModel.teetime = @"07:30";
        _teetimeModel.price = _myCondition.price;
        _teetimeModel.mans = _myCondition.people;
        _teetimeModel.courseName = _myCondition.packageType;
        _teetimeModel.courseId = _myCondition.specId;
        _teetimeModel.holidayCancelBookHours = 24;
        _teetimeModel.normalCancelBookHours = 24;
        _teetimeModel.priceContent = _myCondition.packageName;
    }
    else{
        _teetimeAgent.agentId = _myCondition.agentId;
        _teetimeAgent.agentName = _myCondition.agentName;
        _teetimeAgent.teetime = @"07:30";
        _teetimeAgent.price = _myCondition.price;
        _teetimeAgent.normalCancelBookHours = 24;
        _teetimeAgent.holidayCancelBookHours = 24;
        _teetimeAgent.depositEachMan = _conditionModel.prepayAmount;
        _teetimeAgent.isOnlyCreditCard = YES;
        _teetimeAgent.priceContent = _myCondition.packageName;
        _teetimeAgent.orderId = 0;
        _teetimeAgent.description = @"";
    }
}

- (NSString *)dateWithString:(NSString *)date_{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:date_];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *week = [Utilities getWeekDayByDate:date];
    return [NSString stringWithFormat:@"%@ %@",dateStr,week];
}

- (void)handleData{
    
    NSString *date = [self dateWithString:_myCondition.arriveDate];
    NSString *arriveDate = [NSString stringWithFormat:@"到达日期#%@",date];
    
    NSString *bookMemberNum = [NSString stringWithFormat:@"预订人数#%d人",_myCondition.people];

    NSString *playMember = [NSString stringWithFormat:@"打 球 人#%@",_myCondition.memberName];

    NSString *phoneStr = [NSString stringWithFormat:@"联系电话#%@",_myCondition.memberPhone];
    
    NSString *money = [NSString stringWithFormat:@"￥%d",_myCondition.price*_myCondition.people];
    NSString *orderMoney = [NSString stringWithFormat:@"订单总价#%@#0xff6600",money];
    
    NSString *supplyName = nil;
    NSString *noteInfo = nil;

    if (_myCondition.agentId > 0) {
        supplyName = [NSString stringWithFormat:@"提供商家#%@",_myCondition.agentName];
    }
    else{
        supplyName = [NSString stringWithFormat:@"提供商家#球会官方"];
    }
    if (_myCondition.noteInfo.length > 0) {
        noteInfo = [NSString stringWithFormat:@"备注信息#%@",_myCondition.noteInfo];
    }
    else{
        noteInfo = [NSString stringWithFormat:@"备注信息#无备注信息"];
    }
    NSString *giveYunbiString = nil;//lyf 加
    if (_myCondition.giveYunbi > 0) {
        giveYunbiString = [NSString stringWithFormat:@"可返云币#%d", _myCondition.giveYunbi*_myCondition.people];
    }
    NSArray *array = nil;
    
    if (_conditionModel.prepayAmount > 0) {
        NSString *pay = [NSString stringWithFormat:@"￥%d",_conditionModel.prepayAmount * _conditionModel.people];
        NSString *orderPrePay = nil;
        if (_conditionModel.payType == PayTypeDeposit) {
            orderPrePay = [NSString stringWithFormat:@"支付押金#%@#0xff6600",pay];
        }else if (_conditionModel.payType == PayTypeOnlinePart){
            orderPrePay = [NSString stringWithFormat:@"预付金额#%@#0xff6600",pay];
        }
        if (_myCondition.giveYunbi > 0) {
            array = [NSArray arrayWithObjects:arriveDate,bookMemberNum,playMember,phoneStr,orderMoney,orderPrePay,giveYunbiString,supplyName,noteInfo, nil];
        } else
            array = [NSArray arrayWithObjects:arriveDate,bookMemberNum,playMember,phoneStr,orderMoney,orderPrePay,supplyName,noteInfo, nil];
    }else{
        if (_myCondition.giveYunbi > 0) {
            array = [NSArray arrayWithObjects:arriveDate,bookMemberNum,playMember,phoneStr,orderMoney,giveYunbiString,supplyName,noteInfo, nil];
        } else
            array = [NSArray arrayWithObjects:arriveDate,bookMemberNum,playMember,phoneStr,orderMoney,supplyName,noteInfo, nil];
    }
    
    
    DetailInfoView *detailInfoView = [[DetailInfoView alloc] initWithFrame:CGRectMake(0, 64, Device_Width, 396) withHeadTitle:_myCondition.packageName withContentArray:array withlocation:75.0];
    [self.view addSubview:detailInfoView];

    CGRect rt = _lblTishiTitle.frame;
    rt.origin.y = detailInfoView.frame.origin.y + detailInfoView.frame.size.height + 15;
    _lblTishiTitle.frame = rt;
    
    rt = _lblTishiLabel.frame;
    rt.origin.y = _lblTishiTitle.frame.origin.y + _lblTishiTitle.frame.size.height + 5;
    _lblTishiLabel.frame = rt;
    
    rt = _btnSubmit.frame;
    rt.origin.y = _lblTishiLabel.frame.origin.y + _lblTishiLabel.frame.size.height + 20;
    _btnSubmit.frame = rt;
    
    if (_myCondition.bookConfirm == 2) {
        _lblTishiTitle.hidden = YES;
        _lblTishiLabel.hidden = YES;
        
        rt = _btnSubmit.frame;
        rt.origin.y = detailInfoView.frame.origin.y + detailInfoView.frame.size.height + 20;
        _btnSubmit.frame = rt;
    }
    
}

- (IBAction)buttonSubmit:(id)sender{
    if (![LoginManager sharedManager].loginState) {
        NSString *userPhone = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
        if(userPhone.length == 0) {
            userPhone = _myCondition.memberPhone;
            [[NSUserDefaults standardUserDefaults] setObject:userPhone forKey:KGolfSessionPhone];
        }
        [[LoginManager sharedManager] judgeLoginOrRegestWithPhoneNum:userPhone delegate:nil blockRetrun:^(id data) {
            [self buttonSubmit:nil];
        }];
        return;
    }
    _btnSubmit.enabled = NO;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    _serialNum = [dateStr intValue];
    
    OrderSubmitParamsModel *model = [[OrderSubmitParamsModel alloc] init];
    // TeeTime 开球日期
    model.teeTimeDate = _myCondition.arriveDate;
    // 球会id
    model.clubId = _myCondition.clubId;
    if(_myCondition.agentId <= 0) {
        model.courseId = _teetimeModel.courseId;
        model.teeTimeTime = _teetimeModel.teetime;
    } else {
        model.teeTimeTime = _teetimeAgent.teetime;
    }
    model.memberNum = _myCondition.people;
    model.imeiNum = [OpenUDID value];
    model.sessionId = [[LoginManager sharedManager] getSessionId] ;
    model.payType = _myCondition.payType;
    if(model.payType == PayTypeDeposit){
        model.payAmount = _conditionModel.prepayAmount * _conditionModel.people;
    }else if (model.payType == PayTypeOnline){
        model.payAmount = _myCondition.price*_myCondition.people;
    }else if (model.payType == PayTypeOnlinePart){
        model.payAmount = _conditionModel.prepayAmount * _conditionModel.people;
    }
    model.useAccount = 0;
    model.memberName = _myCondition.memberName;
    model.mobilePhone = _myCondition.memberPhone;
    model.serialNo = _serialNum;
    model.packageId = _myCondition.packageId;
    model.specId = _myCondition.specId;
    model.agentId = _myCondition.agentId;
    model.description = _myCondition.noteInfo;
    model.isMobile = 1;
    model.onlySubmit = 1;
    
    __weak PackageConfirmViewController *vc = self;
    [OrderService orderSubmitUnionpay:model success:^(OrderSubmitModel *osm){
        if (osm.orderId > 0) {
            if (osm.orderState == 6) {
                PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                payOnline.orderId = osm.orderId;
                payOnline.payTotal = osm.payTotal;
                payOnline.orderTotal = _myCondition.price*_myCondition.people;
                payOnline.waitPayFlag = 1;
                payOnline.clubId = _myCondition.clubId;
                [vc pushViewController:payOnline title:@"在线预订" hide:YES];
            }else if (osm.orderState == 1){
                [self pushWithStoryboard:@"Coach" title:@"订单成功" identifier:@"OrderSuccessViewController" completion:^(BaseNavController *controller) {
                    OrderSuccessViewController *orderSuccess = (OrderSuccessViewController*)controller;
                    orderSuccess.orderId = osm.orderId;
                }];
            }else if (osm.orderState == 5){
                [self pushWithStoryboard:@"BookTeetime" title:@"提交成功" identifier:@"SubmitSuccessController" completion:^(BaseNavController *controller) {
                    SubmitSuccessController *vc = (SubmitSuccessController*)controller;
//                    vc.orderId = model.orderId;//lyf 屏蔽
                    vc.orderId = osm.orderId;//lyf 加

                }];
            }
            _btnSubmit.enabled = YES;
        }
    }failure:^(id error) {
        _btnSubmit.enabled = YES;
    }];
}

@end
