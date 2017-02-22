//
//  YGPayCell.m
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayCell.h"

@implementation YGPayCell
+ (CGFloat)cellHeight
{
    return 44.f;
}

- (void)configureWithPayment:(YGPayment *)payment
{
    _payment = payment;
    [self setup];
}

- (void)setup{}
@end

NSString *const kYGPayCell_YungaoPayment = @"YGPayCell_YungaoPayment";
@implementation YGPayCell_YungaoPayment

+ (CGFloat)cellHeight
{
    return 126.f;
}

- (void)setup
{
    NSInteger myYunbi = self.payment.deposit.yunbiBalance;
    if (!self.payment.canUseYunbi) {
        self.yunbiLabel.text = [NSString stringWithFormat:@"可抵扣 %ld",(long)myYunbi];
        self.yunbiLabel.highlighted = NO;
        self.yunbiBtn.enabled = NO;
        self.yunbiBtn.selected = NO;
    }else if (self.payment.isUseYunbi) {
        self.yunbiLabel.text = [NSString stringWithFormat:@"￥%ld",(long)self.payment.yunbi];
        self.yunbiLabel.highlighted = YES;
        self.yunbiBtn.enabled = YES;
        self.yunbiBtn.selected = YES;
    }else{
        self.yunbiLabel.text = [NSString stringWithFormat:@"可抵扣 %ld",(long)myYunbi];
        self.yunbiLabel.highlighted = NO;
        self.yunbiBtn.enabled = YES;
        self.yunbiBtn.selected = NO;
    }
    
    NSInteger myBalance = self.payment.deposit.banlance;
    if (!self.payment.canUseBalance) {
        self.balanceLabel.text = [NSString stringWithFormat:@"余额 %ld",(long)myBalance];
        self.balanceLabel.highlighted = NO;
        self.balanceBtn.enabled = NO;
        self.balanceBtn.selected = NO;
    }else if (self.payment.isUseBalance) {
        self.balanceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)self.payment.balance];
        self.balanceLabel.highlighted = YES;
        self.balanceBtn.enabled = YES;
        self.balanceBtn.selected = YES;
    }else{
        self.balanceLabel.text = [NSString stringWithFormat:@"余额 %ld",(long)myBalance];
        self.balanceLabel.highlighted = NO;
        self.balanceBtn.enabled = YES;
        self.balanceBtn.selected = NO;
    }
    
    if (self.payment.isUseAdvance) {
        //TODO
    }else{
        //TODO
    }
}

- (IBAction)btnAction:(UIButton *)btn
{
    BOOL selected = btn.selected;
    if (btn == self.yunbiBtn) {
        [self.payment useYunbi:!selected];
    }else if (btn == self.balanceBtn){
        [self.payment useBalance:!selected];
    }else{
        [self.payment useAdvance:!selected];
    }
}
@end

#import "YGPayThridPlatformPanel.h"
#import "YGApplePayHelper.h"

NSString *const kYGPayCell_3rdPayment = @"YGPayCell_3rdPayment";

@interface YGPayCell_3rdPayment ()
@property (weak, nonatomic) IBOutlet YGPayThridPlatformPanel *platformPanel;
@property (strong, nonatomic) YGPayThirdPlatformPanelConfig *config;
@end

@implementation YGPayCell_3rdPayment

+ (CGFloat)cellHeight
{
    return 28.f + kYGPayThirdPlatformPanelHeight;
}

- (YGPayThirdPlatformPanelConfig *)config
{
    if (!_config) {
        _config = [YGPayThirdPlatformPanelConfig new];
    }
    return _config;
}

- (void)setFrame:(CGRect)frame
{
    CGFloat h = CGRectGetHeight(frame);
    if (self.payment.thirdPlatform > 0) {
        h = [YGPayCell_3rdPayment cellHeight];
    }
    frame.size.height = h;
    [super setFrame:frame];
}

- (void)setup
{
    if (self.payment.advance > 0) {
        self.priceLabel.text = [NSString stringWithFormat:@"￥0"];
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)self.payment.thirdPlatform];
    }

    ygweakify(self);
    [self.platformPanel setSelectedPlatformDidChangedCallback:^(NSNumber *platform) {
        ygstrongify(self);
        if (platform) {
            self.payment.platform = platform.integerValue;
        }else{
            self.payment.platform = YGPaymentPlatformInApp;
        }
    }];
    [self.platformPanel setShouldAdjustHeightCallback:^(CGFloat height) {
        ygstrongify(self);
        if (self.shouldAdjustHeight) {
            self.shouldAdjustHeight([YGPayCell_3rdPayment cellHeight]);
        }
    }];
    
    NSMutableArray *platforms = [NSMutableArray array];
    
    // 微信支付
    [platforms addObject:@(YGPaymentPlatformWechat)];
    
    
    
    // 银联支付
    [platforms addObject:@(YGPaymentPlatformUnionpay)];
    
    // 云高垫付
    if (NO) { //TODO
        [platforms addObject:@(YGPaymentPlatformYunGao)];
    }
    
    // 支付宝支付
    [platforms addObject:@(YGPaymentPlatformAlipay)];
    
    // ApplePay
    if ([YGApplePayHelper isSupportUnionPay]) {
        [platforms addObject:@(YGPaymentPlatformApplePay)];
    }
    
    self.config.platforms = platforms;
    [self.platformPanel updateWithConfig:self.config];
}
@end

NSString *const kYGPayCell_Start = @"YGPayCell_Start";
@implementation YGPayCell_Start

+ (CGFloat)cellHeight
{
    return 72.f;
}

- (void)setup
{}

- (IBAction)btnAction:(UIButton *)btn
{
    if (self.willStartPayAction) {
        self.willStartPayAction();
    }
}
@end
