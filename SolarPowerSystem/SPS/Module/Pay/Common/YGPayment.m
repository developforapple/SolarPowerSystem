//
//  YGPayment.m
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayment.h"

NSString * PaySceneType(YGPaymentScene scene){
    switch (scene) {
        case YGPaymentSceneTeetime:     return @"teetime";  break;
        case YGPaymentSceneMall:        return @"commodity";break;
        case YGPaymentSceneTeaching:    return @"teaching"; break;
        case YGPaymentScenePublicCourse:return @"teaching"; break;
        case YGPaymentSceneTeachBooking:return @"virtualcourse";break;
    }
    return nil;
}

NSString * PayServiceAPI(YGPaymentScene scene){
    switch (scene) {
        case YGPaymentSceneTeetime:     return @"order_pay_unionpay";  break;
        case YGPaymentSceneMall:        return @"commodity_order_pay";break;
        case YGPaymentSceneTeaching:    return @"teaching_order_pay"; break;
        case YGPaymentScenePublicCourse:return @"teaching_order_pay"; break;
        case YGPaymentSceneTeachBooking:return @"virtual_course_order_pay";break;
    }
    return nil;
}

@interface YGPayment ()
@property (assign, readwrite, nonatomic) YGPaymentScene scene;
@property (assign, readwrite, nonatomic) NSInteger orderId;
@property (assign, readwrite, nonatomic) NSInteger amount;
@property (assign, readwrite, nonatomic) NSInteger yunbi;
@property (assign, readwrite, nonatomic) NSInteger balance;
@property (assign, readwrite, nonatomic) NSInteger advance;
@property (assign, readwrite, nonatomic) NSInteger thirdPlatform;
@property (assign, readwrite, nonatomic) BOOL canUseYunbi;
@property (assign, readwrite, nonatomic) BOOL canUseBalance;
@property (assign, readwrite, nonatomic) BOOL canUseAdvance;
@property (assign, readwrite, nonatomic) BOOL isUseYunbi;
@property (assign, readwrite, nonatomic) BOOL isUseBalance;
@property (assign, readwrite, nonatomic) BOOL isUseAdvance;
@end

@implementation YGPayment

- (instancetype)initWithScene:(YGPaymentScene)scene
                      orderId:(NSInteger)orderId
                    payAmount:(NSInteger)amount
{
    self = [super init];
    if (self) {
        self.scene = scene;
        self.orderId = orderId;
        self.amount = amount;
        self.platform = YGPaymentPlatformInApp;
        self.yunbi = 0;
        self.balance = 0;
        self.advance = 0;
        self.thirdPlatform = 0;
        self.canUseYunbi = NO;
        self.canUseBalance = NO;
        self.canUseAdvance = NO;
        _isUseYunbi = NO;
        _isUseBalance = NO;
        _isUseAdvance = NO;
    }
    return self;
}

- (void)setDeposit:(DepositInfoModel *)deposit
{
    _deposit = deposit;
    
    self.canUseYunbi = deposit.yunbiBalance > 0;
    self.canUseBalance = deposit.banlance > 0;
    
    //使用垫付的三个条件： 球场预定、云币加余额小于总金额、用户是免保证金用户
    self.canUseAdvance = self.scene == YGPaymentSceneTeetime && (deposit.yunbiBalance + deposit.banlance) < self.amount && deposit.no_deposit;
    
    [self useBalance:YES];
    [self useYunbi:YES];
    [self useAdvance:NO];
}

- (void)useYunbi:(BOOL)useYunbi
{
    if (useYunbi) {
        _isUseYunbi = [self canUseYunbi];
    }else{
        _isUseYunbi = NO;
    }
    [self compute];
}

- (void)useBalance:(BOOL)useBalance
{
    if (useBalance) {
        _isUseBalance = [self canUseBalance];
        if (_isUseBalance && self.amount==self.yunbi) {
            _isUseYunbi = NO;
        }
    }else{
        _isUseBalance = NO;
    }
    [self compute];
}

- (void)useAdvance:(BOOL)useAdvance
{
    if (useAdvance) {
        // 使用垫付
        if ([self canUseAdvance]) {
            _isUseYunbi = YES;
            _isUseBalance = YES;
            _isUseAdvance = YES;
        }else{
            _isUseAdvance = NO;
        }
    }else{
        _isUseAdvance = NO;
    }
    [self compute];
}

- (void)compute
{
    if (self.amount == 0) {
        // 待支付0的特殊情况
        _isUseAdvance = NO;
        self.yunbi = 0;
        self.balance = 0;
        self.advance = 0;
        self.thirdPlatform = 0;
        self.platform = YGPaymentPlatformInApp;
        if (self.paymentDidChanged) {
            self.paymentDidChanged();
        }
        return;
    }
    
    NSInteger yunbi = 0;
    if (_isUseYunbi) {
        yunbi = MIN(self.amount, self.deposit.yunbiBalance);
    }
    _isUseYunbi = yunbi > 0;
    
    NSInteger balance = 0;
    if (_isUseBalance) {
        balance = MIN(self.amount - yunbi, self.deposit.banlance);
    }
    _isUseBalance = balance > 0;
    
    NSInteger advance = 0;
    if (_isUseAdvance) {
        advance = self.amount - yunbi - balance;
    }
    _isUseAdvance = advance > 0;
    
    self.yunbi = yunbi;
    self.balance = balance;
    self.advance = advance;
    self.thirdPlatform = self.amount - yunbi - balance;
    
    if (self.thirdPlatform <= 0) {
        self.platform = YGPaymentPlatformInApp;
    }
    
    if (self.paymentDidChanged) {
        self.paymentDidChanged();
    }
}

#pragma mark - Pay
- (OrderSubmitParamsModel *)createSubmitModel
{
    OrderSubmitParamsModel *model = [OrderSubmitParamsModel new];
    model.sessionId = [[LoginManager sharedManager] getSessionId];
    model.orderId = (int)self.orderId;
    model.isMobile = 1;
    model.couponId = [self.couponId intValue];
    model.delayPay = self.isUseAdvance?1:0;
    model.payChannel = PayPlatformType(self.platform);
    
    int use_account = 0;
    if (self.isUseYunbi && self.isUseBalance) {
        use_account = 3;
    }else if (self.isUseYunbi){
        use_account = 2;
    }else if (self.isUseBalance){
        use_account = 1;
    }
    model.useAccount = use_account;
    return model;
}

@end
