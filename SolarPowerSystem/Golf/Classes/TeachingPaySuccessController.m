//
//  TeachingPaySuccessController.m
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingPaySuccessController.h"
#import "JXChooseTimeController.h"
#import "TeachingCourseType.h"
#import "CouponNumCell.h"
#import "VoucherTableViewCell.h"
#import "AwardView.h"
#import "BaseCoverView.h"
#import "YGCouponDetailViewCtrl.h"
#import "TeachingPaySuccessTopCell.h"
#import "SharePackage.h"
#import "CouponModel.h"
#import "YGOrderHandler.h"

@interface TeachingPaySuccessController()<AwardViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    SharePackage *_share;
}
@property (nonatomic,strong) TeachingOrderDetailModel *detail;

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *couponList;
@property (nonatomic,assign) int totalCouponAmount;
@property (nonatomic,assign) BOOL isConsumeAward;
@property (nonatomic,strong) AwardModel *awardModel;


@end

@implementation TeachingPaySuccessController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.couponList = [NSMutableArray array];
    
    if (self.orderId > 0) {
        [[ServiceManager serviceManagerWithDelegate:self] teachingOrderDetail:[[LoginManager sharedManager] getSessionId] orderId:self.orderId coachId:0];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_order_detail")) {
        if (array.count > 0) {
            self.detail = array[0];
            if (_detail) {
                
                [[YGOrderHandler handlerWithOrder:self.detail] postOrderDidChangedNotification];
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":_detail,@"orderType":@3,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他
            }

            _tableView.hidden = NO;
            _tableView.scrollEnabled = NO;
            [_tableView reloadData];
            
            if (!_isConsumeAward) {
                [[ServiceManager serviceManagerWithDelegate:self] consumeAward:[[LoginManager sharedManager] getSessionId] orderId:self.orderId orderType:@"teaching"];
            }else{
                _tableView.scrollEnabled = YES;
            }
        }
    }
    if (Equal(flag, @"consume_award")) {
        _isConsumeAward = YES;
        _tableView.scrollEnabled = YES;
        if (array.count>0){
            NSDictionary *dic = array[0];
            id obj1 = dic[@"red_packet"];
            if (obj1) {
                self.awardModel = [[AwardModel alloc] initWithDic:obj1];
            }
            if (self.awardModel) {
                [self rightButtonActionWithImg:@"ic_hongbao"];
                AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
                [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
            }else{
                self.navigationItem.rightBarButtonItem = nil;
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

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.couponList.count > 0) {
        return 2+self.couponList.count;
    }
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        TeachingPaySuccessTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachingPaySuccessTopCell" forIndexPath:indexPath];
        cell.coachTimeLabel.text = [NSString stringWithFormat:@"%@-%@",self.detail.nickName,self.detail.productName];
        cell.reserveAction = ^(id obj){
            if ([LoginManager sharedManager].loginState) {
               BOOL isChooseTime = (self.detail.classType == TeachingCourseTypeMulti || self.detail.classType == TeachingCourseTypeSpecial);
                if (isChooseTime && self.detail.remainHour > 0) {
                    TeachingCoachModel *teachingCoach = [[TeachingCoachModel alloc] init];
                    teachingCoach.coachId = self.detail.coachId;
                    teachingCoach.nickName = self.detail.nickName;
                    teachingCoach.headImage = self.detail.headImage;
                    teachingCoach.teachingSite = self.detail.teachingSite;
                    
                    [self pushWithStoryboard:@"Jiaoxue" title:@"选择预约时间" identifier:@"JXChooseTimeController" completion:^(BaseNavController *controller) {
                        JXChooseTimeController *chooseTime = (JXChooseTimeController*)controller;
                        chooseTime.teachingCoach = teachingCoach;
                        chooseTime.productId = self.detail.productId;
                        chooseTime.productName = self.detail.productName;
                        chooseTime.classHour = self.detail.classHour;
                        chooseTime.remainHour = self.detail.remainHour;
                        chooseTime.classId = self.detail.classId;
                        chooseTime.classNo = self.detail.classHour-self.detail.remainHour+1;
                        chooseTime.classType = self.detail.classType;
                        chooseTime.returnCash = self.detail.giveYunbi;
                        if (_blockReturn == nil) {
                            chooseTime.blockReturn = ^(id data){
                                [self.navigationController popToViewController:self animated:YES];
                            };
                        }else{
                            chooseTime.blockReturn = _blockReturn;
                        }
                    }];
                }else{
                    [SVProgressHUD showInfoWithStatus:@"剩余课时已用完，不可预约"];
                }
            }else{
                [self doLeftNavAction];
            }
        };
        return cell;
    }else if (indexPath.row == 1){
        CouponNumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponNumCell" forIndexPath:indexPath];
        cell.couponNumLabel.text = [NSString stringWithFormat:@"恭喜您获得%d元现金券",_totalCouponAmount];
        return cell;
    }else{
        VoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoucherTableViewCell" forIndexPath:indexPath];
        cell.viewType = VoucherTableViewTypeMore;
        if (_couponList.count > 0 && indexPath.row < _couponList.count+2) {
            CouponModel *cm = _couponList[indexPath.row-2];
            [cell setPrice:[@(cm.couponAmount) description]];
            [cell setTitle:cm.couponName];
            [cell setOther:[NSString stringWithFormat:@"有效期至 %@\n%@",cm.expireTime,cm.couponDescription == nil ? @"":cm.couponDescription]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        
        if ((self.detail.classType != TeachingCourseTypeMulti && self.detail.classType != TeachingCourseTypeSpecial) || ( (self.detail.classType == TeachingCourseTypeMulti || self.detail.classType == TeachingCourseTypeSpecial) && self.detail.remainHour <= 0)){
            return 160;
        }
        return 229;
    }else if (indexPath.row == 1){
        return 59;
    }else{
        return 101;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 1){
        if (_couponList.count > 0 && indexPath.row < _couponList.count+2) {
            CouponModel *cm = _couponList[indexPath.row-2];
            YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
            vc.title = @"现金券详情";
            vc.couponModel = cm;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)doRightNavAction{
    AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
    [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
}

- (void)awardViewCallBackWithData:(AwardModel*)model{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    if (_share) {
        _share = nil;
    }
    _share = [[SharePackage alloc] initWithTitle:model.awardTitle content:model.awardContent img:[UIImage imageNamed:@"award.png"] url:model.awardUrl];
    [_share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}

- (void)doLeftNavAction{
    if (!_blockReturn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    //lyf 加 没读懂 为了解决点左键没法后退和进入下一页乱后退， 1
    else {
        _blockReturn(nil);
    }
    
}

//-(void)viewDidDisappear:(BOOL)animated{//lyf 屏蔽 没读懂 为了解决点左键没法后退和进入下一页乱后退， 2
//    [super viewDidDisappear:animated];
//    if (_blockReturn) {
//        _blockReturn(nil);
//    }
//}

@end
