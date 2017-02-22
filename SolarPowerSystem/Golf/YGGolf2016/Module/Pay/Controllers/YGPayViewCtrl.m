//
//  YGPayViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayViewCtrl.h"
#import "YGPayCell.h"
#import "OrderService.h"
#import "CustomerServiceViewCtrl.h"
#import "YGPayResultView.h"
#import "YGApplePayHelper.h"
#import "YGPayThirdPlatformProcessor.h"
#import "WXApi.h"

@interface YGPayViewCtrl ()<UITableViewDelegate,UITableViewDataSource,ServiceManagerDelegate,YGPayProcess>
{
    BOOL _waitingServicePayResult;
}

@property (strong, nonatomic) YGPayThirdPlatformProcessor *thirdPlatformProcessor;

// 支付结果
@property (weak, nonatomic) IBOutlet YGPayResultView *resultPanel;

// 支付选项
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *paymentAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (copy, nonatomic) NSString *payTimeNote; //剩余时间提示
@property (copy, nonatomic) NSString *payTimeAlert;//剩余时间，秒

@property (strong, nonatomic) YGPayCell_YungaoPayment *inappCell;
@property (strong, nonatomic) YGPayCell_3rdPayment *thirdPlatformCell;
@property (strong, nonatomic) YGPayCell_Start *startPayCell;

@end

@implementation YGPayViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.baiduMobStatName = @"PayPage";
    
    [self initProcessor];
    
    [self initUI];
    
    ygweakify(self);
    [self.payment setPaymentDidChanged:^{
        ygstrongify(self);
        [self updateUI];
    }];

    [self loadDepositInfo];
    [self loadOrderCountdownTime];
}

- (void)setPayment:(YGPayment *)payment
{
    _payment = payment;
    switch (payment.scene) {
        case YGPaymentSceneMall:YGPostBuriedPoint(YGMallPointPay); break;
        case YGPaymentSceneTeetime:break;
        case YGPaymentSceneTeaching:break;
        case YGPaymentScenePublicCourse:break;
        case YGPaymentSceneTeachBooking:break;
    }
}

#pragma mark - UI
- (void)initUI
{
    [self leftNavButtonImg:@"ic_nav_back_light"];
    [self rightNavButtonImg:@"bg_pay_call"];
    
    self.resultPanel.hidden = YES;
    ygweakify(self);
    [self.resultPanel setLeftBtnAction:^{
        ygstrongify(self);
        if (self.payment.payResult.status == YGPayStatusSuccess) {
            //查看订单
            if (self.showOrderAction) {
                self.showOrderAction(self.payment.orderId);
            }
        }else if (self.payment.payResult.status == YGPayStatusFailed){
            //重新支付
            [self setResultVisible:NO];
        }
    }];
    [self.resultPanel setRightBtnAction:^{
        ygstrongify(self);
        if (self.backHomeAction) {
            self.backHomeAction();
        }
    }];
}

- (void)updateUI
{
    BOOL visible = nil != self.payment.deposit;
    if (visible) {
        [self.loadingIndicator stopAnimating];
    }
    [self.tableView setHidden:!visible animated:YES];
    self.countdownLabel.hidden = self.payTimeNote.length == 0;
    self.countdownLabel.text = self.payTimeNote;
    self.paymentAmountLabel.text = [NSString stringWithFormat:@"￥%ld",(long)self.payment.amount];
    [self.tableView reloadData];
//    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)doLeftNavAction
{
    if (self.payment.payResult) {
        [self back];
        return;
    }
    
    NSString *msg = [NSString stringWithFormat:@"下单后%@内未支付成功，订单将被取消，请尽快完成支付。",self.payTimeAlert?:@"24小时"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要离开支付？" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认离开" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self back];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"继续支付" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)back
{
    if (self.popAction) {
        self.popAction();
    }else{
        [super back];
    }
}

- (void)doRightNavAction
{
    [CustomerServiceViewCtrl show];
}

// 满足云高垫付的用户可以弹出这个提示
- (void)showYungaoAdvanceNotice
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"云高VIP用户可享受先打球后付款的特权。当您的账户可用余额不够，不够部分的金额将由云高担保垫付，您打球后再充值至帐户即可。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Data
- (void)loadDepositInfo
{
    [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:0];
}

- (void)loadOrderCountdownTime
{
    [ServerService orderPayTime:[[LoginManager sharedManager] getSessionId] orderId:(int)self.payment.orderId orderType:PaySceneType(self.payment.scene) success:^(NSString *payTimeNote,NSString *payTimeAlert) {
        RunOnMainQueue(^{
            self.payTimeNote = payTimeNote;
            self.payTimeAlert = payTimeAlert;
            [self updateUI];
        });
    } failure:^(id error) {
    }];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag
{
    if ([flag isEqualToString:@"deposit_info"]) {
        NSArray *list = data;
        DepositInfoModel *deposit = [list firstObject];
        if (deposit) {
            LoginManager *l = [LoginManager sharedManager];
            l.myDepositInfo = deposit;
            l.session.noDeposit = deposit.no_deposit;
            l.session.memberLevel = (int)deposit.memberLevel;
            
            RunOnMainQueue(^{
                self.payment.deposit = deposit;
                [self updateUI];
            });
        }
    }else if (_waitingServicePayResult){
        NSArray *list = data;
        _waitingServicePayResult = NO;
        self.payment.payModel = [list firstObject];
        [SVProgressHUD dismiss];
        [self pay];
    }
}

#pragma mark - Pay
// 准备支付
- (void)prepareToPay
{
    BOOL canPay = YES;
    if (self.payment.platform == YGPaymentPlatformWechat) {
        if (![WXApi isWXAppInstalled]) {
            [SVProgressHUD showErrorWithStatus:@"该设备未安装微信，请安装后重试"];
            canPay = NO;
        }else if (![WXApi isWXAppSupportApi]){
            [SVProgressHUD showErrorWithStatus:@"您的微信版本太旧，请更新后重试"];
            canPay = NO;
        }
    }else if(self.payment.platform == YGPaymentPlatformApplePay){
        
        if (![YGApplePayHelper isSupportUnionPay]) {
            [SVProgressHUD showErrorWithStatus:@"ApplePay不可用"];
            canPay = NO;
        }
        
    } else if (self.payment.platform == YGPaymentPlatformInApp){
        if (self.payment.thirdPlatform != 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择支付方式"];
            canPay = NO;
        }
    }
    
    BOOL useInAppPay = self.payment.isUseYunbi || self.payment.isUseBalance;
    BOOL useThridPay = self.payment.platform != YGPaymentPlatformInApp;
    
    if (!useInAppPay && !useThridPay) {
        [SVProgressHUD showErrorWithStatus:@"请选择支付方式"];
        canPay = NO;
    }
    if (canPay) {
        [self submitPayInfo];
    }
}

// 向服务器提交本次支付的一些数据
- (void)submitPayInfo
{
    OrderSubmitParamsModel *model = [self.payment createSubmitModel];
    NSString *api = PayServiceAPI(self.payment.scene);
    if (model && api.length > 0) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        _waitingServicePayResult = YES;
        [[ServiceManager serviceManagerWithDelegate:self] orderPay:model flag:api];
    }
}

// 接收到服务器返回的待支付数据，开始调起第三方支付，或者完成支付流程。
- (void)pay
{
    switch (self.payment.platform) {
        case YGPaymentPlatformInApp:{
            NSInteger state = self.payment.payModel.orderState;
            // 不要问我为什么。原来就是写1235
            YGPaymentResult *result = [YGPaymentResult new];
            result.tranId = self.payment.payModel.tranId;
            self.payment.payResult = result;
            
            if (state == 1 || state == 2 || state == 3 || state == 5) {
                result.status = YGPayStatusSuccess;
                
                [self callSuccess];
            }else{
                result.status = YGPayStatusFailed;
            }
            [self endPay:YES];
        }   break;
        case YGPaymentPlatformWechat:
        case YGPaymentPlatformAlipay:
        case YGPaymentPlatformUnionpay:
        case YGPaymentPlatformApplePay:{
            [self.thirdPlatformProcessor pay:self.payment.payModel.payXML platform:(YGPayThirdPlatform)self.payment.platform];
        }   break;
        case YGPaymentPlatformYunGao:break;
    }
}

// suc 指的是成功收到服务端数据
- (void)endPay:(BOOL)suc
{
    if (!suc)   return;
    
    switch (self.payment.payResult.status) {
        case YGPayStatusSuccess:    [self callSuccess];break;
        case YGPayStatusFailed:     [self callFailure];break;
        case YGPayStatusCanceled:   [self callCancel];break;
    }
    if (self.payment.payResult.status != YGPayStatusCanceled) {
        [self setResultVisible:YES];
    }
}

- (void)callSuccess
{
    if (self.payCallback) {
        self.payCallback(YGPayStatusSuccess,self.payment);
    }
}

- (void)callFailure
{
    if (self.payCallback) {
        self.payCallback(YGPayStatusFailed,self.payment);
    }
}

- (void)callCancel
{
    if (self.payCallback) {
        self.payCallback(YGPayStatusCanceled,self.payment);
    }
}

#pragma mark - Notification
- (void)initProcessor
{
    if (!kProductionEnvironment) {
        [YGPayThirdPlatformProcessor setDebugMode:YES];
    }
    self.thirdPlatformProcessor = [[YGPayThirdPlatformProcessor alloc] init];
    self.thirdPlatformProcessor.viewCtrl = self;
    self.thirdPlatformProcessor.receiver = self;
}

- (void)didReceivedThirdPayPlatformResult:(YGPaymentResult *)result platform:(YGPayThirdPlatform)platform
{
    if (!result || self.payment.platform != (YGPaymentPlatform)platform) {
        return;
    }
    result.tranId = self.payment.payModel.tranId;
    self.payment.payResult = result;
    
    [SVProgressHUD show];
    [OrderService endPay:result success:^(id obj) {
        [SVProgressHUD dismiss];
        [self endPay:YES];
    } failure:^(id error) {
        [SVProgressHUD dismiss];
        [self endPay:NO];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ygweakify(self);
    if (indexPath.row == 0) {
        if (!self.inappCell) {
            self.inappCell = [tableView dequeueReusableCellWithIdentifier:kYGPayCell_YungaoPayment forIndexPath:indexPath];
        }
        [self.inappCell configureWithPayment:self.payment];
        return self.inappCell;
    }
    
    if (indexPath.row == 1 ) {
        if (!self.thirdPlatformCell) {
            self.thirdPlatformCell = [tableView dequeueReusableCellWithIdentifier:kYGPayCell_3rdPayment forIndexPath:indexPath];
        }
        [self.thirdPlatformCell setShouldAdjustHeight:^(CGFloat h) {
            ygstrongify(self);
            [self.tableView reloadRow:1 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.thirdPlatformCell configureWithPayment:self.payment];
        return self.thirdPlatformCell;
    }
    
    if (indexPath.row == 2) {
        if (!self.startPayCell) {
            self.startPayCell = [tableView dequeueReusableCellWithIdentifier:kYGPayCell_Start forIndexPath:indexPath];
        }
        [self.startPayCell setWillStartPayAction:^{
            ygstrongify(self);
            [self prepareToPay];
        }];
        return self.startPayCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [YGPayCell_YungaoPayment cellHeight];
    }
    if (indexPath.row == 1 ) {
        return self.payment.thirdPlatform > 0?[YGPayCell_3rdPayment cellHeight]:1.f;
    }
    return [YGPayCell_Start cellHeight];
}

#pragma mark - Result
- (void)setResultVisible:(BOOL)visible
{
    if (visible) {
        [self.resultPanel updateWithResult:self.payment];
    }
    self.resultPanel.hidden = !visible;
    [self.tableView setHidden:visible animated:YES];
    [self.resultPanel setHidden:!visible animated:YES];
}

@end
