//
//  JXConfirmOrderController.m
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXConfirmOrderController.h"
#import "TeachingOrderStatus.h"
#import "PayOnlineViewController.h"

@interface JXConfirmOrderController()

@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *classNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *coachNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *totalPriceLabel;
@property (nonatomic,weak) IBOutlet UILabel *totalCourseLabel;
@property (nonatomic,weak) IBOutlet UIButton *doneBtn;

@property (nonatomic,weak) IBOutlet UILabel *fxLabel1;
@property (nonatomic,weak) IBOutlet UILabel *fxLabel2;
@property (nonatomic,weak) IBOutlet UIView *fxView;

@end

@implementation JXConfirmOrderController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initization];
}


-(void)back{
    if (_blockReturn) {
        _blockReturn(nil);
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initization{
    [Utilities drawView:self.headImageV radius:28 bordLineWidth:0 borderColor:nil];
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:_teachingCoach.headImage] placeholderImage:self.defaultImage];
    [self.classNameLabel setText:_productName];
    [self.coachNameLabel setText:_teachingCoach.nickName];
    [self.totalPriceLabel setText:[NSString stringWithFormat:@"¥%d",_sellingPrice]];
    [self.totalCourseLabel setText:[NSString stringWithFormat:@"%d课时",_classHour]];
    
    if (_returnCash > 0) {
        _fxLabel1.layer.borderColor = [UIColor colorWithHexString:@"#ff9547"].CGColor;
        [_fxLabel1 setText:[NSString stringWithFormat:@" 返%d ",_returnCash]];
        [_fxLabel2 setText:[NSString stringWithFormat:@"购买课程后返%d云币，1云币价值1元现金",_returnCash]];
    }else{
        _fxView.hidden = YES;
    }
}

- (IBAction)doneBtn:(id)sender{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
        return;
    }
    
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    [[ServiceManager serviceManagerWithDelegate:self] teachingSubmitOrder:[[LoginManager sharedManager] getSessionId] publicClassId:self.publicClassId productId:self.productId coachId:self.teachingCoach.coachId date:@"" time:@"" phoneNum:phoneNum];
}

- (void)loginButtonPressed:(id)sender{
    [self doneBtn:nil];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array.count > 0) {
        if (Equal(flag, @"teaching_order_submit")) {
            TeachingSubmitInfo *submitInfo = array[0];
            if (submitInfo.orderState == TeachingOrderStatusWaitPay){
                PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                payOnline.payTotal = submitInfo.orderTotal;
                payOnline.orderTotal = submitInfo.orderTotal;
                payOnline.orderId = submitInfo.orderId;
                payOnline.waitPayFlag = 3;
                payOnline.productId = submitInfo.productId;
                payOnline.academyId = submitInfo.academyId;
                payOnline.classType = submitInfo.classType;
                payOnline.classHour = self.classHour;
                payOnline.blockReturn = _blockReturn;
                [self pushViewController:payOnline title:@"在线支付" hide:YES];
            }
        }
    }
}

@end
