//
//  SubmitSuccessController.m
//  Golf
//
//  Created by 黄希望 on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SubmitSuccessController.h"
#import "OrderSubmitStatusCell.h"
#import "ClubOrderViewController.h"
#import "AwardView.h"
#import "BaseCoverView.h"
#import "SharePackage.h"
#import "CouponNumCell.h"
#import "VoucherTableViewCell.h"
#import "YGCouponDetailViewCtrl.h"
#import "YGCapabilityHelper.h"
#import "CouponModel.h"
#import "YGOrderHandler.h"

@interface SubmitSuccessController ()<UITableViewDelegate,UITableViewDataSource,AwardViewDelegate>{
    SharePackage *_share;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic,strong) OrderDetailModel *odm;
@property (nonatomic,strong) NSMutableArray *couponList;
@property (nonatomic,assign) int totalCouponAmount;
@property (nonatomic,assign) BOOL isConsumeAward;
@property (nonatomic,strong) AwardModel *awardModel;

@end

@implementation SubmitSuccessController

#pragma mark - UITableView 相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _couponList.count>0 ? 5+_couponList.count : 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 4) {
        NSString *identifier = [self identifierWithTableView:tableView indexPath:indexPath orderStatus:_odm.orderStatus];
        OrderSubmitStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if (indexPath.row == 1) {
            [cell.orderStatusBtn setTitle:_isFromPay>0?@" 支付成功":@" 提交成功" forState:UIControlStateNormal];
        }else if (indexPath.row == 3) {
            cell.orderDetailBlock = ^(id data){
                [self pushToOrderDetail:_odm];
            };
            cell.backHomeBlock = ^(id data){
                [self.navigationController popToRootViewControllerAnimated:YES];
            };
        }
        return cell;
    }else{
        if (indexPath.row == 4){
            CouponNumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponNumCell" forIndexPath:indexPath];
            cell.couponNumLabel.text = [NSString stringWithFormat:@"恭喜您获得%d元现金券",_totalCouponAmount];
            return cell;
        }else{
            VoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoucherTableViewCell" forIndexPath:indexPath];
            cell.viewType = VoucherTableViewTypeMore;
            if (_couponList.count > 0 && indexPath.row < 5+_couponList.count) {
                CouponModel *cm = _couponList[indexPath.row-5];
                [cell setPrice:[@(cm.couponAmount) description]];
                [cell setTitle:cm.couponName];
                [cell setOther:[NSString stringWithFormat:@"有效期至 %@\n%@",cm.expireTime,cm.couponDescription == nil ? @"":cm.couponDescription]];
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 4) {
        if (_couponList.count > 0 && indexPath.row < _couponList.count+5) {
            CouponModel *cm = _couponList[indexPath.row-5];
            YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
            vc.title = @"现金券详情";
            vc.couponModel = cm;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < 4) {
        return [self cellHeightWithTableView:tableView indexPath:indexPath orderStatus:_odm.orderStatus];
    }else{
        return indexPath.row == 4 ? 59 : 101;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [GolfAppDelegate shareAppDelegate].currentController = self;
    
    self.couponList = [NSMutableArray array];
    
    [self.navigationItem setRightBarButtonItems:[self navBtnTitleAndImageItems:@[@{@"btnImageName":@"btn_ic_phone",@"btnTitle":@"客服"}]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
}

- (void)doLeftNavAction{
    if (!_blockReturn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    else {
        _blockReturn(nil);
    }
    
}

- (void)rightItemsButtonAction:(UIButton*)button{
    if (button.tag == 1) {
        [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
    }else{// 发红包
        AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
        [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"order_detail")) {
        if (array.count>0) {
            self.odm = array[0];
            
            [[YGOrderHandler handlerWithOrder:self.odm] postOrderDidChangedNotification];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":_odm,@"orderType":@1,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他

            [_tableView reloadData];
            if (!_isConsumeAward) {
                [[ServiceManager serviceManagerWithDelegate:self] consumeAward:[[LoginManager sharedManager] getSessionId] orderId:self.orderId orderType:@"teetime"];
            }
        }
    }
    if (Equal(flag, @"consume_award")) {
        _isConsumeAward = YES;
        if (array.count>0){
            NSDictionary *dic = array[0];
            id obj1 = dic[@"red_packet"];
            if (obj1) {
                self.awardModel = [[AwardModel alloc] initWithDic:obj1];
            }
            if (self.awardModel) {
                [self.navigationItem setRightBarButtonItems:[self navBtnTitleAndImageItems:@[@{@"btnImageName":@"btn_ic_phone",@"btnTitle":@"客服"},@{@"btnImageName":@"ic_hongbao_small",@"btnTitle":@"发红包"}]]];
                AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
                [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
            }else{
                [self.navigationItem setRightBarButtonItems:[self navBtnTitleAndImageItems:@[@{@"btnImageName":@"btn_ic_phone",@"btnTitle":@"客服"}]]];
            }
            NSArray *resultArr = dic[@"coupon_list"];
            if (resultArr && resultArr.count > 0) {
                _tableView.scrollEnabled = YES;
                _totalCouponAmount = 0;
                for (NSDictionary *obj in resultArr) {
                    _totalCouponAmount += [obj[@"coupon_amount"] intValue]/100;
                    CouponModel *cm = [[CouponModel alloc] initWithDic:obj];
                    [_couponList addObject:cm];
                }
                [_tableView reloadData];
            }
        }
    }
}


- (NSString*)identifierWithTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath orderStatus:(int)orderStatus{
    NSString *identifier = nil;
    switch (indexPath.row) {
        case 0:
            if (orderStatus == OrderStatusWaitEnsure) {
                identifier = _odm.payTotal > 0 ? @"OrderSubmitStatus11" : @"OrderSubmitStatus1";
            }else{
                identifier = @"OrderSubmitStatus11";
            }
            break;
        case 1:
            identifier = orderStatus == OrderStatusWaitEnsure ? (_odm.payTotal>0?@"OrderSubmitStatus2_pay":@"OrderSubmitStatus2") : @"OrderSubmitStatus22" ;
            break;
        case 2:
            identifier = @"OrderSubmitStatus3";
            break;
        case 3:
            identifier = @"OrderSubmitStatus4";
            break;
        default:
            break;
    }
    return identifier;
}

- (CGFloat)cellHeightWithTableView:(UITableView*)tableView indexPath:(NSIndexPath *)indexPath orderStatus:(int)orderStatus{
    CGFloat height = 0;
    switch (indexPath.row) {
        case 0:
            height = orderStatus == OrderStatusWaitEnsure ? 68 : 0;
            break;
        case 1:
            height = orderStatus == OrderStatusWaitEnsure ? (_odm.payTotal>0 ? 154 : 137) : 112;
            break;
        case 2:
            height = 78;
            break;
        case 3:
            height = 64;
            break;
        default:
            break;
    }
    return height;
}

- (void)pushToOrderDetail:(OrderDetailModel*)model{
    ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
    clubOrder.orderDetail = model;
    clubOrder.orderId = model.orderId;
    [self pushViewController:clubOrder title:[NSString stringWithFormat:@"订单%d",model.orderId] hide:YES];
}

- (void)awardViewCallBackWithData:(AwardModel*)model{
    if ([self needPerfectMemberData]) {
        return;
    }
    if (!_share) {
        _share = [[SharePackage alloc] initWithTitle:model.awardTitle content:model.awardContent img:[UIImage imageNamed:@"award.png"] url:model.awardUrl];
    }
    [_share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}
@end
