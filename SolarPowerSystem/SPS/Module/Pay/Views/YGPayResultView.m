//
//  YGPayResultView.m
//  Golf
//
//  Created by bo wang on 2016/11/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayResultView.h"
#import "YGPayment.h"
#import "AwardModel.h"
#import "YGCouponCell.h"
#import "YGCouponListViewCtrl.h"
#import "YGCouponDetailViewCtrl.h"
#import "YGPayRedEnvelopeViewCtrl.h"
#import "CouponModel.h"
#import "SharePackage.h"

@interface YGPayResultView () <UITableViewDelegate,UITableViewDataSource,ServiceManagerDelegate>
@property (strong, nonatomic) YGPayment *payment;

@property (strong, nonatomic) SharePackage *share;
@end

@implementation YGPayResultView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.couponPanel.hidden = YES;
    self.redEnvelopeBtn.hidden = YES;
}

- (void)updateWithResult:(YGPayment *)payment
{
    self.payment = payment;
    YGPaymentResult *result = payment.payResult;
    self.sucPanel.hidden = result.status!=YGPayStatusSuccess;
    self.sucApplePayIcon.hidden = payment.platform!=YGPaymentPlatformApplePay;
    self.failPanel.hidden = result.status!=YGPayStatusFailed;
    [self.leftBtn setTitle:result.status==YGPayStatusFailed?@"重新支付":@"查看订单" forState:UIControlStateNormal];
    
    if (result.status == YGPayStatusSuccess) {
        [self loadMoreData];
    }
}

- (IBAction)leftAction:(id)sender
{
    if (self.leftBtnAction) {
        self.leftBtnAction();
    }
}

- (IBAction)rightAction:(id)sender
{
    if (self.rightBtnAction) {
        self.rightBtnAction();
    }
}

- (IBAction)sendRedPacket:(id)sender
{
    YGPayRedEnvelopeViewCtrl *vc = [YGPayRedEnvelopeViewCtrl instanceFromStoryboard];
    vc.redEnvelopeAmount = self.payment.payResult.awardRedPackt.totalQuantity;
    ygweakify(self);
    [vc setSendToFriendAction:^{
        ygstrongify(self);
        [self sendRedEnvelopeToFriend];
    }];
    [vc show];
}

- (void)sendRedEnvelopeToFriend
{
    AwardModel *model = self.payment.payResult.awardRedPackt;
    _share = [[SharePackage alloc] initWithTitle:model.awardTitle content:model.awardContent img:[UIImage imageNamed:@"award.png"] url:model.awardUrl];
    [_share shareInfoForView:self];
}

- (void)loadMoreData
{
    [[ServiceManager serviceManagerWithDelegate:self] consumeAward:[[LoginManager sharedManager] getSessionId] orderId:self.payment.orderId orderType:PaySceneType(self.payment.scene)];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag
{
    if ([flag isEqualToString:@"consume_award"]) {
        NSArray *array = data;
        NSDictionary *dic = [array firstObject];
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            self.payment.payResult.awardRedPackt = [[AwardModel alloc] initWithDic:dic[@"red_packet"]];
            self.payment.payResult.awardCoupon = [CouponModel couponsWithData:dic[@"coupon_list"]];
            [self update];
        }
    }
}

- (void)update
{
    self.redEnvelopeBtn.hidden = !self.payment.payResult.awardRedPackt;
//    self.redEnvelopeBtn.hidden = NO;
    
    if (self.payment.payResult.awardCoupon.count > 0) {
        NSInteger amount = 0;
        for (CouponModel *c in self.payment.payResult.awardCoupon) {
            amount += c.couponAmount;
        }
        self.couponPanel.hidden = NO;
        self.couponNoteLabel.text = [NSString stringWithFormat:@"恭喜您获得%ld元现金券",(long)amount];
    }else{
        self.couponPanel.hidden = YES;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViwe

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.payment.payResult.awardCoupon.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGCouponCell forIndexPath:indexPath];
    [cell configureWithCoupon:self.payment.payResult.awardCoupon[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
    vc.couponModel = self.payment.payResult.awardCoupon[indexPath.row];
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

@end
