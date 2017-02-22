//
//  OrderSuccessViewController.m
//  Golf
//
//  Created by 黄希望 on 12-8-1.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "OrderSuccessViewController.h"
#import "AwardView.h"
#import "BaseCoverView.h"
#import "sharePackage.h"
#import "ClubOrderViewController.h"
#import "YGCouponDetailViewCtrl.h"
#import "ClubSuccessInfoCell.h"
#import "CouponNumCell.h"
#import "VoucherTableViewCell.h"
#import "SuccessTopCell.h"
#import "CommoditySuccessInfoCell.h"
#import "YGCapabilityHelper.h"
#import "CouponModel.h"

@interface OrderSuccessViewController ()<AwardViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    SharePackage *_share;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *couponList;
@property (nonatomic,assign) int totalCouponAmount;
@property (nonatomic,assign) BOOL isConsumeAward;

@property (nonatomic,strong) AwardModel *awardModel;

@end

@implementation OrderSuccessViewController

- (void)viewDidUnload
{
    self.myCondition = nil;
    self.myOrder = nil;
    [super viewDidUnload];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [GolfAppDelegate shareAppDelegate].currentController = self;
    
    self.couponList = [NSMutableArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count>0) {
        if (Equal(flag, @"order_detail")) {
            self.tableView.hidden = NO;
            self.tableView.scrollEnabled = NO;
            self.myOrder = [array objectAtIndex:0];
            [_tableView reloadData];
            if (!_isConsumeAward) {
                [[ServiceManager serviceManagerWithDelegate:self] consumeAward:[[LoginManager sharedManager] getSessionId] orderId:self.orderId orderType:@"teetime"];
            }else{
                _tableView.scrollEnabled = YES;
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
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.couponList.count > 0) {
        return 3+self.couponList.count;
    }
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SuccessTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuccessTopCell" forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 1){
        ClubSuccessInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubSuccessInfoCell" forIndexPath:indexPath];
        if (self.myOrder) {
            NSString *str = _myCondition.date ;
            if (_myCondition.date.length <= 0) {
                str = _myOrder.teetimeDate;
            }
            NSMutableString *infoStr = [NSMutableString string];
            [infoStr appendFormat:@"%@ ",[Utilities getDateStringFromString:str WithFormatter:@"MM月dd日"]];
            if (_myOrder.packageId <= 0) {
                [cell.clubNameLabel setText:_myOrder.clubName];
                if (_myOrder.agentId == 0) {
                    [infoStr appendFormat:@"%@ %@ ",_myOrder.teetimeTime, _myOrder.courseName];
                }else{
                    [infoStr appendFormat:@"%@ ",_myOrder.teetimeTime];
                }
            }else{
                [cell.clubNameLabel setText:_myOrder.packageName];
            }
            cell.dateTimeLabel.text = infoStr;
            [cell.peoplePriceLabel setText:[NSString stringWithFormat:@"%d人  ¥%d",_myOrder.memberNum,_myOrder.orderTotal]];
        }
        return cell;
    }else if (indexPath.row == 2){
        CouponNumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponNumCell" forIndexPath:indexPath];
        cell.couponNumLabel.text = [NSString stringWithFormat:@"恭喜您获得%d元现金券",_totalCouponAmount];
        return cell;
    }else{
        VoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoucherTableViewCell" forIndexPath:indexPath];
        cell.viewType = VoucherTableViewTypeMore;
        if (_couponList.count > 0 && indexPath.row < _couponList.count+3) {
            CouponModel *cm = _couponList[indexPath.row-3];
            [cell setPrice:[@(cm.couponAmount) description]];
            [cell setTitle:cm.couponName];
            [cell setOther:[NSString stringWithFormat:@"有效期至 %@\n%@",cm.expireTime,cm.couponDescription == nil ? @"":cm.couponDescription]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;
    }else if (indexPath.row == 1){
        return 94;
    }else if (indexPath.row == 2){
        return 59;
    }else{
        return 101;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
        clubOrder.orderDetail = self.myOrder;
        clubOrder.orderId = self.orderId;
        [self pushViewController:clubOrder title:[NSString stringWithFormat:@"订单%d",self.orderId] hide:YES];
    }else if (indexPath.row > 2){
        if (_couponList.count > 0 && indexPath.row < _couponList.count+3) {
            CouponModel *cm = _couponList[indexPath.row-3];
            
            YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
            vc.title = @"现金券详情";
            vc.couponModel = cm;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)rightItemsButtonAction:(UIButton*)button{
    if (button.tag == 1) {
        [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
    }else{// 发红包
        AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
        [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
    }
}

- (void)awardViewCallBackWithData:(AwardModel*)model{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    if (!_share) {
        _share = [[SharePackage alloc] initWithTitle:model.awardTitle content:model.awardContent img:[UIImage imageNamed:@"award.png"] url:model.awardUrl];
    }
    [_share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}

@end
